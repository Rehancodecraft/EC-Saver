import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/emergency.dart';

class PdfService {
  static Future<void> generateAndPrintPdf({
    required Map<String, List<Emergency>> groupedEmergencies,
    required List<String> selectedMonths,
    required String title,
  }) async {
    final pdf = pw.Document();

    // Add pages for each selected month
    for (final month in selectedMonths) {
      final emergencies = groupedEmergencies[month] ?? [];
      if (emergencies.isEmpty) continue;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Emergency Records Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        month,
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Total Records: ${emergencies.length}',
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.Divider(thickness: 2),
                pw.SizedBox(height: 16),

                // Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(30),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(3),
                  },
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        _buildTableCell('#', isHeader: true),
                        _buildTableCell('EC Number', isHeader: true),
                        _buildTableCell('Date', isHeader: true),
                        _buildTableCell('Type', isHeader: true),
                      ],
                    ),
                    // Data Rows
                    ...emergencies.asMap().entries.map((entry) {
                      final index = entry.key;
                      final emergency = entry.value;
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: index % 2 == 0 ? PdfColors.white : PdfColors.grey100,
                        ),
                        children: [
                          _buildTableCell('${index + 1}'),
                          _buildTableCell(emergency.ecNumber),
                          _buildTableCell(
                            DateFormat('dd MMM yyyy').format(emergency.emergencyDate),
                          ),
                          _buildTableCell(emergency.emergencyType),
                        ],
                      );
                    }).toList(),
                  ],
                ),

                pw.Spacer(),

                // Footer
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Text(
                  'EC Saver - Emergency Cases Saver for Rescue 1122 Pakistan',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );
    }

    // Show print dialog
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'EC_Records_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
