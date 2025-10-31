import 'package:flutter/material.dart';
import 'package:dummy/app_colours.dart';

class ProfileTile extends StatelessWidget {
  final String name;
  final String booklet;
  final VoidCallback onTap;

  const ProfileTile({
    super.key,
    required this.name,
    required this.booklet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 24, backgroundColor: AppColours.grey3),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColours.darkText,
                    ),
                  ),
                  Text(
                    "Booklet No: $booklet",
                    style: TextStyle(fontSize: 12, color: AppColours.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: AppColours.grey),
          ],
        ),
      ),
    );
  }
}
