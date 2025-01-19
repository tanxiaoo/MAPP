import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../components/my_textfield.dart';
import '../components/attraction_card.dart';
import '../data/listData.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _searchPlace(String value) async {
    try {
      List<Location> locations = await locationFromAddress(value);
      if (locations.isNotEmpty) {
        mapController.animateCamera(CameraUpdate.newLatLng(
          LatLng(locations.first.latitude, locations.first.longitude),
        ));
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
              ),
            ),
            const SizedBox(height: 16,),
            Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 180),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10)
              ),
            ),
            const SizedBox(height: 10,),
            Text(
            "${listData.length} sights",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
            const SizedBox(height: 10,),
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
        )
      );
  }
}