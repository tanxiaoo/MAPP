import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/yellow_button.dart';
import '../const.dart';

class PlanPage extends StatefulWidget {
  const PlanPage({super.key});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
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
      body: const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Stack(
            children: [
              Center(
                child: Text("plan page content"),
              ),
            ],
          )),
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
