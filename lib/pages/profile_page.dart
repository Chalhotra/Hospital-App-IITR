import 'package:dummy/bloc/auth_bloc.dart';
import 'package:dummy/bloc/auth_event.dart';
import 'package:dummy/bloc/auth_state.dart';
import 'package:dummy/bloc/patient_bloc.dart';
import 'package:dummy/bloc/patient_event.dart';
import 'package:dummy/bloc/patient_state.dart';
import 'package:dummy/pages/profile_page/widgets/switch_profile_sheet.dart';
import 'package:dummy/pages/profile_page/widgets/logout_confirmation_dialog.dart';
import 'package:dummy/pages/book_appointment_page/book_appointment_page.dart';
import 'package:dummy/pages/login_page.dart';
import 'package:dummy/pages/prescription_page/prescription_page.dart';
import 'package:dummy/pages/test_results_page/test_results_page.dart';
import 'package:dummy/pages/downloaded_files_page/downloaded_files_page.dart';
import 'package:dummy/pages/your_bookings_page.dart';
import 'package:dummy/widgets/app_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dummy/app_colours.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int bottomIndex = 2; // Profile tab selected (index 2 with Status added back)

  // Helper function to convert text to Name Case (Title Case)
  String toNameCase(String text) {
    if (text.isEmpty) return text;
    return text
        .toLowerCase()
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    // Load patient info when profile page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        print("🔍 [PROFILE] Requesting patient info with token");
        context.read<PatientBloc>().add(
          PatientLoadRequested(authState.user.token),
        );
      } else {
        print("⚠️ [PROFILE] User not authenticated");
      }
    });
  }

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

              // Avatar + name section with patient info
              BlocConsumer<PatientBloc, PatientState>(
                listener: (context, patientState) {
                  if (patientState is PatientError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text('Error: ${patientState.message}'),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red.shade700,
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, patientState) {
                  print(
                    "🔍 [PROFILE] Current PatientState: ${patientState.runtimeType}",
                  );

                  if (patientState is PatientLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (patientState is PatientError) {
                    return Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load patient info',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            patientState.message,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColours.textGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              final authState = context.read<AuthBloc>().state;
                              if (authState is AuthAuthenticated) {
                                context.read<PatientBloc>().add(
                                  PatientLoadRequested(authState.user.token),
                                );
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColours.mainColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (patientState is PatientLoaded) {
                    final activeBooklet = patientState.activeBooklet;

                    return Column(
                      children: [
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
                              child: Icon(
                                activeBooklet.gender.toUpperCase() == 'MALE'
                                    ? Icons.person
                                    : Icons.person_outline,
                                size: 45,
                                color: AppColours.textGrey,
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    toNameCase(activeBooklet.fullName),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    // overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Booklet No: ${activeBooklet.bookletNo}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColours.textGrey,
                                    ),
                                  ),
                                  if (activeBooklet.relation != 'SELF')
                                    Text(
                                      "${activeBooklet.relation} of ${toNameCase(activeBooklet.relativeName.trim())}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColours.textGrey,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Bottom sheet button for booklet switching
                            GestureDetector(
                              onTap: () {
                                if (patientState.booklets.length > 1) {
                                  _showBookletSwitchSheet(
                                    context,
                                    patientState,
                                  );
                                }
                              },
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: patientState.booklets.length > 1
                                    ? AppColours.textGrey
                                    : AppColours.textGrey.withOpacity(0.3),
                                size: 28,
                              ),
                            ),
                          ],
                        ),

                        // Additional info cards
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                'Blood Group',
                                activeBooklet.bloodGroup.isNotEmpty
                                    ? activeBooklet.bloodGroup
                                    : 'N/A',
                                Icons.bloodtype,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                'Age',
                                activeBooklet.age.isNotEmpty
                                    ? activeBooklet.age
                                    : 'N/A',
                                Icons.cake,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                'Mobile',
                                activeBooklet.mobileNo.isNotEmpty
                                    ? activeBooklet.mobileNo
                                    : 'N/A',
                                Icons.phone,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }

                  // Fallback to auth state if patient data not loaded
                  return BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      String displayName = "Guest User";
                      String identificationNo = "N/A";

                      if (authState is AuthAuthenticated) {
                        displayName = authState.user.username;
                        identificationNo = authState.user.username;
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "ID: $identificationNo",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColours.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
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

              // Downloaded Files
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DownloadedFilesPage(),
                    ),
                  );
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text("Downloaded Files"),
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
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthUnauthenticated) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) {
                        return LogoutConfirmationDialog(
                          onConfirm: () {
                            Navigator.pop(dialogContext); // Close dialog
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          },
                          onCancel: () {
                            Navigator.pop(dialogContext);
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
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColours.mutedGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColours.borderGrey),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColours.textGrey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColours.textGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookletSwitchSheet(
    BuildContext context,
    PatientLoaded patientState,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColours.borderGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Switch Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Booklet list
            ...patientState.booklets.map((booklet) {
              final isActive =
                  booklet.bookletNo == patientState.activeBooklet.bookletNo;

              return InkWell(
                onTap: () {
                  context.read<PatientBloc>().add(
                    PatientBookletChanged(booklet.bookletNo),
                  );
                  Navigator.pop(modalContext);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColours.mainColor.withOpacity(0.1)
                        : AppColours.mutedGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isActive
                          ? AppColours.mainColor
                          : AppColours.borderGrey,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColours.mutedGrey,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          booklet.gender.toUpperCase() == 'MALE'
                              ? Icons.person
                              : Icons.person_outline,
                          size: 30,
                          color: AppColours.textGrey,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toNameCase(booklet.fullName),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${booklet.bookletNo} • ${booklet.relation}",
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColours.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Checkmark for active
                      if (isActive)
                        const Icon(
                          Icons.check_circle,
                          color: AppColours.mainColor,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 10),
          ],
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
