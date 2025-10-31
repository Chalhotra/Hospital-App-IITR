import 'package:flutter/material.dart';
import 'package:dummy/pages/test_results_page/test_results_details_page.dart';

class TestResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> tests = [
    {
      "lab": "Test Center Name",
      "reportId": "RPID: 987654",
      "date": "Sept 27 2025 - 08:15AM",
    },
    {
      "lab": "Test Center Name",
      "reportId": "RPID: 123123",
      "date": "Sept 26 2025 - 03:20PM",
    },
    {
      "lab": "Test Center Name",
      "reportId": "RPID: 555678",
      "date": "Sept 25 2025 - 10:00AM",
    },
  ];

  TestResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Test Results",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tests.length,
        itemBuilder: (_, index) {
          final test = tests[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffE1E1E1)),
            ),
            child: ListTile(
              title: Text(
                test["lab"],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(test["reportId"]),
                  const SizedBox(height: 2),
                  Text(
                    test["date"],
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Extract RPID from "RPID: 987654" format
                String rpid = test["reportId"].toString().replaceAll(
                  "RPID: ",
                  "",
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TestResultDetailPage(
                      labName: test["lab"],
                      reportId: rpid,
                      date: test["date"],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      floatingActionButton: SizedBox(
        width: 140,
        height: 45,
        child: FloatingActionButton.extended(
          onPressed: () {
            // TODO: implement download all
          },
          label: const Text(
            "Download All",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFD67171), // linkRed
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
