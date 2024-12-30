import 'package:flutter/material.dart';

import '../components/yellow_button.dart';
import '../const.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Me"),
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
                child: Text("list page content"),
              ),
            ],
          )),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                children: [
                  YellowButton(
                    width: 300,
                    onPressed: () {},
                    iconUrl: 'lib/images/Logout.svg',
                    label: "Log Out",
                  ),
          ])),
    );
  }
}
