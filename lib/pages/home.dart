import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("home"),
      ),
      body: Center(
          child: Column(
        children: [
          const Text("home page content"),
          TextButton(
              onPressed: () {
                Get.toNamed("/detail");
              },
              child: const Text("Details"))
        ],
      )),
    );
  }
}
