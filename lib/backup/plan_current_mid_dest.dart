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
import '../components/customIcon.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  late GoogleMapController mapController;
  final TextEditingController _currentLocationController =
      TextEditingController();
  final TextEditingController _midPointController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final LatLng _center = const LatLng(45.464211, 9.191383);
  final Set<Marker> _markers = {};
  final location.Location _location = location.Location();

  final Set<Polyline> _polylines = {};
  final List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  final String googleAPiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';
  LatLng? _currentLatLng;
  LatLng? _midPointLatLng;
  LatLng? _destinationLatLng;

  Map<String, dynamic>? _selectedAttraction;

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    final BitmapDescriptor customIcon =
        await CustomIcon.createCustomIconWithImage(
      imageUrl: 'lib/images/flag.png',
    );
    setState(() {
      for (var attrtaction in listData) {
        final coordinates = attrtaction["coordinates"];
        final marker = Marker(
          markerId: MarkerId(attrtaction["title"]),
          position: LatLng(coordinates["latitude"], coordinates["longitude"]),
          infoWindow: InfoWindow(
            title: attrtaction["title"],
          ),
          icon: customIcon,
          onTap: () {
            setState(() {
              _selectedAttraction = attrtaction;
            });
          },
        );
        _markers.add(marker);
      }

      _markers.add(Marker(
        markerId: const MarkerId("sourceLocation"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: _center,
      ));
    });

    await Future.delayed(const Duration(milliseconds: 500));
    for (var attraction in listData) {
      mapController.showMarkerInfoWindow(MarkerId(attraction["title"]));
    }
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
        } else if (markerId == "midPoint") {
          _midPointLatLng = newPosition;
        } else if (markerId == "destination") {
          _destinationLatLng = newPosition;
        }

        mapController.animateCamera(CameraUpdate.newLatLng(newPosition));

        setState(() {
          _markers.removeWhere((marker) => marker.markerId.value == markerId);
          _markers.add(Marker(
            markerId: MarkerId(markerId),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              markerId == "currentLocation"
                  ? BitmapDescriptor.hueGreen
                  : markerId == "midPoint"
                      ? BitmapDescriptor.hueOrange
                      : BitmapDescriptor.hueViolet,
            ),
            position: newPosition,
          ));
        });

        if (_currentLatLng != null && _destinationLatLng != null) {
          _getPolyline();
        }
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
      setState(() {
        _markers.removeWhere(
            (marker) => marker.markerId.value == "currentLocation");
        _markers.add(Marker(
          markerId: const MarkerId("currentLocation"),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: currentPosition,
        ));
      });

      // get the name of current location
      String placeName = await _getPlaceNameFromLocation(
          currentPosition.latitude, currentPosition.longitude);
      setState(() {
        _currentLocationController.text = placeName;
      });
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<String> _getPlaceNameFromLocation(
      double latitude, double longitude) async {
    try {
      final String url =
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
          "?location=$latitude,$longitude&rankby=distance&key=$googleAPiKey";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["results"].isNotEmpty) {
          return data["results"][0]["name"] ?? "Unknown Place";
        }
        return "No Place Found";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      print("Error fetching place name: $e");
      return "Unknown Place";
    }
  }

  Future<void> _getPolyline() async {
    if (_currentLatLng == null || _destinationLatLng == null) return;
    polylineCoordinates.clear();

    List<LatLng?> waypoints = [
      _currentLatLng,
      _midPointLatLng,
      _destinationLatLng
    ];

    for (int i = 0; i < waypoints.length - 1; i++) {
      if (waypoints[i] != null && waypoints[i + 1] != null) {
        List<LatLng> segment =
            await _requestRoute(waypoints[i]!, waypoints[i + 1]!);
        polylineCoordinates.addAll(segment);
      }

      _addPolyLine();
    }
  }

  Future<List<LatLng>> _requestRoute(LatLng start, LatLng end) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleAPiKey,
      request: PolylineRequest(
          origin: PointLatLng(start.latitude, start.longitude),
          destination: PointLatLng(end.latitude, end.longitude),
          mode: TravelMode.driving),
    );

    if (result.points.isNotEmpty) {
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      return [];
    }
  }

  void _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        width: 5,
        points: polylineCoordinates);
    _polylines.add(polyline);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan"),
        titleTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.green,
      ),
      body: Column(
        children: [
          TextField(
            controller: _currentLocationController,
            onSubmitted: (value) => _searchPlace(value, "currentLocation"),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.my_location, color: Colors.green),
                onPressed: _getCurrentLocation,
                tooltip: "Get Current Location",
              ),
              hintText: "Current Location",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          TextField(
            controller: _midPointController,
            onSubmitted: (value) => _searchPlace(value, "midPoint"),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
              hintText: "Midpoint",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          TextField(
            controller: _destinationController,
            onSubmitted: (value) => _searchPlace(value, "destination"),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
              hintText: "Destination",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          SizedBox(
            height: 300,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition:
                  CameraPosition(target: _center, zoom: 16.0),
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Expanded(
            child: _selectedAttraction == null? Center(
              child:Text("choose a view point",style: TextStyle(fontSize: 16, color:Colors.grey),) 
            ):AttractionCard2(
              title: _selectedAttraction!["title"], 
              description: _selectedAttraction!["description"], 
              imageUrls: List<String>.from(_selectedAttraction!["imageUrls"]), 
              distance: _selectedAttraction!["distance"],
            )
          ),
        ],
      ),
      // bottomNavigationBar: Padding(
      //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      //     child:
      //         Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      //       YellowButton(
      //         onPressed: () {},
      //         iconUrl: 'lib/images/plan_save.svg',
      //         label: "Save Plan",
      //       ),
      //       YellowButton(
      //         onPressed: () {
      //           Get.toNamed("./pay");
      //         },
      //         iconUrl: 'lib/images/Card.svg',
      //         label: "Buy Tickets",
      //       ),
      //     ])),
    );
  }
}
