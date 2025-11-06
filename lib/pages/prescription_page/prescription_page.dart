import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dummy/app_colours.dart';
import 'package:dummy/bloc/prescription_bloc.dart';
import 'package:dummy/bloc/prescription_event.dart';
import 'package:dummy/bloc/prescription_state.dart';
import 'package:dummy/repositories/auth_repository.dart';
import 'package:dummy/pages/prescription_page/prescription_details_page.dart';
import 'package:dummy/services/pdf_service.dart';
import 'package:open_file/open_file.dart';

class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({super.key});

  @override
  State<PrescriptionsPage> createState() => _PrescriptionsPageState();
}

class _PrescriptionsPageState extends State<PrescriptionsPage> {
  @override
  void initState() {
    super.initState();
    _loadOpdList();
  }

  Future<void> _loadOpdList() async {
    final authRepository = context.read<AuthRepository>();
    final bookletNo = await authRepository.getActiveBookletNo();

    if (bookletNo != null && mounted) {
      context.read<PrescriptionBloc>().add(PrescriptionLoadOpdList(bookletNo));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColours.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        // backgroundColor: AppColours.backgroundLight,
        centerTitle: true,
        title: const Text(
          "Prescriptions",
          style: TextStyle(
            color: AppColours.darkText,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),

      floatingActionButton: BlocBuilder<PrescriptionBloc, PrescriptionState>(
        builder: (context, state) {
          // Only show FAB when OPDs are loaded and not empty
          if (state is PrescriptionOpdListLoaded ||
              state is PrescriptionDetailsLoading ||
              state is PrescriptionDetailsLoaded) {
            final opds = state is PrescriptionOpdListLoaded
                ? state.opds
                : state is PrescriptionDetailsLoading
                ? state.opds
                : (state as PrescriptionDetailsLoaded).opds;

            if (opds.isNotEmpty) {
              return FloatingActionButton.extended(
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
                            Text('Generating PDF summary...'),
                          ],
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // Get active booklet number
                    final authRepository = context.read<AuthRepository>();
                    final bookletNo = await authRepository.getActiveBookletNo();

                    if (bookletNo == null) {
                      throw Exception('No active booklet found');
                    }

                    // Generate summary PDF with all OPDs
                    final filePath =
                        await PdfService.generateAllPrescriptionsSummaryPdf(
                          opds,
                          bookletNo,
                        );

                    // Try to open the PDF automatically
                    try {
                      await OpenFile.open(filePath);
                    } catch (openError) {
                      print('⚠️ Could not auto-open PDF: $openError');
                      // Continue to show success message even if auto-open fails
                    }

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
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 16),
                                  Text('PDF saved and opened!'),
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
                              const Icon(Icons.error, color: Colors.white),
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
                backgroundColor: AppColours.mainColor,
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text(
                  'Download All',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),

      body: SafeArea(
        child: BlocConsumer<PrescriptionBloc, PrescriptionState>(
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
            if (state is PrescriptionOpdListLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PrescriptionOpdListLoaded ||
                state is PrescriptionDetailsLoading ||
                state is PrescriptionDetailsLoaded) {
              final opds = state is PrescriptionOpdListLoaded
                  ? state.opds
                  : state is PrescriptionDetailsLoading
                  ? state.opds
                  : (state as PrescriptionDetailsLoaded).opds;

              if (opds.isEmpty) {
                return const Center(
                  child: Text(
                    'No prescriptions found',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: opds.length,
                      itemBuilder: (context, index) {
                        final opd = opds[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: _PrescriptionCard(
                            doctorName: opd.doctorCode,
                            opdId: opd.opdid.toString(),
                            opdDate: opd.opdDate,
                            diagnosis: opd.diagnosis,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PrescriptionDetailsPage(opdId: opd.opdid),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              );
            }

            return const Center(
              child: Text(
                'Loading prescriptions...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PrescriptionCard extends StatelessWidget {
  final String doctorName;
  final String opdId;
  final String opdDate;
  final String diagnosis;
  final VoidCallback onTap;

  const _PrescriptionCard({
    required this.doctorName,
    required this.opdId,
    required this.opdDate,
    required this.diagnosis,
    required this.onTap,
  });

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd yyyy - hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dr. $doctorName",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColours.darkText,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "OPD ID: $opdId",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(opdDate),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (diagnosis.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      "Diagnosis: $diagnosis",
                      style: const TextStyle(
                        color: AppColours.mainColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
