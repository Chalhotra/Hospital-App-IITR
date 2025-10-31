import 'package:flutter/material.dart';
import 'package:dummy/app_colours.dart';

class PrescriptionDetailsPage extends StatelessWidget {
  final String opdId;

  const PrescriptionDetailsPage({super.key, required this.opdId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Prescription",
          style: TextStyle(
            color: AppColours.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  const Text(
                    "Doctor Name",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColours.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "OPDID: $opdId",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 2),

                  const Text(
                    "Sept 26 2025 - 07:39AM",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "Prescribed Drugs",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColours.darkText,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==== Multiple drug cards ====
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: const _DrugCard(),
                      );
                    },
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ===== Floating Download Button =====
          Positioned(
            bottom: 20,
            right: 20,
            child: SafeArea(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColours.mainColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Download",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrugCard extends StatelessWidget {
  const _DrugCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rabez - D",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColours.darkText,
            ),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              _Tag(label: "Type: CAP"),
              const SizedBox(width: 6),
              _Tag(label: "Qty: 05"),
            ],
          ),

          const SizedBox(height: 8),

          const Text(
            "Raberprazole 20 MG + Domperidone30",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          const Text(
            "Dosage: OD-1 (MORNING)",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Small red capsule tags
class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColours.mainColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColours.mainColor,
        ),
      ),
    );
  }
}
