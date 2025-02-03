import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/yellow_button.dart';
import '../const.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../components/attraction_card2.dart';
import '../data/listData.dart';
import 'package:location/location.dart' as location;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../components/customMarker.dart';
import '../components/plan_save_card.dart';
import '../components/keepAliveWrapper.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late GoogleMapController mapController;
  final TextEditingController _currentLocationController =
      TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final LatLng _center = const LatLng(45.464211, 9.191383);
  final Set<Marker> _markers = {};
  final location.Location _location = location.Location();

  final Set<Polyline> _polylines = {};
  final List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  final String googleAPiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
  LatLng? _currentLatLng;
  LatLng? _destinationLatLng;

  Map<String, dynamic>? _selectedAttraction;
  final List<LatLng> waypoints = [];
  final List<String> waypointsTitles = [];

  Map<String, dynamic> routeDetails = {};

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    _updateMarker();
  }

  void _updateMarker() async {
    Set<Marker> updatedMarkers = {};

    final BitmapDescriptor customIcon =
        await CustomMarker.createCustomIconWithImage(
      imageUrl: 'lib/images/flag.png',
    );
    for (var attraction in listData) {
      final coordinates = LatLng(
        attraction["coordinates"]["latitude"],
        attraction["coordinates"]["longitude"],
      );

      if (!waypoints.contains(coordinates)) {
        updatedMarkers.add(Marker(
          markerId: MarkerId(attraction["title"]),
          position: coordinates,
          infoWindow: InfoWindow(
            title: attraction["title"],
          ),
          icon: customIcon,
          onTap: () {
            setState(() {
              _selectedAttraction = attraction;
            });
          },
        ));
      }
    }

    for (int i = 0; i < waypoints.length; i++) {
      final customMarker =
          await CustomMarker.createNumberedMarker(index: i + 1);
      updatedMarkers.add(Marker(
        markerId: MarkerId("waypoint_$i"),
        position: waypoints[i],
        icon: customMarker,
      ));
    }

    if (_currentLatLng != null) {
      updatedMarkers.add(Marker(
        markerId: const MarkerId("currentLocation"),
        position: _currentLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }

    if (_destinationLatLng != null) {
      updatedMarkers.add(Marker(
        markerId: const MarkerId("destination"),
        position: _destinationLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ));
    }

    setState(() {
      _markers.clear();
      _markers.addAll(updatedMarkers);
    });
  }

  Future<void> _searchPlace(String value, String markerId) async {
    try {
      List<geocoding.Location> locations =
          await geocoding.locationFromAddress(value);
      if (locations.isNotEmpty) {
        LatLng newPosition =
            LatLng(locations.first.latitude, locations.first.longitude);

        if (markerId == "currentLocation") {
          _currentLatLng = newPosition;
        } else if (markerId == "destination") {
          _destinationLatLng = newPosition;
        }

        mapController.animateCamera(CameraUpdate.newLatLng(newPosition));

        _selectedAttraction = await _getPlaceDetails(newPosition);
        _selectedAttraction!["title"] = value;
        _updateMarker();
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
        print("Location services are disabled.");
        return;
      }
      if (await _location.hasPermission() == location.PermissionStatus.denied &&
          await _location.requestPermission() !=
              location.PermissionStatus.granted) {
        print("Location permissions are denied.");
        return;
      }
      final locationData = await _location.getLocation();
      final currentPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
      _currentLatLng = currentPosition;
      mapController
          .animateCamera(CameraUpdate.newLatLngZoom(currentPosition, 14));

      // get the details of current location
      _selectedAttraction = await _getPlaceDetails(currentPosition);
      _currentLocationController.text = _selectedAttraction!["title"];
      _updateMarker();
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
          String address = place.containsKey("vicinity")
              ? place["vicinity"]
              : "No address available.";
          List<String> imageUrls = [];
          if (place.containsKey("photos") && place["photos"] is List) {
            final photos = place["photos"] as List;
            for (var i = 0; i < min(5, photos.length); i++) {
              String photoReference = photos[i]["photo_reference"];
              String imageUrl =
                  "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=$photoReference&key=$googleAPiKey";
              imageUrls.add(imageUrl);
            }
          }
          Map<String, dynamic> coordinates = {
            "latitude": position.latitude,
            "longitude": position.longitude
          };

          return {
            "title": placeName,
            "description": address,
            "imageUrls": imageUrls,
            "distance": "Current location",
            "coordinates": coordinates,
          };
        }
      }
    } catch (e) {
      print("Error fetching place details: $e");
    }
    return {
      "title": "No Place Found",
      "description": "No details available.",
      "imageUrls": [],
      "distance": "Current location",
      "coordinates": {"latitude": 0.0, "longitude": 0.0}
    };
  }

  void _addWaypoint(Map<String, dynamic>? attraction) async {
    if (attraction == null) return;

    LatLng newPoint = LatLng(
      attraction["coordinates"]["latitude"],
      attraction["coordinates"]["longitude"],
    );

    if (!waypoints.contains(newPoint)) {
      setState(() {
        waypoints.add(newPoint);
        waypointsTitles.add(attraction["title"]);
        _selectedAttraction = null;
      });

      _updateMarker();
      if (waypoints.length >= 2) {
        _getPolyline(waypoints);
      }
    }
  }

  Future<void> _getPolyline(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return;

    List<LatLng> newPolylineCoordinates = [];
    Map<String, dynamic> newRouteDetails = {};

    for (int i = 0; i < waypoints.length - 1; i++) {
      var routeData = await _requestRoute(waypoints[i], waypoints[i + 1]);
      newPolylineCoordinates.addAll(routeData["polyline"]);
      newRouteDetails["${i}_${i + 1}"] = routeData["details"];
    }

    setState(() {
      _polylines.clear();
      polylineCoordinates.clear();
      polylineCoordinates.addAll(newPolylineCoordinates);
      routeDetails = newRouteDetails;
    });

    _addPolyLine();
  }

  Future<Map<String, dynamic>> _requestRoute(LatLng start, LatLng end) async {
    try {
      final String url = "https://maps.googleapis.com/maps/api/directions/json?"
          "origin=${start.latitude},${start.longitude}"
          "&destination=${end.latitude},${end.longitude}"
          "&mode=transit"
          "&key=$googleAPiKey";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["routes"].isNotEmpty) {
          List<LatLng> polylineCoordinates = [];
          List<Map<String, String>> transportDetails = [];

          for (var route in data["routes"]) {
            for (var leg in route["legs"]) {
              for (var step in leg["steps"]) {
                print("Step Data: ${jsonEncode(step)}");
                String travelMode = step["travel_mode"];

                if (step.containsKey("polyline")) {
                  List<PointLatLng> decodePolyline =
                      polylinePoints.decodePolyline(step["polyline"]["points"]);
                  polylineCoordinates.addAll(decodePolyline
                      .map((point) => LatLng(point.latitude, point.longitude)));
                }

                if (travelMode == "TRANSIT" &&
                    step.containsKey("transit_details")) {
                  var transit = step["transit_details"];
                  transportDetails.add({
                    "mode": transit["line"]["vehicle"]["name"],
                    "line": transit["line"]["short_name"],
                    "departure": transit["departure_stop"]["name"],
                    "arrival": transit["arrival_stop"]["name"],
                    "duration": leg["duration"]["text"],
                    "distance": step["distance"]["text"],
                  });
                } else if (travelMode == "WALKING") {
                  transportDetails.add({
                    "mode": "Walking",
                    "line": "",
                    "departure": step["start_location"].toString(),
                    "arrival": step["end_location"].toString(),
                    "duration": step["duration"]["text"],
                    "distance": step["distance"]["text"],
                  });
                }
              }
            }
          }
          return {
            "polyline": polylineCoordinates,
            "details": transportDetails,
          };
        } else {
          return {"polyline": [], "details": []};
        }
      } else {
        return {"polyline": [], "details": []};
      }
    } catch (e) {
      return {"polyline": [], "details": []};
    }
  }

  void _addPolyLine() {
    setState(() {
      _polylines.clear();
      _polylines.add(Polyline(
        polylineId: PolylineId("polyline"),
        color: Colors.red,
        width: 5,
        points: List.from(polylineCoordinates),
      ));
    });
  }

  void _updateWaypoints(
      List<LatLng> newWaypoints, List<String> newTiles) async {
    setState(() {
      waypoints.clear();
      waypointsTitles.clear();
      waypoints.addAll(newWaypoints);
      waypointsTitles.addAll(newTiles);
      _polylines.clear();
      polylineCoordinates.clear();
    });

    _updateMarker();
    _getPolyline(waypoints);
  }

  @override
  Widget build(BuildContext context) {
    return KeepAliveWrapper(
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Plan"),
              titleTextStyle: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: AppColors.green,
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    TextField(
                      controller: _currentLocationController,
                      onSubmitted: (value) =>
                          _searchPlace(value, "currentLocation"),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.my_location,
                              color: Colors.green),
                          onPressed: _getCurrentLocation,
                          tooltip: "Get Current Location",
                        ),
                        hintText: "Current Location",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextField(
                      controller: _destinationController,
                      onSubmitted: (value) =>
                          _searchPlace(value, "destination"),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        hintText: "Where do you want to visit",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition:
                            CameraPosition(target: _center, zoom: 16.0),
                        markers: _markers,
                        polylines: _polylines,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _selectedAttraction != null
                      ? AttractionCard2(
                          title: _selectedAttraction!["title"],
                          description: _selectedAttraction!["description"],
                          imageUrls: List<String>.from(
                              _selectedAttraction!["imageUrls"]),
                          distance: _selectedAttraction!["distance"],
                          onAddWaypoint: () {
                            _addWaypoint(_selectedAttraction);
                            setState(() {
                              _selectedAttraction = null;
                            });
                          },
                        )
                      : (waypoints.length >= 2
                          ? PlanSaveCard(
                              waypoints: waypoints,
                              waypointsTitles: waypointsTitles,
                              routeDetails: routeDetails,
                              onReorderCompleted: (newWaypoints, newTitles) {
                                _updateWaypoints(newWaypoints, newTitles);
                              },
                            )
                          : Container()),
                ),
              ],
            )));
  }
}
