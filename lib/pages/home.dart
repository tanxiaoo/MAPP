import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart' as location;
import 'package:http/http.dart' as http;
import '../components/attraction_card1.dart';
import '../data/listData.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../components/customMarker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  final TextEditingController _currentLocationController =
      TextEditingController();
  final LatLng _center = const LatLng(45.464211, 9.191383);
  final Set<Marker> _markers = {};
  final location.Location _location = location.Location();
  final String googleAPiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
  LatLng? _currentLatLng;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _updateMarker();
  }

  void _updateMarker() async {
    Set<Marker> updatedMarkers = {};

    final BitmapDescriptor customIcon =
        await CustomMarker.createCustomIconWithImage(
            imageUrl: 'lib/images/flag.png');

    for (var i = 0; i < listData.length; i++) {
      final attraction = listData[i];
      final coordinates = LatLng(
        attraction["coordinates"]["latitude"],
        attraction["coordinates"]["longitude"],
      );

      updatedMarkers.add(Marker(
        markerId: MarkerId(attraction["title"]),
        position: coordinates,
        infoWindow: InfoWindow(title: attraction["title"]),
        icon: customIcon,
        onTap: () {
          _scrollToIndex(i);
        },
      ));
    }

    if (_currentLatLng != null) {
      updatedMarkers.add(Marker(
        markerId: const MarkerId("currentLocation"),
        position: _currentLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }

    setState(() {
      _markers.clear();
      _markers.addAll(updatedMarkers);
    });
  }

  Future<void> _searchPlace(String value) async {
    try {
      List<geocoding.Location> locations =
          await geocoding.locationFromAddress(value);
      if (locations.isNotEmpty) {
        LatLng newPosition =
            LatLng(locations.first.latitude, locations.first.longitude);
        _currentLatLng = newPosition;
        mapController.animateCamera(CameraUpdate.newLatLng(newPosition));

        final placeDetails = await _getPlaceDetails(newPosition);
        _currentLocationController.text = placeDetails["title"];

        setState(() {
          _markers.add(Marker(
            markerId: const MarkerId("currentLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position: newPosition,
          ));
        });
      } else {
        print("No locations found for: $value");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (!await _location.serviceEnabled() &&
          !await _location.requestService()) {
        return;
      }
      if (await _location.hasPermission() == location.PermissionStatus.denied &&
          await _location.requestPermission() !=
              location.PermissionStatus.granted) {
        return;
      }
      final locationData = await _location.getLocation();
      final currentPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
      _currentLatLng = currentPosition;
      mapController
          .animateCamera(CameraUpdate.newLatLngZoom(currentPosition, 7));

      final placeDetails = await _getPlaceDetails(currentPosition);
      _currentLocationController.text = placeDetails["title"];

      setState(() {
        _markers.add(Marker(
          markerId: const MarkerId("currentLocation"),
          position: currentPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<Map<String, dynamic>> _getPlaceDetails(LatLng position) async {
    try {
      final String url =
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
          "?location=${position.latitude},${position.longitude}&rankby=distance&key=$googleAPiKey";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["results"].isNotEmpty) {
          final place = data["results"][0];
          String placeName = place["name"] ?? "Unknown Place";

          return {
            "title": placeName,
          };
        }
      }
    } catch (e) {
      print("Error fetching place details: $e");
    }
    return {
      "title": "No Place Found",
    };
  }

  void _scrollToIndex(int index) {
    _scrollController.animateTo(
      index * 220.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("home"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 800; 

          if (isTablet) {
            return Row(
              children: [
                Expanded(
                  flex: 1, 
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "${listData.length} sights",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: listData.length,
                          itemBuilder: (context, index) {
                            final attraction = listData[index];
                            return AttractionCard1(
                              title: attraction["title"],
                              description: attraction["description"],
                              imageUrls:
                                  List<String>.from(attraction["imageUrls"]),
                              distance: attraction["distance"],
                              onDetailsPressed: () {
                                Get.toNamed("/detail", arguments: attraction);
                              },
                              onVisitHerePressed: () {
                                Get.offNamed("/plan", arguments: attraction);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: 1, 
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5),
                        child: TextField(
                          controller: _currentLocationController,
                          onSubmitted: _searchPlace,
                          decoration: InputDecoration(
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.my_location,
                                  color: Colors.green),
                              onPressed: _getCurrentLocation,
                            ),
                            hintText: "Current Location",
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition:
                              CameraPosition(target: _center, zoom: 7.0),
                          markers: _markers,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                TextField(
                  controller: _currentLocationController,
                  onSubmitted: _searchPlace,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.green),
                      onPressed: _getCurrentLocation,
                    ),
                    hintText: "Current Location",
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 300,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition:
                        CameraPosition(target: _center, zoom: 7.0),
                    markers: _markers,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 180),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${listData.length} sights",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: listData.length,
                    itemBuilder: (context, index) {
                      final attraction = listData[index];
                      return AttractionCard1(
                        title: attraction["title"],
                        description: attraction["description"],
                        imageUrls: List<String>.from(attraction["imageUrls"]),
                        distance: attraction["distance"],
                        onDetailsPressed: () {
                          Get.toNamed("/detail", arguments: attraction);
                        },
                        onVisitHerePressed: () {
                          Get.offNamed("/plan", arguments: attraction);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
