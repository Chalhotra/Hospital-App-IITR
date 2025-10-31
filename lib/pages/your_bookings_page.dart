import 'package:flutter/material.dart';
import 'package:dummy/widgets/app_bottom_nav_bar.dart';
import 'package:dummy/pages/book_appointment_page/book_appointment_page.dart';
import 'package:dummy/pages/profile_page.dart';

class YourBookingsPage extends StatefulWidget {
  const YourBookingsPage({super.key});

  @override
  State<YourBookingsPage> createState() => _YourBookingsPageState();
}

class _YourBookingsPageState extends State<YourBookingsPage> {
  int bottomIndex = 1; // Status tab selected

  void _onNavBarTap(int index) {
    if (index == 0) {
      // Navigate to Book Appointment page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookAppointmentPage()),
      );
    } else if (index == 2) {
      // Navigate to Profile page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else {
      setState(() => bottomIndex = index);
    }
  }

  final List<Map<String, dynamic>> bookings = [
    {
      "doctor": "Doctor Name",
      "status": "Pending",
      "token": null,
      "date": "Sept 26 2025 - 07:39AM",
    },
    {
      "doctor": "Doctor Name",
      "status": "Approved",
      "token": "1234565678",
      "date": "Sept 26 2025 - 07:39AM",
    },
    {
      "doctor": "Doctor Name",
      "status": "Declined due to unavailability",
      "token": null,
      "date": "Sept 26 2025 - 07:39AM",
    },
  ];

  Color statusColor(String status) {
    if (status.toLowerCase().contains("pending")) {
      return const Color(0xFFFFF9E6); // Lighter pastel yellow
    } else if (status.toLowerCase().contains("approved")) {
      return const Color(0xFFE8F5E9); // Lighter pastel green
    } else {
      return const Color(0xFFFFEBEE); // Lighter pastel red
    }
  }

  Color statusBorderColor(String status) {
    if (status.toLowerCase().contains("pending")) {
      return const Color(0xFFFFD54F); // Lighter yellow border
    } else if (status.toLowerCase().contains("approved")) {
      return const Color(0xFF81C784); // Lighter green border
    } else {
      return const Color(0xFFE57373); // Lighter red border
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: bottomIndex,
        onTap: _onNavBarTap,
      ),
      appBar: AppBar(
        title: const Text(
          "Your Bookings",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final booking = bookings[index];

          return Container(
            decoration: BoxDecoration(
              color: statusColor(booking["status"]),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusBorderColor(booking["status"])),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking["doctor"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Status: ${booking["status"]}",
                  style: const TextStyle(fontSize: 14),
                ),
                if (booking["token"] != null)
                  Text(
                    "Allotted Token: ${booking["token"]}",
                    style: const TextStyle(fontSize: 14),
                  ),
                const SizedBox(height: 4),
                Text(
                  booking["date"],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
