import 'package:dummy/app_colours.dart';
import 'package:flutter/material.dart';

class ProfileSelectionTile extends StatelessWidget {
  final String name;
  final String booklet;
  final int age;

  const ProfileSelectionTile({
    super.key,
    required this.name,
    required this.booklet,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // TODO: handle switch profile logic
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(radius: 24, backgroundColor: AppColours.grey3),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColours.darkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Booklet No: $booklet",
                  style: TextStyle(fontSize: 12, color: AppColours.grey),
                ),
                Text(
                  "Age: $age",
                  style: TextStyle(fontSize: 12, color: AppColours.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
