import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show sin, cos, sqrt, atan2;
import 'dart:io' show Platform;
import '../../../../core/models/railway_station.dart';
import '../../../../core/utils/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async'; // Add this for StreamSubscription

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
  StreamSubscription<Position>?
  _positionStream; // Add this for continuous updates

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
    _fetchStations();
    _getUserLocation(); // Get initial location and start continuous updates
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

  void _updateMarkers() {
    setState(() {
      _markers.clear();
      print('Updating markers for ${stations.length} stations');
      for (var station in stations) {
        String displayName;
        switch (selectedLanguage) {
          case 'Sinhala':
            displayName =
                station.nameSi?.isNotEmpty == true
                    ? station.nameSi!
                    : station.name;
            break;
          case 'Tamil':
            displayName =
                station.nameTa?.isNotEmpty == true
                    ? station.nameTa!
                    : station.name;
            break;
          default:
            displayName =
                station.nameEn?.isNotEmpty == true
                    ? station.nameEn!
                    : station.name;
        }
        print(
          'Adding marker for $displayName at (${station.latitude}, ${station.longitude})',
        );
        _markers.add(
          Marker(
            markerId: MarkerId(station.id.toString()),
            position: LatLng(station.latitude, station.longitude),
            infoWindow: InfoWindow(
              title: displayName,
              snippet: station.city ?? 'Unknown city',
            ),
            onTap: () => _showStationDetails(station),
            icon:
                customIcon ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
      print('Total markers added: ${_markers.length}');
    });
  }

  void _showStationDetails(RailwayStation station) {
    String displayName;
    switch (selectedLanguage) {
      case 'Sinhala':
        displayName =
            station.nameSi?.isNotEmpty == true ? station.nameSi! : station.name;
        break;
      case 'Tamil':
        displayName =
            station.nameTa?.isNotEmpty == true ? station.nameTa! : station.name;
        break;
      default:
        displayName =
            station.nameEn?.isNotEmpty == true ? station.nameEn! : station.name;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'English Name',
                    station.nameEn?.isNotEmpty == true
                        ? station.nameEn!
                        : station.name,
                  ),
                  _buildDetailRow(
                    'Sinhala Name',
                    station.nameSi?.isNotEmpty == true
                        ? station.nameSi!
                        : 'Not available',
                  ),
                  _buildDetailRow(
                    'Tamil Name',
                    station.nameTa?.isNotEmpty == true
                        ? station.nameTa!
                        : 'Not available',
                  ),
                  _buildDetailRow(
                    'Address',
                    station.address ?? 'Not available',
                  ),
                  _buildDetailRow('City', station.city ?? 'Not available'),
                  _buildDetailRow(
                    'Operator',
                    station.operatorType ?? 'Not available',
                  ),
                  _buildDetailRow(
                    'Services',
                    station.services ?? 'Not available',
                  ),
                  _buildDetailRow(
                    'Created At',
                    station.createdAt?.toString() ?? 'Not available',
                  ),
                ],
              ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.white,
            elevation: 8,
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
    _positionStream?.cancel(); // Cancel the location stream
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
    };

    if (Platform.isIOS) {
      headers['X-Ios-Bundle-Identifier'] = 'com.example.frontend';
    } else if (Platform.isAndroid) {
      // Uncomment if you add Android API key restrictions
      // headers['X-Android-Package'] = 'com.example.frontend';
      // headers['X-Android-Cert'] = 'YOUR_SHA1_FINGERPRINT';
    }

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

      final displayNameParts = displayNameLower.split(',');
      final mainPlaceName = displayNameParts[0].trim();

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

  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen(
      (Position position) {
        print(
          'Location updated: (${position.latitude}, ${position.longitude})',
        );
        setState(() {
          _currentPosition = position;
          _markers.removeWhere(
            (marker) => marker.markerId.value == 'user_location',
          );
          _markers.add(
            Marker(
              markerId: const MarkerId('user_location'),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: const InfoWindow(
                title: 'Your Location',
                snippet: 'You are here',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
            ),
          );

          // Optionally move the camera to follow the user's location
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
        });
      },
      onError: (e) {
        print('Error in location stream: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error in location updates: $e')),
        );
      },
    );
  }

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
          SnackBar(
            content: const Text(
              'Location permissions are permanently denied. Please enable them in settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                Geolocator.openAppSettings();
              },
            ),
          ),
        );
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }

      // Get the initial position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLocationLoading = false;

        _markers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(
              title: 'Your Location',
              snippet: 'You are here',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        );

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
      });

      // Start continuous location updates after getting the initial position
      _startLocationUpdates();
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
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                padding: const EdgeInsets.only(bottom: 120.0),
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
}
