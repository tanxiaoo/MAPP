import 'package:flutter/material.dart';

import '../components/yellow_button.dart';
import '../const.dart';

class PayPage extends StatefulWidget {
  const PayPage({super.key});

  @override
  State<PayPage> createState() => _PayPageState();
}

class _PayPageState extends State<PayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buy Tickets"),
        titleTextStyle: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.green,
        iconTheme: const IconThemeData(
          color: AppColors.white, )
      ),
      body: const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Stack(
            children: [
              Center(
                child: Text("pay page content"),
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
                    iconUrl: 'lib/images/Card.svg',
                    label: "Pay",
                  ),
          ])),
    );
  }
}