import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/yellow_button.dart';
import '../const.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import '../components/attraction_card.dart';
import '../data/listData.dart';
import 'package:location/location.dart' as location;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

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
  final String googleAPiKey = "AIzaSyD_VJTifAmwwH6J3TUJrKYcGqo5J33tsZk";
  LatLng? _currentLatLng;
  LatLng? _destinationLatLng; 

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId("sourceLocation"),
        icon: BitmapDescriptor.defaultMarker,
        position: _center,
      ));
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

        setState(() {
          _markers.removeWhere((marker) => marker.markerId.value == markerId);
          _markers.add(Marker(
            markerId: MarkerId(markerId),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              markerId == "currentLocation"
                  ? BitmapDescriptor.hueGreen
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
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  Future<void> _getPolyline() async {
    if (_currentLatLng == null || _destinationLatLng == null) return;

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleAPiKey,
        request: PolylineRequest(
            origin: PointLatLng(
                _currentLatLng!.latitude, _currentLatLng!.longitude),
            destination: PointLatLng(
                _destinationLatLng!.latitude, _destinationLatLng!.longitude),
            mode: TravelMode.driving));
    
    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (PointLatLng point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      _addPolyLine();
    } else {
      print("no route found");
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
            height: 13,
          ),
          SizedBox(
            height: 300,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition:
                  CameraPosition(target: _center, zoom: 11.0),
              markers: _markers,
              polylines: _polylines,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 180),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "${listData.length} sights",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listData.length,
              itemBuilder: (context, index) {
                final attraction = listData[index];
                return AttractionCard(
                  title: attraction["title"],
                  description: attraction["description"],
                  imageUrls: List<String>.from(attraction["imageUrls"]),
                  distance: attraction["distance"],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            YellowButton(
              onPressed: () {},
              iconUrl: 'lib/images/plan_save.svg',
              label: "Save Plan",
            ),
            YellowButton(
              onPressed: () {
                Get.toNamed("./pay");
              },
              iconUrl: 'lib/images/Card.svg',
              label: "Buy Tickets",
            ),
          ])),
    );
  }
}
