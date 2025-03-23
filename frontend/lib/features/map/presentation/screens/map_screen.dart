import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show sin, cos, sqrt, atan2;
import '../../../../core/models/railway_station.dart';
import '../../../../core/utils/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';

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
  final Set<Polyline> _polylines = {};
  BitmapDescriptor? customIcon;
  String selectedLanguage = 'English';

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _predictions = [];
  bool _isSearching = false;

  Position? _currentPosition;
  bool _isLocationLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
    _fetchStations();
    _getUserLocation();
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
      _polylines.clear();
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
            ),
            icon: markerIcon,
            onTap:
                () => _fetchTravelTime(
                  userLocation,
                  stationLocation,
                  station,
                ), // Moved action here
          ),
        );

        if (distance <= 10) {
          nearbyStations.add(station);
        }
      }

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
    print('Fetching travel time for ${station.name}');
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
      'travelMode': 'DRIVE',
      'routingPreference': 'TRAFFIC_AWARE',
      'computeAlternativeRoutes': false,
      'languageCode': 'en',
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-FieldMask':
              'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline,routes.legs',
          'X-Ios-Bundle-Identifier':
              'com.example.frontend', // Replace with your iOS Bundle ID
        },
        body: jsonEncode(body),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final distanceMeters = route['distanceMeters'];
          final durationSeconds = int.parse(
            route['duration'].replaceAll('s', ''),
          );
          final encodedPolyline = route['polyline']?['encodedPolyline'];

          final distanceKm = (distanceMeters / 1000).toStringAsFixed(2);
          final durationMinutes = (durationSeconds / 60).round();

          print('Distance: $distanceKm km, Duration: $durationMinutes mins');
          print('Encoded Polyline: $encodedPolyline');

          if (_calculateDistance(origin, destination) <= 10 &&
              encodedPolyline != null) {
            List<LatLng> polylinePoints = _decodePolyline(encodedPolyline);
            print('Decoded Polyline Points: $polylinePoints');

            if (polylinePoints.isNotEmpty) {
              setState(() {
                _polylines.clear();
                _polylines.add(
                  Polyline(
                    polylineId: const PolylineId('route_to_station'),
                    points: polylinePoints,
                    color: Colors.blue,
                    width: 5,
                  ),
                );
              });
              _fitMapToRoute(polylinePoints);
            } else {
              print('No valid polyline points decoded');
            }
          } else {
            print(
              'Station not within 10km or no polyline data: Distance = ${_calculateDistance(origin, destination)} km',
            );
          }

          _showTravelDetails(
            station,
            '$distanceKm km',
            '$durationMinutes mins',
          );
        } else {
          print('No routes found in response');
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

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _fitMapToRoute(List<LatLng> points) {
    if (points.isEmpty || mapController == null) {
      print('No points or map controller not ready');
      return;
    }

    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    print('Fitting map to bounds: ($minLat, $minLng) to ($maxLat, $maxLng)');
    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50,
      ),
    );
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
      'X-Ios-Bundle-Identifier': 'com.example.frontend',
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

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371;
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

  void _selectPlace(Map<String, dynamic> place) {
    final double lat = place['location']['latitude'];
    final double lng = place['location']['longitude'];
    final String displayName = place['displayName']['text'];
    print('Searched place: $displayName at ($lat, $lng)');

    RailwayStation? matchedStation;
    const double maxDistanceKm = 10.0;
    for (var station in stations) {
      bool nameMatch = false;
      final stationName = station.name.toLowerCase();
      final displayNameLower = displayName.toLowerCase();
      final stationNameEn = station.nameEn?.toLowerCase() ?? '';
      final mainPlaceName = displayNameLower.split(',')[0].trim();

      if (stationName == mainPlaceName ||
          (stationNameEn.isNotEmpty && stationNameEn == mainPlaceName) ||
          stationName.contains(mainPlaceName) ||
          (stationNameEn.isNotEmpty && stationNameEn.contains(mainPlaceName))) {
        nameMatch = true;
      }

      if (nameMatch) {
        final distance = _calculateDistance(
          LatLng(lat, lng),
          LatLng(station.latitude, station.longitude),
        );
        print(
          'Station ${station.name} at (${station.latitude}, ${station.longitude}) - Distance: $distance km',
        );
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

  Future<void> _getUserLocation() async {
    setState(() => _isLocationLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        setState(() => _isLocationLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
          setState(() => _isLocationLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
        setState(() => _isLocationLoading = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _isLocationLoading = false;
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
        _updateMarkers();
      });
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
      setState(() => _isLocationLoading = false);
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
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
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
                  onChanged: (value) => _searchPlaces(value),
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
                          onTap: () => _selectPlace(place),
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
            onPressed: _getUserLocation,
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
                _polylines.clear();
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
          'travelMode': 'DRIVE',
          'routingPreference': 'TRAFFIC_AWARE',
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
              'X-Ios-Bundle-Identifier': 'com.example.frontend',
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
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16.0),
            height: 300,
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
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
