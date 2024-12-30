import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/yellow_button.dart';
import '../const.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attraction Name"),
        titleTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.green,
      ),
      body: const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Stack(
            children: [
              Center(
                child: Text("Attraction page content"),
              ),
            ],
          )),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            YellowButton(
              onPressed: () {
                Get.toNamed("/plan");
              },
              iconUrl: 'lib/images/visit.svg',
              label: "Visit Here",
            ),
            YellowButton(
              onPressed: () {},
              iconUrl: 'lib/images/plan_favorites.svg',
              label: "Add List",
            ),
          ])),
    );
  }
}
