import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dummy/app_colours.dart';
import 'package:dummy/bloc/prescription_bloc.dart';
import 'package:dummy/bloc/prescription_event.dart';
import 'package:dummy/bloc/prescription_state.dart';
import 'package:dummy/services/pdf_service.dart';

class PrescriptionDetailsPage extends StatefulWidget {
  final int opdId;

  const PrescriptionDetailsPage({super.key, required this.opdId});

  @override
  State<PrescriptionDetailsPage> createState() =>
      _PrescriptionDetailsPageState();
}

class _PrescriptionDetailsPageState extends State<PrescriptionDetailsPage> {
  @override
  void initState() {
    super.initState();
    // Load prescription details when page opens
    context.read<PrescriptionBloc>().add(PrescriptionLoadDetails(widget.opdId));
  }

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

      body: BlocConsumer<PrescriptionBloc, PrescriptionState>(
        listener: (context, state) {
          if (state is PrescriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PrescriptionDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PrescriptionDetailsLoaded) {
            final prescriptions = state.prescriptions;

            if (prescriptions.isEmpty) {
              return const Center(
                child: Text(
                  'No prescriptions found for this appointment',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            // Get OPD details from the first prescription
            final opdInfo = prescriptions.first.opd;

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        Text(
                          "Dr. ${opdInfo.doctorCode}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColours.darkText,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Text(
                          "OPD ID: ${opdInfo.opdid}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 2),

                        Text(
                          _formatDate(opdInfo.opdDate),
                          style: const TextStyle(color: Colors.grey),
                        ),

                        if (opdInfo.diagnosis.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Diagnosis: ${opdInfo.diagnosis}",
                            style: const TextStyle(
                              color: AppColours.mainColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],

                        if (opdInfo.complaints.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            "Complaints: ${opdInfo.complaints}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],

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

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: prescriptions.length,
                          itemBuilder: (context, index) {
                            final prescription = prescriptions[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: _DrugCard(
                                drugName: prescription.drugName,
                                drugSalt: prescription.drugSalt,
                                drugType: prescription.drugType,
                                dosage: prescription.dossage,
                                remark: prescription.remark,
                                qty: prescription.qty,
                                issuedBy: prescription.issuedBy,
                                issuedOn: prescription.issuedOn,
                              ),
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
                    child: ElevatedButton.icon(
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
                      onPressed: () async {
                        try {
                          // Show loading indicator
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Text('Generating PDF...'),
                                ],
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );

                          // Generate PDF
                          final filePath =
                              await PdfService.generatePrescriptionPdf(
                                prescriptions,
                                opdInfo,
                              );

                          // Show success message with file location
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 16),
                                        Text('PDF saved successfully!'),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Saved to: $filePath',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        } catch (e) {
                          // Log the error
                          print('❌ PDF Generation Error: $e');

                          // Show error message
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.error,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text('Failed to generate PDF: $e'),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.download, color: Colors.white),
                      label: const Text(
                        "Download",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text(
              'Loading prescription details...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd yyyy - hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

class _DrugCard extends StatelessWidget {
  final String drugName;
  final String drugSalt;
  final String drugType;
  final String dosage;
  final String remark;
  final int qty;
  final String issuedBy;
  final String issuedOn;

  const _DrugCard({
    required this.drugName,
    required this.drugSalt,
    required this.drugType,
    required this.dosage,
    required this.remark,
    required this.qty,
    required this.issuedBy,
    required this.issuedOn,
  });

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
          Text(
            drugName,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColours.darkText,
            ),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              _Tag(label: "Type: $drugType"),
              const SizedBox(width: 6),
              _Tag(label: "Qty: ${qty.toString().padLeft(2, '0')}"),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            drugSalt,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          Text(
            "Dosage: $dosage",
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          if (remark.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              "Remark: $remark",
              style: const TextStyle(
                fontSize: 13,
                color: AppColours.mainColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            "Issued by: $issuedBy",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
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
