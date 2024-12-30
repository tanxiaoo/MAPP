import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class YellowButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String iconUrl;
  final String label;
  final double width;
  const YellowButton({
    super.key,
    required this.iconUrl,
    required this.label,
    required this.onPressed,
    this.width = 150,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: SvgPicture.asset(
          iconUrl,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 6),
          backgroundColor: Colors.yellow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
