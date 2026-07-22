import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'pdf_data_service.dart';
import '../models/company.dart';

class PdfService {
  static const List<String> _weekdayLabels = [
    "Mo",
    "Di",
    "Mi",
    "Do",
    "Fr",
    "Sa",
    "So",
  ];

  /// Öffnet die native Druckvorschau (inkl. "Als PDF sichern" / Drucker-Auswahl).
  static Future<void> preview(int reportId) async {
    await Printing.layoutPdf(
      onLayout: (format) => generate(reportId),
    );
  }

  /// Öffnet das native Teilen-Menü (Mail, WhatsApp, Dateien, ...).
  static Future<void> share(int reportId) async {
    final bytes = await generate(reportId);

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'arbeitsbericht.pdf',
    );
  }

  static Future<Uint8List> generate(int reportId) async {
    final data = await PdfDataService.load(reportId);

    if (data == null) {
      throw Exception("Bericht konnte nicht geladen werden.");
    }

    final pdf = pw.Document();

    pw.MemoryImage? logo;

    if (data.company.logoPath.isNotEmpty &&
        File(data.company.logoPath).existsSync()) {
      logo = pw.MemoryImage(File(data.company.logoPath).readAsBytesSync());
    }

    if (data.report.isWeekReport) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (context) => _weekContent(data, logo),
        ),
      );
    } else {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (context) => _dayContent(data, logo),
        ),
      );
    }

    return pdf.save();
  }

  static List<pw.Widget> _dayContent(PdfData data, pw.MemoryImage? logo) {
    final company = data.company;
    final customer = data.customer;
    final report = data.report;

    return [
      _buildHeader(company, logo, "Arbeitsbericht"),
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
    ];
  }

  static List<pw.Widget> _weekContent(PdfData data, pw.MemoryImage? logo) {
    final company = data.company;
    final customer = data.customer;
    final report = data.report;
    final weekStart = DateTime.parse(report.date);

    final byWeekday = {
      for (final d in data.days) d.weekday: d,
    };

    double totalHours = 0;

    final rows = List<pw.TableRow>.generate(7, (index) {
      final weekday = index + 1;
      final date = weekStart.add(Duration(days: index));
      final day = byWeekday[weekday];

      final hasEntry = day != null && day.isFilled;
      final hours = hasEntry ? day.hours : 0.0;
      totalHours += hours;

      return pw.TableRow(
        children: [
          _cell(_weekdayLabels[index]),
          _cell(DateFormat("dd.MM.").format(date)),
          _cell(hasEntry ? day.startTime : "-"),
          _cell(hasEntry ? day.endTime : "-"),
          _cell(hasEntry ? "${day.breakMinutes} Min" : "-"),
          _cell(hasEntry ? hours.toStringAsFixed(2) : "-"),
          _cell(hasEntry ? day.activity : "-"),
        ],
      );
    });

    return [
      _buildHeader(company, logo, "Wochenbericht"),
      pw.SizedBox(height: 20),

      _sectionTitle("Kunde"),
      _value(customer.name),

      pw.SizedBox(height: 15),

      _sectionTitle("Baustelle"),
      _value(report.constructionSite),

      pw.SizedBox(height: 15),

      _sectionTitle("Woche ab"),
      _value(DateFormat("dd.MM.yyyy").format(weekStart)),

      pw.SizedBox(height: 20),

      pw.Table(
        border: pw.TableBorder.all(width: 0.5),
        columnWidths: const {
          0: pw.FlexColumnWidth(1.2),
          1: pw.FlexColumnWidth(1.2),
          2: pw.FlexColumnWidth(1),
          3: pw.FlexColumnWidth(1),
          4: pw.FlexColumnWidth(1),
          5: pw.FlexColumnWidth(1),
          6: pw.FlexColumnWidth(2.5),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              _cell("Tag", bold: true),
              _cell("Datum", bold: true),
              _cell("Beginn", bold: true),
              _cell("Ende", bold: true),
              _cell("Pause", bold: true),
              _cell("Std.", bold: true),
              _cell("Tätigkeit", bold: true),
            ],
          ),
          ...rows,
        ],
      ),

      pw.SizedBox(height: 15),

      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          "Gesamt: ${totalHours.toStringAsFixed(2)} Std.",
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      ),

      pw.SizedBox(height: 40),

      pw.Row(
        children: [
          pw.Expanded(child: _signature("Mitarbeiter")),
          pw.SizedBox(width: 40),
          pw.Expanded(child: _signature("Kunde")),
        ],
      ),
    ];
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildHeader(
    Company company,
    pw.MemoryImage? logo,
    String title,
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
                title,
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
