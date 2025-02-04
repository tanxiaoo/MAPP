import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> attraction;

  const DetailPage({super.key, required this.attraction});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late String title;
  late String description;
  List<String> imageUrls = [];
  late String location;
  late String time;
  late String cost;
  late String weather;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null) {
      title = args["title"] ?? "Unknown Place";
      description = args["detailedDescription"] ?? "No details available.";
      imageUrls = List<String>.from(args["imageUrls"] ?? []);
      location = args["distance"] ?? "Unknown location";
      time = args["openingHours"] ?? "Unknown time";
      cost = args["ticketPrice"] ?? "Unknown cost";
      weather = args["weather"] ?? "Unknown weather";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFA1BB96),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrls.isNotEmpty)
            Image.network(
              imageUrls[0],
              width: double.infinity,
              height: 210,
              fit: BoxFit.cover,
            ),

          if (imageUrls.length > 2)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3, right: 3),
                    child: Image.network(
                      imageUrls[1],
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Image.network(
                      imageUrls[2],
                      width: double.infinity,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 5,
              ),
              children: [
                _buildInfoItem(Icons.place, location),
                _buildInfoItem(Icons.access_time, time),
                _buildInfoItem(Icons.attach_money, cost),
                _buildInfoItem(Icons.wb_sunny, weather),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(icon, size: 16, color: Colors.grey),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
