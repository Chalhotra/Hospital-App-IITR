import 'package:flutter/material.dart';

class TestResultDetailPage extends StatelessWidget {
  final String labName;
  final String reportId;
  final String date;

  const TestResultDetailPage({
    super.key,
    required this.labName,
    required this.reportId,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> parameters = [
      {
        "name": "Hemoglobin",
        "value": "15.2 g/dL",
        "refRange": "13.0 - 17.0",
        "flag": "Normal",
      },
      {
        "name": "WBC Count",
        "value": "11,500 /µL",
        "refRange": "4,000 - 11,000",
        "flag": "High",
      },
      {
        "name": "Platelets",
        "value": "210,000 /µL",
        "refRange": "150,000 - 400,000",
        "flag": "Normal",
      },
    ];

    Color flagColor(flag) {
      if (flag == "High" || flag == "Low") return Colors.red.shade200;
      return Colors.green.shade200;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Test Result",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("RPID: $reportId"),
            Text(date),
            const SizedBox(height: 22),

            const Text(
              "Test Parameters",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 14),

            ...parameters.map((e) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffE1E1E1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e["name"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Value: ${e["value"]}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Ref: ${e["refRange"]}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: flagColor(e["flag"]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Status: ${e["flag"]}",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),

      floatingActionButton: SizedBox(
        width: 130,
        height: 45,
        child: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Download report logic
          },
          label: const Text("Download", style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFD67171),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
