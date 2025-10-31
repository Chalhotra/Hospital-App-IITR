import 'package:flutter/material.dart';
import 'package:dummy/app_colours.dart';
import 'package:dummy/widgets/app_bottom_nav_bar.dart';
import 'package:dummy/pages/profile_page/profile_page.dart';
import 'package:dummy/pages/your_bookings_page.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final TextEditingController titleController = TextEditingController();

  String selectedPatient = "Rakesh Kumar";
  String selectedShift = "Evening";
  String selectedDoctor = "Dr. Sharma";

  List<String> patients = [
    "Rakesh Kumar",
    "Ankit Sharma",
    "Ritu Jain",
    "Amit Verma",
  ];

  List<String> shifts = ["Morning", "Afternoon", "Evening", "Night"];

  List<String> doctors = ["Dr. Sharma", "Dr. Patel", "Dr. Singh", "Dr. Gupta"];

  int bottomIndex = 0;

  void _onNavBarTap(int index) {
    if (index == 1) {
      // Navigate to Status page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const YourBookingsPage()),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 26),
              const Center(
                child: Text(
                  "Book Appointment",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 26),
              const Center(
                child: Text(
                  "Request For Appointment",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  "This will send a request to hospital\nstaff which you can track.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 28),

              // Date
              const Text("Date", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColours.mainColor,
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColours.mainColor,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    setState(() {
                      titleController.text =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: "Select a date",
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(Icons.calendar_today, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColours.borderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: AppColours.mainColor,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Patient Booklet
              const Text(
                "Select Patient Booklet",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColours.borderGrey),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value: selectedPatient,
                    isExpanded: true,
                    items: patients.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (v) => setState(() => selectedPatient = v!),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Doctor
              const Text(
                "Select Doctor",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColours.borderGrey),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value: selectedDoctor,
                    isExpanded: true,
                    items: doctors.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (v) => setState(() => selectedDoctor = v!),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Shift
              const Text(
                "Select Shift",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColours.borderGrey),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                    value: selectedShift,
                    isExpanded: true,
                    items: shifts.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),
                    onChanged: (v) => setState(() => selectedShift = v!),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // REQUEST BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColours.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Request Appointment",
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
