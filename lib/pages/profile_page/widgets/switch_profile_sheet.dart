import 'package:dummy/app_colours.dart';
import 'package:dummy/pages/profile_page/widgets/profile_selection_tile.dart';
import 'package:flutter/material.dart';

class SwitchProfileSheet extends StatelessWidget {
  const SwitchProfileSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> profiles = [
      {"name": "Rakesh Kumar", "booklet": "12334567", "age": 37},
      {"name": "Priya Gupta", "booklet": "12334567", "age": 35},
      {"name": "Vihaan Kumar", "booklet": "12334567", "age": 8},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Select Profile",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColours.darkText,
            ),
          ),
          const SizedBox(height: 16),
          ...profiles.map(
            (p) => ProfileSelectionTile(
              name: p["name"],
              booklet: p["booklet"],
              age: p["age"],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
