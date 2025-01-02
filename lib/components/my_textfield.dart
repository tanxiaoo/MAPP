import 'package:flutter/material.dart';
import '../const.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SizedBox(
          height: 36,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.green),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.yellow),
              ),
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ));
  }
}
