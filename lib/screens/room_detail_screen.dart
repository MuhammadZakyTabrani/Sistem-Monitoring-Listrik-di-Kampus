import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/ruang_model.dart';
import '../providers/monitoring_provider.dart';
import '../services/pdf_export_service.dart';
import '../theme/colors.dart';
import '../widgets/alat_card.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/metric_card.dart';

class RoomDetailScreen extends StatelessWidget {
  final String roomId;

  const RoomDetailScreen({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitoringProvider>();
    final room = provider.getRuangById(roomId);

    if (room == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Ruangan'),
          backgroundColor: AppColors.bluePrimary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Ruangan tidak ditemukan atau sedang dimuat...'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(room.nama),
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Cetak Laporan Ruangan',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mempersiapkan laporan PDF...'), duration: Duration(seconds: 1)),
              );
              final pdfService = PdfExportService();
              // Memanggil fungsi yang tepat dengan data 'room' spesifik
              await pdfService.generateRoomDetailReport(room);
            },
          ),
        ],
      ),
      backgroundColor: AppColors.lightBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(room),
            const SizedBox(height: 24),
            _buildConsumptionMetrics(context, room),
            const SizedBox(height: 24),
            _buildDeviceList(context, room),
            const SizedBox(height: 24),
            _buildConsumptionChart(context, room),
            const SizedBox(height: 24),
            _buildRoomInfo(room),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context, RuangModel room) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daftar Alat Listrik',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        if (room.daftarAlat.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Tidak ada alat terdaftar di ruangan ini.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: room.daftarAlat.length,
            itemBuilder: (context, index) {
              final alat = room.daftarAlat[index];
              return AlatCard(
                alat: alat,
                onToggle: () {
                  context.read<MonitoringProvider>().toggleAlatStatus(room.id, alat.id);
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildStatusHeader(RuangModel room) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bluePrimary, AppColors.blueLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [ BoxShadow(color: AppColors.shadow, blurRadius: 10, offset: const Offset(0, 4)) ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.nama,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.metadata['lokasi'] ?? 'Gedung A - Lantai 1',
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: room.aktif ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: room.aktif ? Colors.green : Colors.grey, width: 1),
                ),
                child: Text(
                  room.aktif ? 'Aktif' : 'Nonaktif',
                  style: TextStyle(color: room.aktif ? Colors.white : Colors.grey[300], fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.white.withOpacity(0.8)),
              const SizedBox(width: 8),
              Text(
                'Terakhir diperbarui: ${DateFormat('HH:mm:ss', 'id_ID').format(room.lastUpdated)}',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionMetrics(BuildContext context, RuangModel room) {
    final provider = context.watch<MonitoringProvider>();
    final roomTrend = provider.getRoomTrend(room.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ringkasan Konsumsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Konsumsi Saat Ini',
                value: room.konsumsi.toStringAsFixed(1),
                unit: 'W',
                icon: Icons.flash_on,
                cardColor: room.isOverLimit ? AppColors.error.withOpacity(0.1) : AppColors.cardBackground,
                iconColor: room.isOverLimit ? AppColors.error : AppColors.bluePrimary,
                textColor: room.isOverLimit ? AppColors.error : null,
                isLoading: provider.isLoading && roomTrend == null,
                showTrend: true,
                percentage: roomTrend.percentage,
                isIncreasing: roomTrend.isIncreasing,
                increasingIcon: Icons.trending_up,
                decreasingIcon: Icons.trending_down,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MetricCard(
                title: 'Batas Maksimal',
                value: room.batas.toStringAsFixed(1),
                unit: 'W',
                icon: Icons.speed,
                cardColor: AppColors.cardBackground,
                iconColor: AppColors.bluePrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConsumptionChart(BuildContext context, RuangModel room) {
    final provider = context.watch<MonitoringProvider>();
    final now = DateTime.now();
    final chartData = provider.getMonthlyConsumptionForChart(roomId: room.id);
    final currentMonthKWh = chartData['current'] ?? 0.0;
    final previousMonthKWh = chartData['previous'] ?? 0.0;
    final previousMonth = DateTime(now.year, now.month - 1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bluePrimary.withOpacity(0.2), width: 1),
        boxShadow: [ BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)) ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Grafik Konsumsi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChartWidget(
              totalCurrentMonth: currentMonthKWh,
              totalPreviousMonth: previousMonthKWh,
              currentMonthName: DateFormat('MMM yy', 'id_ID').format(now),
              previousMonthName: DateFormat('MMM yy', 'id_ID').format(previousMonth),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomInfo(RuangModel room) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [ BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2)) ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Ruangan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          _buildInfoItem('Kapasitas', room.metadata['kapasitas'] ?? 'N/A'),
          _buildInfoItem('Peralatan', room.metadata['peralatan'] ?? 'N/A'),
          _buildInfoItem('Koordinator', room.metadata['koordinator'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
          const Text(': ', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
