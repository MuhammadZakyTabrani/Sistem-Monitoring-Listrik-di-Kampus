import 'dart:math';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/ruang_model.dart';
import '../providers/monitoring_provider.dart';

class PdfExportService {
  /// Laporan 1: Halaman Monitoring
  Future<void> generateMonitoringReport(MonitoringProvider provider) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(context, boldFont),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          _buildTitle(boldFont, title: 'Laporan Ringkasan Monitoring'),
          pw.SizedBox(height: 24),
          _buildSummary(provider, font, boldFont),
          pw.SizedBox(height: 24),
          pw.Text('Daftar Detail Ruangan:', style: pw.TextStyle(font: boldFont, fontSize: 14)),
          pw.SizedBox(height: 12),
          _buildRoomTable(provider, font, boldFont),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  /// Laporan 2: Halaman Statistik
  Future<void> generateStatistikReport(MonitoringProvider provider) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();

    final now = DateTime.now();
    final chartData = provider.getMonthlyConsumptionForChart();
    final totalCurrentMonth = chartData['current'] ?? 0.0;
    final totalPreviousMonth = chartData['previous'] ?? 0.0;

    double percentageChange = 0;
    if (totalPreviousMonth > 0) {
      percentageChange = ((totalCurrentMonth - totalPreviousMonth) / totalPreviousMonth) * 100;
    } else if (totalCurrentMonth > 0) {
      percentageChange = 100.0;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(context, boldFont),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          _buildTitle(boldFont, title: 'Laporan Statistik Konsumsi'),
          pw.SizedBox(height: 24),
          pw.Text('Perbandingan Konsumsi Bulanan (kWh):', style: pw.TextStyle(font: boldFont, fontSize: 14)),
          pw.SizedBox(height: 12),
          _buildStatistikSummary(totalCurrentMonth, totalPreviousMonth, percentageChange, font, boldFont),
          pw.SizedBox(height: 20),
          _buildStatistikChartManual(totalCurrentMonth, totalPreviousMonth, now, font),
          pw.SizedBox(height: 24),
          pw.Text('Detail Penggunaan per Ruangan:', style: pw.TextStyle(font: boldFont, fontSize: 14)),
          pw.SizedBox(height: 12),
          _buildStatistikRoomTable(provider, font, boldFont),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  /// Laporan 3: Halaman Detail Ruangan
  Future<void> generateRoomDetailReport(RuangModel room) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final italicFont = await PdfGoogleFonts.robotoItalic();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(context, boldFont),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          _buildTitle(boldFont, title: 'Laporan Detail: ${room.nama}'),
          pw.SizedBox(height: 24),
          _buildRoomInfoTable(room, font, boldFont),
          pw.SizedBox(height: 24),
          pw.Text('Daftar Alat Listrik Terpasang:', style: pw.TextStyle(font: boldFont, fontSize: 14)),
          pw.SizedBox(height: 12),
          _buildDeviceListTable(room, font, boldFont, italicFont),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  // --- Fungsi-fungsi Pembantu untuk Membangun Bagian PDF ---

  pw.Widget _buildHeader(pw.Context context, pw.Font boldFont) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(bottom: 20.0),
      child: pw.Text('Laporan Sistem Monitoring Listrik', style: pw.TextStyle(font: boldFont, color: PdfColors.grey)),
    );
  }

  pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20.0),
      child: pw.Text('Halaman ${context.pageNumber} dari ${context.pagesCount}', style: pw.TextStyle(font: font, color: PdfColors.grey)),
    );
  }

  pw.Widget _buildTitle(pw.Font boldFont, {required String title}) {
    final formattedDate = DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(DateTime.now());
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(font: boldFont, fontSize: 24)),
        pw.SizedBox(height: 4),
        pw.Text('Dibuat pada: $formattedDate', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
        pw.Divider(color: PdfColors.grey400, height: 20),
      ],
    );
  }

  pw.TableRow _buildTableRow(List<String> cells, {required pw.Font font, required pw.Font boldFont, bool isHeader = false}) {
    return pw.TableRow(
      children: cells.map((cell) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(cell, style: pw.TextStyle(font: isHeader ? boldFont : font)),
        );
      }).toList(),
    );
  }

  // Helpers untuk Laporan Monitoring
  pw.Widget _buildSummary(MonitoringProvider provider, pw.Font font, pw.Font boldFont) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        _buildTableRow(['Metrik', 'Nilai'], font: font, boldFont: boldFont, isHeader: true),
        _buildTableRow(['Total Konsumsi', '${provider.totalKonsumsi.toStringAsFixed(1)} W'], font: font, boldFont: boldFont),
        _buildTableRow(['Efisiensi Kampus', '${provider.efisiensiEnergi.toStringAsFixed(1)} %'], font: font, boldFont: boldFont),
        _buildTableRow(['Ruangan Aktif', provider.ruangAktif.toString()], font: font, boldFont: boldFont),
        _buildTableRow(['Ruangan Melebihi Batas', provider.ruangOverLimit.toString()], font: font, boldFont: boldFont),
      ],
    );
  }

  pw.Widget _buildRoomTable(MonitoringProvider provider, pw.Font font, pw.Font boldFont) {
    final headers = ['Nama Ruangan', 'Status', 'Konsumsi (W)', 'Batas (W)'];
    final data = provider.ruangList.map((ruang) => [ruang.nama, ruang.aktif ? 'Aktif' : 'Nonaktif', ruang.konsumsi.toStringAsFixed(1), ruang.batas.toStringAsFixed(0)]).toList();
    return pw.Table.fromTextArray(
      headers: headers, data: data, border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
      cellStyle: pw.TextStyle(font: font),
      cellAlignments: { 1: pw.Alignment.center, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight },
    );
  }

  // Helpers untuk Laporan Statistik
  pw.Widget _buildStatistikSummary(double current, double previous, double change, pw.Font font, pw.Font boldFont) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {0: const pw.FlexColumnWidth(2), 1: const pw.FlexColumnWidth(1)},
      children: [
        _buildTableRow(['Deskripsi', 'Nilai'], font: font, boldFont: boldFont, isHeader: true),
        _buildTableRow(['Konsumsi Bulan Ini', '${current.toStringAsFixed(1)} kWh'], font: font, boldFont: boldFont),
        _buildTableRow(['Konsumsi Bulan Lalu', '${previous.toStringAsFixed(1)} kWh'], font: font, boldFont: boldFont),
        _buildTableRow(['Perubahan', '${change.toStringAsFixed(1)} %'], font: font, boldFont: boldFont),
      ],
    );
  }

  pw.Widget _buildStatistikChartManual(double current, double previous, DateTime now, pw.Font font) {
    final double chartHeight = 150;
    final double maxValue = [current, previous, 1.0].reduce(max) * 1.2;
    final double previousMonthHeight = maxValue > 0 ? (previous / maxValue * chartHeight) : 0;
    final double currentMonthHeight = maxValue > 0 ? (current / maxValue * chartHeight) : 0;
    final previousMonthDate = DateTime(now.year, now.month - 1);

    pw.Widget buildBar(String label, double value, double height) {
      return pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(value.toStringAsFixed(1), style: pw.TextStyle(font: font, fontSize: 10)),
            pw.SizedBox(height: 4),
            pw.Container(
              width: 50,
              height: height.clamp(0, chartHeight),
              color: label.contains(DateFormat('MMM yy', 'id_ID').format(now)) ? PdfColors.blue700 : PdfColors.blueGrey300,
            ),
            pw.SizedBox(height: 4),
            pw.Container(height: 1, color: PdfColors.black, width: 60),
            pw.SizedBox(height: 4),
            pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10)),
          ]
      );
    }

    return pw.Container(
      height: chartHeight + 50,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          buildBar(DateFormat('MMM yy', 'id_ID').format(previousMonthDate), previous, previousMonthHeight),
          buildBar(DateFormat('MMM yy', 'id_ID').format(now), current, currentMonthHeight),
        ],
      ),
    );
  }

  pw.Widget _buildStatistikRoomTable(MonitoringProvider provider, pw.Font font, pw.Font boldFont) {
    final headers = ['Nama Ruangan', 'Konsumsi (W)', 'Batas (W)', 'Penggunaan (%)'];
    final data = provider.ruangList.map((ruang) {
      final penggunaan = ruang.batas > 0 ? (ruang.konsumsi / ruang.batas * 100) : 0;
      return [ruang.nama, ruang.konsumsi.toStringAsFixed(1), ruang.batas.toStringAsFixed(0), penggunaan.toStringAsFixed(1)];
    }).toList();
    return pw.Table.fromTextArray(
      headers: headers, data: data, border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
      cellStyle: pw.TextStyle(font: font),
      cellAlignments: { 1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight },
    );
  }

  // Helpers untuk Laporan Detail Ruangan
  pw.Widget _buildRoomInfoTable(RuangModel room, pw.Font font, pw.Font boldFont) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {0: const pw.FlexColumnWidth(1), 1: const pw.FlexColumnWidth(2)},
      children: [
        _buildTableRow(['Deskripsi', 'Detail'], font: font, boldFont: boldFont, isHeader: true),
        _buildTableRow(['Nama Ruangan', room.nama], font: font, boldFont: boldFont),
        _buildTableRow(['Lokasi', room.metadata['lokasi'] ?? 'N/A'], font: font, boldFont: boldFont),
        _buildTableRow(['Koordinator', room.metadata['koordinator'] ?? 'N/A'], font: font, boldFont: boldFont),
        _buildTableRow(['Status Ruangan', room.aktif ? 'Aktif' : 'Nonaktif'], font: font, boldFont: boldFont),
        _buildTableRow(['Konsumsi Saat Ini', '${room.konsumsi.toStringAsFixed(1)} W'], font: font, boldFont: boldFont),
        _buildTableRow(['Batas Maksimal', '${room.batas.toStringAsFixed(0)} W'], font: font, boldFont: boldFont),
      ],
    );
  }

  pw.Widget _buildDeviceListTable(RuangModel room, pw.Font font, pw.Font boldFont, pw.Font italicFont) {
    final headers = ['Nama Alat', 'Konsumsi (W)', 'Status'];
    final data = room.daftarAlat.map((alat) => [alat.nama, alat.konsumsi.toStringAsFixed(1), alat.status ? 'Menyala' : 'Mati']).toList();
    if (data.isEmpty) {
      return pw.Text('Tidak ada alat terdaftar di ruangan ini.', style: pw.TextStyle(font: italicFont));
    }
    return pw.Table.fromTextArray(
      headers: headers, data: data, border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey),
      cellStyle: pw.TextStyle(font: font),
      cellAlignments: { 1: pw.Alignment.centerRight, 2: pw.Alignment.center },
    );
  }
}
