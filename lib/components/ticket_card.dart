import 'package:flutter/material.dart';

class TicketCard extends StatelessWidget {
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final String departureStation;
  final String arrivalStation;
  final String operatorName;
  final String price;
  final int changes;
  final bool isSelected; 
  final VoidCallback onTap;

  const TicketCard({
    super.key,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.departureStation,
    required this.arrivalStation,
    required this.operatorName,
    required this.price,
    required this.changes,
    required this.isSelected,
    required this.onTap, 
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, 
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        margin: EdgeInsets.zero,
        color: isSelected ? Colors.yellow[200] : Colors.white, 
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _capitalize(operatorName),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      price,
                      style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      departureTime,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    Text(
                      duration,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      arrivalTime,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _capitalize(departureStation),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    Text(
                      _capitalize(arrivalStation),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Colors.grey),
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz, color: Colors.grey, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      "$changes ${changes == 1 ? "Change" : "Changes"}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
