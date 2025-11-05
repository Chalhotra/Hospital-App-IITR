import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/prescription.dart';
import '../models/opd.dart';

class PdfService {
  /// Generates a prescription PDF and saves it to device storage
  /// Returns the file path where the PDF was saved
  static Future<String> generatePrescriptionPdf(
    List<Prescription> prescriptions,
    Opd opdInfo,
  ) async {
    try {
      print('📄 Starting PDF generation...');
      final pdf = pw.Document();

      // Add page with prescription content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) => [
            // Header
            _buildHeader(opdInfo),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 20),

            // Patient & OPD Information
            _buildPatientInfo(opdInfo),
            pw.SizedBox(height: 25),

            // Prescribed Medications Title
            pw.Text(
              'PRESCRIBED MEDICATIONS',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.red800,
              ),
            ),
            pw.SizedBox(height: 15),

            // Medications List
            ..._buildMedicationsList(prescriptions),

            pw.SizedBox(height: 30),

            // Footer
            _buildFooter(
              prescriptions.first.issuedBy,
              prescriptions.first.issuedOn,
            ),
          ],
        ),
      );

      print('📄 PDF document created, attempting to save...');

      // Save the PDF
      final pdfBytes = await pdf.save();
      print('📄 PDF bytes generated: ${pdfBytes.length} bytes');

      // Get the appropriate directory
      Directory? directory;
      if (Platform.isAndroid) {
        // Use app-specific external storage directory (doesn't require permissions)
        directory = await getExternalStorageDirectory();

        // Create a Downloads subfolder in app directory
        if (directory != null) {
          final downloadsDir = Directory('${directory.path}/Prescriptions');
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          directory = downloadsDir;
        }

        print('📁 Using directory: ${directory?.path}');
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'prescription_${opdInfo.opdid}_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');

      print('📄 Saving to: ${file.path}');

      // Write the file
      await file.writeAsBytes(pdfBytes);

      print('✅ PDF saved successfully to: ${file.path}');

      // Return the file path so we can show it to the user
      return file.path;
    } catch (e, stackTrace) {
      print('❌ Error in PDF generation: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Header section with hospital name
  static pw.Widget _buildHeader(Opd opdInfo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                'IITR HOSPITAL',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red800,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Medical Prescription',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Patient and OPD information section
  static pw.Widget _buildPatientInfo(Opd opdInfo) {
    final formattedDate = _formatDate(opdInfo.opdDate);

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: _buildInfoRow('Patient Name', opdInfo.patientName),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(
                child: _buildInfoRow('OPD ID', opdInfo.opdid.toString()),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: _buildInfoRow('Doctor', 'Dr. ${opdInfo.doctorCode}'),
              ),
              pw.SizedBox(width: 20),
              pw.Expanded(child: _buildInfoRow('Date & Time', formattedDate)),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(child: _buildInfoRow('Age', opdInfo.age)),
              pw.SizedBox(width: 20),
              pw.Expanded(child: _buildInfoRow('Gender', opdInfo.gender)),
            ],
          ),
          if (opdInfo.diagnosis.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            _buildInfoRow('Diagnosis', opdInfo.diagnosis),
          ],
          if (opdInfo.complaints.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            _buildInfoRow('Complaints', opdInfo.complaints),
          ],
        ],
      ),
    );
  }

  /// Helper to build info row
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey600,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 11, color: PdfColors.black),
        ),
      ],
    );
  }

  /// Build medications list
  static List<pw.Widget> _buildMedicationsList(
    List<Prescription> prescriptions,
  ) {
    return prescriptions.asMap().entries.map((entry) {
      final index = entry.key;
      final prescription = entry.value;

      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 12),
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Medication number and name
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    '${index + 1}. ${prescription.drugName}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    prescription.drugType,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red800,
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 6),

            // Salt composition
            pw.Text(
              prescription.drugSalt,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
            pw.SizedBox(height: 8),

            // Dosage and quantity
            pw.Row(
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Dosage:',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        prescription.dossage,
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 15),
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Quantity:',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        prescription.qty.toString(),
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Remarks if present
            if (prescription.remark.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red50,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Row(
                  children: [
                    pw.Text('⚠ ', style: const pw.TextStyle(fontSize: 10)),
                    pw.Expanded(
                      child: pw.Text(
                        prescription.remark,
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.red900,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }).toList();
  }

  /// Footer section
  static pw.Widget _buildFooter(String issuedBy, String issuedOn) {
    final formattedDate = _formatDate(issuedOn);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Issued By:',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
                pw.Text(
                  issuedBy,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Issued On:',
                  style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
                pw.Text(
                  formattedDate,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Center(
          child: pw.Text(
            'This is a computer-generated prescription',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey500,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  /// Format date string
  static String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
