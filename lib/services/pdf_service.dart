import 'dart:io';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../localization/app_language.dart';
import '../models/company.dart';
import '../models/customer.dart';
import '../models/work_report.dart';
import 'pdf_data_service.dart';

class PdfService {
  static Future<pw.Document> _buildPdf(PdfData data) async {
    final t = AppLanguage.instance.strings;

    final Company company = data.company;
    final Customer customer = data.customer;
    final WorkReport report = data.report;

    final pdf = pw.Document();

    pw.MemoryImage? logo;

    if (company.logoPath.isNotEmpty && File(company.logoPath).existsSync()) {
      logo = pw.MemoryImage(File(company.logoPath).readAsBytesSync());
    }

    return pdf;
  }

  static Future<void> sharePdf(int reportId) async {
    // TODO: Nach dem Umbau auf _buildPdf() wird hier Share.shareXFiles(...)
    // verwendet. Bis dahin verwenden wir dieselbe Logik wie die Vorschau.
    await preview(reportId);
  }

  static Future<void> preview(int reportId) async {
    final data = await PdfDataService.load(reportId);

    if (data == null) return;

    final t = AppLanguage.instance.strings;

    final Company company = data.company;
    final Customer customer = data.customer;
    final WorkReport report = data.report;

    final pdf = pw.Document();

    pw.MemoryImage? logo;

    if (company.logoPath.isNotEmpty && File(company.logoPath).existsSync()) {
      logo = pw.MemoryImage(File(company.logoPath).readAsBytesSync());
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        build: (context) => [
          _buildHeader(company, logo, t),

          pw.SizedBox(height: 25),

          _divider(),

          pw.SizedBox(height: 15),

          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(child: _dataField(t.customer, customer.name)),
              pw.SizedBox(width: 15),
              pw.Expanded(
                child: _dataField(
                  t.date,
                  DateFormat("dd.MM.yyyy").format(DateTime.parse(report.date)),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 15),

          _dataField(t.constructionSite, report.constructionSite),

          pw.SizedBox(height: 22),

          _sectionTitle(t.workingTime),

          pw.SizedBox(height: 10),

          pw.Row(
            children: [
              pw.Expanded(child: _infoBox(t.start, report.startTime)),
              pw.SizedBox(width: 10),
              pw.Expanded(child: _infoBox(t.end, report.endTime)),
              pw.SizedBox(width: 10),
              pw.Expanded(
                child: _infoBox(t.breakTime, "${report.breakMinutes} Min."),
              ),
              pw.SizedBox(width: 10),
              pw.Expanded(child: _infoBox(t.total, _workingTime(report))),
            ],
          ),

          pw.SizedBox(height: 25),

          _sectionTitle(t.activity),

          pw.SizedBox(height: 10),

          pw.Container(
            width: double.infinity,
            constraints: const pw.BoxConstraints(minHeight: 180),
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              report.activity,
              style: const pw.TextStyle(fontSize: 11, lineSpacing: 4),
            ),
          ),

          pw.SizedBox(height: 25),

          _sectionTitle(t.materials),

          pw.SizedBox(height: 10),

          pw.Container(
            width: double.infinity,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey600),
            ),
            child: pw.Column(
              children: [
                // Tabellenkopf
                pw.Container(
                  color: PdfColors.grey300,
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          t.quantity,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          t.unit,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.Expanded(
                        flex: 6,
                        child: pw.Text(
                          t.materials,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                if (data.materials.isEmpty)
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      t.noMaterials,
                      style: const pw.TextStyle(color: PdfColors.grey700),
                    ),
                  )
                else
                  ...data.materials.map((entry) {
                    final material = data.materialCatalog[entry.materialId];

                    return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(color: PdfColors.grey300),
                        ),
                      ),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              entry.quantity % 1 == 0
                                  ? entry.quantity.toInt().toString()
                                  : entry.quantity.toString().replaceAll(
                                      ".",
                                      ",",
                                    ),
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(material?.unit ?? ""),
                          ),
                          pw.Expanded(
                            flex: 6,
                            child: pw.Text(material?.name ?? "-"),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),

          pw.SizedBox(height: 30),

          _divider(),

          pw.SizedBox(height: 20),

          pw.Row(
            children: [
              pw.Expanded(child: _signature(t.employeeSignature)),
              pw.SizedBox(width: 40),
              pw.Expanded(child: _signature(t.customerSignature)),
            ],
          ),

          pw.SizedBox(height: 25),

          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              t.createdWith,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );
    final file = await _savePdf(pdf, "Arbeitsbericht.pdf");

    await Printing.layoutPdf(onLayout: (_) async => await file.readAsBytes());
  }

  static String _workingTime(WorkReport report) {
    final start = report.startTime.split(":");
    final end = report.endTime.split(":");

    final startMinutes = int.parse(start[0]) * 60 + int.parse(start[1]);

    final endMinutes = int.parse(end[0]) * 60 + int.parse(end[1]);

    final total = (endMinutes - startMinutes - report.breakMinutes).clamp(
      0,
      24 * 60,
    );

    final hours = total ~/ 60;
    final minutes = total % 60;

    return "$hours Std. ${minutes.toString().padLeft(2, "0")} Min.";
  }

  static Future<File> _savePdf(pw.Document pdf, String fileName) async {
    final directory = await getTemporaryDirectory();

    final file = File("${directory.path}/$fileName");

    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _buildHeader(
    Company company,
    pw.MemoryImage? logo,
    dynamic t,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (logo != null)
          pw.Container(width: 90, height: 90, child: pw.Image(logo)),

        if (logo != null) pw.SizedBox(width: 20),

        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                company.companyName,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              if (company.contactPerson.isNotEmpty)
                pw.Text(company.contactPerson),

              pw.Text(company.street),

              pw.Text("${company.zipCode} ${company.city}"),

              if (company.phone.isNotEmpty) pw.Text("Tel.: ${company.phone}"),

              if (company.mobile.isNotEmpty)
                pw.Text("Mobil: ${company.mobile}"),

              if (company.email.isNotEmpty) pw.Text(company.email),

              if (company.website.isNotEmpty) pw.Text(company.website),
            ],
          ),
        ),

        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              t.pdfTitle,
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 6),

            pw.Text(DateFormat("dd.MM.yyyy").format(DateTime.now())),
          ],
        ),
      ],
    );
  }

  static pw.Widget _divider() {
    return pw.Container(height: 1, color: PdfColors.grey500);
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
    );
  }

  static pw.Widget _dataField(String title, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        ),

        pw.SizedBox(height: 5),

        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey600),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(value),
        ),
      ],
    );
  }

  static pw.Widget _infoBox(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey600),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),

          pw.SizedBox(height: 8),

          pw.Text(value, textAlign: pw.TextAlign.center),
        ],
      ),
    );
  }

  static pw.Widget _signature(String title) {
    return pw.Column(
      children: [
        pw.Container(height: 55),

        pw.Container(height: 1, color: PdfColors.black),

        pw.SizedBox(height: 5),

        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ],
    );
  }
}
