import 'dart:io';
import 'pdf_data_service.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/company.dart';
import '../models/customer.dart';
import '../models/work_report.dart';

class PdfService {
  static Future<void> preview(int reportId) async {
    final data = await PdfDataService.load(reportId);

    if (data == null) {
      return;
    }

    final company = data.company;
    final customer = data.customer;
    final report = data.report;

    final pdf = pw.Document();

    pw.MemoryImage? logo;

    if (company.logoPath.isNotEmpty && File(company.logoPath).existsSync()) {
      logo = pw.MemoryImage(File(company.logoPath).readAsBytesSync());
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          _buildHeader(company, logo),
          pw.SizedBox(height: 20),

          _sectionTitle("Kunde"),
          _value(customer.name),

          pw.SizedBox(height: 15),

          _sectionTitle("Baustelle"),
          _value(report.constructionSite),

          pw.SizedBox(height: 15),

          _sectionTitle("Datum"),
          _value(DateFormat("dd.MM.yyyy").format(DateTime.parse(report.date))),

          pw.SizedBox(height: 15),

          _sectionTitle("Arbeitszeit"),

          pw.Row(
            children: [
              pw.Expanded(child: _infoBox("Beginn", report.startTime)),

              pw.SizedBox(width: 10),

              pw.Expanded(child: _infoBox("Ende", report.endTime)),

              pw.SizedBox(width: 10),

              pw.Expanded(
                child: _infoBox("Pause", "${report.breakMinutes} Min"),
              ),
            ],
          ),

          pw.SizedBox(height: 20),

          _sectionTitle("Tätigkeit"),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Text(report.activity),
          ),

          pw.SizedBox(height: 40),

          pw.Row(
            children: [
              pw.Expanded(child: _signature("Mitarbeiter")),

              pw.SizedBox(width: 40),

              pw.Expanded(child: _signature("Kunde")),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  static pw.Widget _buildHeader(Company company, pw.MemoryImage? logo) {
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
                "Arbeitsbericht",
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 8),

              pw.Text(company.companyName),

              if (company.contactPerson.isNotEmpty)
                pw.Text(company.contactPerson),

              pw.Text(company.street),

              pw.Text("${company.zipCode} ${company.city}"),

              if (company.phone.isNotEmpty) pw.Text(company.phone),

              if (company.email.isNotEmpty) pw.Text(company.email),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _value(String value) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Text(value),
    );
  }

  static pw.Widget _infoBox(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Column(
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Text(value),
        ],
      ),
    );
  }

  static pw.Widget _signature(String title) {
    return pw.Column(
      children: [
        pw.Container(
          height: 50,
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide()),
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(title),
      ],
    );
  }
}
