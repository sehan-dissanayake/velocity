import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show sin, cos, sqrt, atan2;
import '../../../../core/models/railway_station.dart';
import '../../../../core/utils/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart'; // Add this import

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<RailwayStation> stations = [];
  bool isLoading = true;
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  BitmapDescriptor? customIcon;
  String selectedLanguage = 'English'; // Default language

  // Search-related variables
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _predictions = [];
  bool _isSearching = false;

  // User location-related variables
  Position? _currentPosition;
  bool _isLocationLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
    _fetchStations();
    _getUserLocation(); // Call this to get the user's location on init
  }

  Future<void> _loadCustomIcon() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/train_icon.png',
    );
    setState(() {});
  }

  Future<void> _fetchStations() async {
    try {
      final apiService = ApiService();
      final fetchedStations = await ApiService.fetchRailwayStations();
      print('Fetched stations: ${fetchedStations.length}');
      for (var station in fetchedStations) {
        print(
          'Station: ${station.name}, Lat: ${station.latitude}, Lng: ${station.longitude}',
        );
      }
      setState(() {
        stations = fetchedStations;
        _updateMarkers();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching stations: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading stations: $e')));
    }
  }

  void _showStationDetails(RailwayStation station) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              station.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Latitude', station.latitude.toString()),
                _buildDetailRow('Longitude', station.longitude.toString()),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }

  void _updateMarkers() {
    if (_currentPosition == null || stations.isEmpty) return;

    setState(() {
      _markers.clear();
      final LatLng userLocation = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      List<RailwayStation> nearbyStations = [];

      for (var station in stations) {
        LatLng stationLocation = LatLng(station.latitude, station.longitude);
        double distance = _calculateDistance(userLocation, stationLocation);

        String displayName =
            selectedLanguage == 'Sinhala'
                ? station.nameSi ?? station.name
                : selectedLanguage == 'Tamil'
                ? station.nameTa ?? station.name
                : station.nameEn ?? station.name;

        BitmapDescriptor markerIcon =
            distance <= 10
                ? BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                )
                : BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                );

        _markers.add(
          Marker(
            markerId: MarkerId(station.id.toString()),
            position: stationLocation,
            infoWindow: InfoWindow(
              title: displayName,
              snippet: 'Distance: ${distance.toStringAsFixed(2)} km',
              onTap:
                  () =>
                      _fetchTravelTime(userLocation, stationLocation, station),
            ),
            icon: markerIcon,
          ),
        );

        if (distance <= 10) {
          nearbyStations.add(station);
        }
      }

      // Add user location marker
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: userLocation,
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'You are here',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );

      // Fetch travel info for nearby stations if any exist
      if (nearbyStations.isNotEmpty) {
        _fetchTravelInfoForNearbyStations(nearbyStations);
      }
    });
  }

  Future<void> _fetchTravelTime(
    LatLng origin,
    LatLng destination,
    RailwayStation station,
  ) async {
    final apiKey = dotenv.get('GOOGLE_MAPS_API_KEY');
    final url = Uri.parse(
      'https://routes.googleapis.com/directions/v2:computeRoutes?key=$apiKey',
    );

    final Map<String, dynamic> body = {
      'origin': {
        'location': {
          'latLng': {
            'latitude': origin.latitude,
            'longitude': origin.longitude,
          },
        },
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': destination.latitude,
            'longitude': destination.longitude,
          },
        },
      },
      'travelMode': 'TRANSIT',
      'routingPreference': 'LESS_WALKING',
      'computeAlternativeRoutes': false,
      'languageCode': 'en',
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-FieldMask':
              'routes.duration,routes.distanceMeters,routes.legs',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final distanceMeters = route['distanceMeters'];
          final durationSeconds = int.parse(
            route['duration'].replaceAll('s', ''),
          );

          // Convert distance to kilometers
          final distanceKm = (distanceMeters / 1000).toStringAsFixed(2);
          // Convert duration to minutes
          final durationMinutes = (durationSeconds / 60).round();

          _showTravelDetails(
            station,
            '$distanceKm km',
            '$durationMinutes mins',
          );
        } else {
          _showTravelDetails(station, 'N/A', 'No transit info');
        }
      } else {
        print('Failed to fetch routes: ${response.body}');
        _showTravelDetails(station, 'Error', 'Error');
      }
    } catch (e) {
      print('Error fetching routes: $e');
      _showTravelDetails(station, 'Error', 'Error');
    }
  }

  void _showTravelDetails(
    RailwayStation station,
    String distance,
    String duration,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              station.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Distance', distance),
                _buildDetailRow('Estimated Travel Time', duration),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 16),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    print('Map created');
    // If we have the user's location, move the camera there; otherwise, use the default position
    if (_currentPosition != null) {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 15.0,
          ),
        ),
      );
    } else {
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(target: LatLng(7.8731, 80.7718), zoom: 8.0),
        ),
      );
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Search for places using Places API (New) Text Search
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
        _isSearching = false;
      });
      return;
    }

    final String apiKey = dotenv.get('GOOGLE_MAPS_API_KEY');
    print('Using API Key: $apiKey');
    const String url = 'https://places.googleapis.com/v1/places:searchText';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'places.displayName,places.location',
      'X-Ios-Bundle-Identifier':
          'com.example.frontend', // Replace with your app's bundle ID
    };
    final Map<String, dynamic> body = {
      'textQuery': query,
      'locationBias': {
        'circle': {
          'center': {'latitude': 7.8731, 'longitude': 80.7718},
          'radius': 50000.0,
        },
      },
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          _predictions = List<Map<String, dynamic>>.from(
            jsonResponse['places'] ?? [],
          );
          _isSearching = true;
        });
      } else {
        print(
          'HTTP error searching places: ${response.statusCode} - ${response.body}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching places: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error searching places: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error searching places: $e')));
    }
  }

  // Helper function to calculate the distance between two LatLng points (in kilometers)
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers
    final double dLat = (point2.latitude - point1.latitude) * (3.14159 / 180);
    final double dLng = (point2.longitude - point1.longitude) * (3.14159 / 180);
    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(point1.latitude) *
            cos(point2.latitude) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // Handle place selection
  void _selectPlace(Map<String, dynamic> place) {
    final double lat = place['location']['latitude'];
    final double lng = place['location']['longitude'];
    final String displayName = place['displayName']['text'];
    print('Searched place: $displayName at ($lat, $lng)');

    // Check if the searched place matches a railway station
    RailwayStation? matchedStation;
    const double maxDistanceKm =
        10.0; // Maximum distance in kilometers to consider a match
    for (var station in stations) {
      // Check if the station name or nameEn is a close match to the displayName
      bool nameMatch = false;
      final stationName = station.name.toLowerCase();
      final displayNameLower = displayName.toLowerCase();
      final stationNameEn = station.nameEn?.toLowerCase() ?? '';

      // Split the displayName to get the main place name (e.g., "Kandy" from "Kandy, Sri Lanka")
      final displayNameParts = displayNameLower.split(',');
      final mainPlaceName = displayNameParts[0].trim();

      // Check for a match (exact or close match)
      if (stationName == mainPlaceName ||
          (stationNameEn.isNotEmpty && stationNameEn == mainPlaceName) ||
          stationName.contains(mainPlaceName) ||
          (stationNameEn.isNotEmpty && stationNameEn.contains(mainPlaceName))) {
        nameMatch = true;
      }

      if (nameMatch) {
        // Calculate the distance between the searched location and the station
        final distance = _calculateDistance(
          LatLng(lat, lng),
          LatLng(station.latitude, station.longitude),
        );
        _showStationDetails(matchedStation!);
        print(
          'Station ${station.name} at (${station.latitude}, ${station.longitude}) - Distance: $distance km',
        );

        // Only consider the station a match if it's within the max distance
        if (distance <= maxDistanceKm) {
          print(
            'Matched station: ${station.name} at (${station.latitude}, ${station.longitude})',
          );
          matchedStation = station;
          break;
        }
      }
    }

    setState(() {
      _markers.removeWhere(
        (marker) => marker.markerId.value == 'searched_place',
      );
      if (matchedStation != null) {
        print(
          'Zooming to matched station: ${matchedStation.name} at (${matchedStation.latitude}, ${matchedStation.longitude})',
        );
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(matchedStation.latitude, matchedStation.longitude),
              zoom: 15.0,
            ),
          ),
        );
        _showStationDetails(matchedStation);
      } else {
        print('No matched station, zooming to searched location: ($lat, $lng)');
        _markers.add(
          Marker(
            markerId: const MarkerId('searched_place'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: displayName,
              snippet: 'Searched Location',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(lat, lng), zoom: 15.0),
          ),
        );
      }
      _searchController.clear();
      _predictions = [];
      _isSearching = false;
    });
  }

  // New method to get the user's current location
  Future<void> _getUserLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location services are disabled. Please enable them.',
            ),
          ),
        );
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
          setState(() {
            _isLocationLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLocationLoading = false;

        // Move the camera to the user's location if the map is already created
        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 15.0,
              ),
            ),
          );
        }

        _updateMarkers(); // Add this line
      });
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Railway Stations Map'),
        actions: [
          DropdownButton<String>(
            value: selectedLanguage,
            items:
                ['English', 'Sinhala', 'Tamil']
                    .map(
                      (language) => DropdownMenuItem(
                        value: language,
                        child: Text(language),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                selectedLanguage = value!;
                _updateMarkers();
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(7.8731, 80.7718),
                  zoom: 8.0,
                ),
                markers: _markers,
                myLocationEnabled:
                    true, // This shows the blue dot for the user's location
                myLocationButtonEnabled:
                    true, // This adds the default "My Location" button
                zoomControlsEnabled: true,
              ),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a place...',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _predictions = [];
                          _isSearching = false;
                        });
                      },
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.blueAccent,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  onChanged: (value) {
                    _searchPlaces(value);
                  },
                ),
                if (_isSearching && _predictions.isNotEmpty)
                  Container(
                    color: Colors.white,
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _predictions.length,
                      itemBuilder: (context, index) {
                        final place = _predictions[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(place['displayName']['text'] ?? ''),
                          onTap: () {
                            _selectPlace(place);
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (_isLocationLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed:
                _getUserLocation, // Add a button to get the user's location
            child: const Icon(Icons.my_location),
            tooltip: 'Get My Location',
            heroTag: 'getLocation',
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _markers.removeWhere(
                  (marker) => marker.markerId.value == 'searched_place',
                );
                _updateMarkers();
                mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    const CameraPosition(
                      target: LatLng(7.8731, 80.7718),
                      zoom: 8.0,
                    ),
                  ),
                );
              });
            },
            child: const Icon(Icons.refresh),
            tooltip: 'Reset Map',
            heroTag: 'resetMap',
          ),
        ],
      ),
    );
  }

  Future<void> _fetchTravelInfoForNearbyStations(
    List<RailwayStation> nearbyStations,
  ) async {
    if (nearbyStations.isEmpty || _currentPosition == null) return;

    final apiKey = dotenv.get('GOOGLE_MAPS_API_KEY');
    final origin = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
    List<Map<String, dynamic>> travelInfoList = [];

    // Process all stations concurrently
    await Future.wait(
      nearbyStations.map((station) async {
        final destination = LatLng(station.latitude, station.longitude);
        final url = Uri.parse(
          'https://routes.googleapis.com/directions/v2:computeRoutes?key=$apiKey',
        );

        final Map<String, dynamic> body = {
          'origin': {
            'location': {
              'latLng': {
                'latitude': origin.latitude,
                'longitude': origin.longitude,
              },
            },
          },
          'destination': {
            'location': {
              'latLng': {
                'latitude': destination.latitude,
                'longitude': destination.longitude,
              },
            },
          },
          'travelMode': 'TRANSIT',
          'routingPreference': 'LESS_WALKING',
          'computeAlternativeRoutes': false,
          'languageCode': 'en',
        };

        try {
          final response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-FieldMask':
                  'routes.duration,routes.distanceMeters,routes.legs',
            },
            body: jsonEncode(body),
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['routes'] != null && data['routes'].isNotEmpty) {
              final route = data['routes'][0];
              final distanceMeters = route['distanceMeters'];
              final durationSeconds = int.parse(
                route['duration'].replaceAll('s', ''),
              );

              final distanceKm = (distanceMeters / 1000).toStringAsFixed(2);
              final durationMinutes = (durationSeconds / 60).round();

              travelInfoList.add({
                'station': station,
                'distance': '$distanceKm km',
                'duration': '$durationMinutes mins',
              });
            } else {
              travelInfoList.add({
                'station': station,
                'distance': 'N/A',
                'duration': 'No transit info',
              });
            }
          } else {
            print(
              'Failed to fetch routes for ${station.name}: ${response.body}',
            );
            travelInfoList.add({
              'station': station,
              'distance': 'Error',
              'duration': 'Error',
            });
          }
        } catch (e) {
          print('Error fetching routes for ${station.name}: $e');
          travelInfoList.add({
            'station': station,
            'distance': 'Error',
            'duration': 'Error',
          });
        }
      }),
    );

    // Sort by distance (if desired)
    travelInfoList.sort((a, b) {
      final aDist =
          double.tryParse(a['distance'].replaceAll(' km', '')) ??
          double.infinity;
      final bDist =
          double.tryParse(b['distance'].replaceAll(' km', '')) ??
          double.infinity;
      return aDist.compareTo(bDist);
    });

    _showNearbyStationsSheet(travelInfoList);
  }

  void _showNearbyStationsSheet(List<Map<String, dynamic>> travelInfoList) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 300, // Adjust height as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nearby Railway Stations (within 10km)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: travelInfoList.length,
                  itemBuilder: (context, index) {
                    final info = travelInfoList[index];
                    final station = info['station'] as RailwayStation;
                    final distance = info['distance'] as String;
                    final duration = info['duration'] as String;
                    return ListTile(
                      title: Text(station.name),
                      subtitle: Text('Distance: $distance, Time: $duration'),
                      onTap: () {
                        mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                station.latitude,
                                station.longitude,
                              ),
                              zoom: 15.0,
                            ),
                          ),
                        );
                        Navigator.pop(context); // Close the bottom sheet
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
