import 'package:flutter/material.dart';
import 'package:dummy/app_colours.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: AppColours.mainColor,
      unselectedItemColor: AppColours.bottomIconGrey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.book_online_rounded),
          label: "Book",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pending_actions),
          label: "Status",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}
