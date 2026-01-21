import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/emergency.dart';
import '../models/off_day.dart';
import '../models/user_profile.dart';

class PdfService {
  static Future<void> generateAndPrintPdf({
    required Map<String, List<Emergency>> groupedEmergencies,
    required List<String> selectedMonths,
    required String title,
    UserProfile? userProfile,
    Map<String, List<OffDay>>? groupedOffDays,
  }) async {
    final pdf = pw.Document();

    // Add pages for each selected month
    for (final month in selectedMonths) {
      final emergencies = groupedEmergencies[month] ?? [];
      final offDays = groupedOffDays?[month] ?? [];
      // Include page if there are emergencies OR off days
      if (emergencies.isEmpty && offDays.isEmpty) continue;

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
                      pw.SizedBox(height: 12),
                      
                      // User Information Section
                      if (userProfile != null) ...[
                        pw.Container(
                          padding: const pw.EdgeInsets.all(12),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Rescuer Information',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey800,
                                ),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow('Name:', userProfile.fullName),
                                        _buildInfoRow('Designation:', userProfile.designation),
                                        _buildInfoRow('Phone:', userProfile.mobileNumber),
                                      ],
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow('District:', userProfile.district),
                                        _buildInfoRow('Tehsil:', userProfile.tehsil),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 12),
                      ],
                      
                      pw.Text(
                        month,
                        style: const pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      if (emergencies.isNotEmpty)
                        pw.Text(
                          'Total Emergency Records: ${emergencies.length}',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
                      if (offDays.isNotEmpty)
                        pw.Text(
                          'Total Off Days: ${offDays.length}',
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

                // Emergency Records Table
                if (emergencies.isNotEmpty) ...[
                  pw.Text(
                    'Emergency Records',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
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
                      }),
                    ],
                  ),
                ],

                // Off Days Section
                if (offDays.isNotEmpty) ...[
                  if (emergencies.isNotEmpty) ...[
                    pw.SizedBox(height: 20),
                    pw.Divider(thickness: 1),
                  ],
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Off Days, Leaves & Gazetted Holidays',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(3),
                    },
                    children: [
                      // Header Row
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          _buildTableCell('Date', isHeader: true),
                          _buildTableCell('Type', isHeader: true),
                        ],
                      ),
                      // Data Rows
                      ...offDays.map((offDay) {
                        String offDayType = 'Off Day';
                        if (offDay.notes != null) {
                          if (offDay.notes!.startsWith('Leave')) {
                            offDayType = 'Leave';
                          } else if (offDay.notes!.startsWith('Gazetted Holiday')) {
                            offDayType = 'Gazetted Holiday';
                          } else if (offDay.notes!.startsWith('Day-off')) {
                            offDayType = 'Day-off';
                          }
                        }
                        return pw.TableRow(
                          children: [
                            _buildTableCell(
                              DateFormat('dd MMM yyyy').format(offDay.offDate),
                            ),
                            _buildTableCell(offDayType),
                          ],
                        );
                      }),
                    ],
                  ),
                ],

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

  /// Quick print: saves PDF to Downloads folder automatically
  static Future<String> quickPrintAndSave({
    required Map<String, List<Emergency>> groupedEmergencies,
    required List<String> selectedMonths,
    required String title,
    UserProfile? userProfile,
    Map<String, List<OffDay>>? groupedOffDays,
  }) async {
    final pdf = pw.Document();

    // Add pages for each selected month (same logic as generateAndPrintPdf)
    for (final month in selectedMonths) {
      final emergencies = groupedEmergencies[month] ?? [];
      final offDays = groupedOffDays?[month] ?? [];
      if (emergencies.isEmpty && offDays.isEmpty) continue;

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
                      pw.SizedBox(height: 12),
                      
                      // User Information Section
                      if (userProfile != null) ..[
                        pw.Container(
                          padding: const pw.EdgeInsets.all(12),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Rescuer Information',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey800,
                                ),
                              ),
                              pw.SizedBox(height: 8),
                              pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow('Name:', userProfile.fullName),
                                        _buildInfoRow('Designation:', userProfile.designation),
                                        _buildInfoRow('Phone:', userProfile.mobileNumber),
                                      ],
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow('District:', userProfile.district),
                                        _buildInfoRow('Tehsil:', userProfile.tehsil),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 12),
                      ],
                      
                      pw.Text(
                        month,
                        style: const pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      if (emergencies.isNotEmpty)
                        pw.Text(
                          'Total Emergency Records: ${emergencies.length}',
                          style: const pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey600,
                          ),
                        ),
                      if (offDays.isNotEmpty)
                        pw.Text(
                          'Total Off Days: ${offDays.length}',
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

                // Emergency Records Table
                if (emergencies.isNotEmpty) ...[
                  pw.Text(
                    'Emergency Records',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
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
                      }),
                    ],
                  ),
                ],

                // Off Days Section
                if (offDays.isNotEmpty) ...[
                  if (emergencies.isNotEmpty) ...[
                    pw.SizedBox(height: 20),
                    pw.Divider(thickness: 1),
                  ],
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'Off Days, Leaves & Gazetted Holidays',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey400),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2),
                      1: const pw.FlexColumnWidth(3),
                    },
                    children: [
                      // Header Row
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          _buildTableCell('Date', isHeader: true),
                          _buildTableCell('Type', isHeader: true),
                        ],
                      ),
                      // Data Rows
                      ...offDays.map((offDay) {
                        String offDayType = 'Off Day';
                        if (offDay.notes != null) {
                          if (offDay.notes!.startsWith('Leave')) {
                            offDayType = 'Leave';
                          } else if (offDay.notes!.startsWith('Gazetted Holiday')) {
                            offDayType = 'Gazetted Holiday';
                          } else if (offDay.notes!.startsWith('Day-off')) {
                            offDayType = 'Day-off';
                          }
                        }
                        return pw.TableRow(
                          children: [
                            _buildTableCell(
                              DateFormat('dd MMM yyyy').format(offDay.offDate),
                            ),
                            _buildTableCell(offDayType),
                          ],
                        );
                      }),
                    ],
                  ),
                ],

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

    // Save PDF to Downloads folder
    final bytes = await pdf.save();
    final dir = Directory('/storage/emulated/0/Download');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    final fileName = 'EC_Records_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    
    return file.path;
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

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
