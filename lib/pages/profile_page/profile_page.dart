import 'package:dummy/pages/profile_page/widgets/switch_profile_sheet.dart';
import 'package:dummy/pages/profile_page/widgets/logout_confirmation_dialog.dart';
import 'package:dummy/pages/book_appointment_page/book_appointment_page.dart';
import 'package:dummy/pages/login_page.dart';
import 'package:dummy/pages/prescription_page/prescription_page.dart';
import 'package:dummy/pages/test_results_page/test_results_page.dart';
import 'package:dummy/pages/your_bookings_page.dart';
import 'package:dummy/widgets/app_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:dummy/app_colours.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int bottomIndex = 2; // Profile tab selected (index 2 with Status added back)

  void _onNavBarTap(int index) {
    if (index == 0) {
      // Navigate to Book Appointment page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BookAppointmentPage()),
      );
    } else if (index == 1) {
      // Navigate to Status page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const YourBookingsPage()),
      );
    } else {
      setState(() => bottomIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: bottomIndex,
        onTap: _onNavBarTap,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "Profile",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 30),

              // Avatar + name section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      color: AppColours.mutedGrey,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 45,
                      color: AppColours.textGrey,
                    ),
                  ),

                  const SizedBox(width: 18),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Rakesh Kumar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Booklet No: 12334567",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColours.textGrey,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  GestureDetector(
                    onTap: () => showSwitchProfileSheet(context),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColours.textGrey,
                      size: 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              Divider(color: AppColours.borderGrey),

              // Test Results
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TestResultsPage()),
                  );
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text("Test Results"),
                trailing: const Icon(Icons.chevron_right),
              ),

              Divider(color: AppColours.borderGrey),

              // Prescriptions
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrescriptionsPage(),
                    ),
                  );
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text("Prescriptions"),
                trailing: const Icon(Icons.chevron_right),
              ),

              Divider(color: AppColours.borderGrey),

              const SizedBox(height: 40),

              // Download EHR button
              SizedBox(
                width: 180,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColours.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Download Full EHR",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Logout button
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return LogoutConfirmationDialog(
                        onConfirm: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        onCancel: () {
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
                style: TextButton.styleFrom(
                  splashFactory: InkRipple.splashFactory,
                  overlayColor: AppColours.mainColor.withOpacity(0.1),
                ),
                child: Text(
                  "Logout",
                  style: TextStyle(
                    color: AppColours.linkRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

void showSwitchProfileSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    builder: (_) => const SwitchProfileSheet(),
  );
}
