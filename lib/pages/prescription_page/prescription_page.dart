import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:dummy/app_colours.dart';
import 'package:dummy/bloc/prescription_bloc.dart';
import 'package:dummy/bloc/prescription_event.dart';
import 'package:dummy/bloc/prescription_state.dart';
import 'package:dummy/repositories/auth_repository.dart';
import 'package:dummy/repositories/prescription_repository.dart';
import 'package:dummy/pages/prescription_page/prescription_details_page.dart';
import 'package:dummy/services/pdf_service.dart';
import 'package:dummy/models/opd.dart';

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

                    const SizedBox(height: 10),

                    // Download All Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                        width: 150,
                        height: 45,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColours.mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _downloadAllPrescriptions(opds),
                          icon: const Icon(Icons.download, color: Colors.white, size: 18),
                          label: const Text(
                            "Download All",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
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

  Future<void> _downloadAllPrescriptions(List<Opd> opds) async {
    if (opds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No prescriptions to download'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Downloading ${opds.length} prescription(s)...'),
            ],
          ),
        );
      },
    );

    try {
      final authRepository = context.read<AuthRepository>();
      final prescriptionRepository = PrescriptionRepository();
      final user = await authRepository.getSavedUser();

      if (user == null || user.isTokenExpired) {
        throw Exception('Authentication required. Please login again.');
      }

      int successCount = 0;
      int failCount = 0;
      final List<String> savedPaths = [];

      // Download each prescription
      for (final opd in opds) {
        try {
          print('📥 Downloading prescription for OPD ID: ${opd.opdid}');
          
          // Fetch prescription details
          final prescriptions = await prescriptionRepository.getPrescriptionsByOpdId(
            user.token,
            opd.opdid,
          );

          if (prescriptions.isEmpty) {
            print('⚠️ No prescription found for OPD ID: ${opd.opdid}');
            failCount++;
            continue;
          }

          // Generate PDF
          final filePath = await PdfService.generatePrescriptionPdf(
            prescriptions,
            opd,
          );
          
          savedPaths.add(filePath);
          successCount++;
          print('✅ Downloaded prescription ${successCount}/${opds.length}');
        } catch (e) {
          print('❌ Error downloading prescription for OPD ${opd.opdid}: $e');
          failCount++;
        }
      }

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show result
        String message;
        Color backgroundColor;

        if (successCount == opds.length) {
          message = '✅ Successfully downloaded all $successCount prescription(s)!';
          backgroundColor = Colors.green;
        } else if (successCount > 0) {
          message = '⚠️ Downloaded $successCount of ${opds.length} prescription(s). $failCount failed.';
          backgroundColor = Colors.orange;
        } else {
          message = '❌ Failed to download any prescriptions';
          backgroundColor = Colors.red;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                if (savedPaths.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Files saved to:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    savedPaths.first.substring(0, savedPaths.first.lastIndexOf('/')),
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ],
            ),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('❌ Error in download all: $e');
      
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download prescriptions: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
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
