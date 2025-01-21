import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../components/my_textfield.dart';
import '../components/attraction_card.dart';
import '../data/listData.dart';
import '../const.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  final LatLng _center = const LatLng(45.464211, 9.191383);

  final Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    setState(() {
      for (var attrtaction in listData) {
        final coordinates = attrtaction["coordinates"];
        final marker = Marker(
          markerId: MarkerId(attrtaction["title"]),
          position: LatLng(coordinates["latitude"], coordinates["longitude"]),
          infoWindow: InfoWindow(
            title: attrtaction["title"],
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), 
        );
        _markers.add(marker);
      }
      
      _markers.add(Marker(
        markerId: const MarkerId("sourceLocation"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: _center,
      ));
    });
  }

  Future<void> _searchPlace(String value) async {
    try {
      List<Location> locations = await locationFromAddress(value);
      if (locations.isNotEmpty) {
        LatLng newPosition =
            LatLng(locations.first.latitude, locations.first.longitude);
        mapController.animateCamera(CameraUpdate.newLatLng(newPosition));

        setState(() {
          _markers.clear();
          _markers.add(Marker(
            markerId: const MarkerId("searchedLocation"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("home"),
        ),
        body: Column(
          children: [
            TextField(
              controller: _searchController,
              onSubmitted: _searchPlace,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                  prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              )),
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
        ));
  }
}
