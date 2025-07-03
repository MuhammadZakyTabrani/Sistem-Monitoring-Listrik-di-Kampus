import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/ruang_model.dart';
import '../providers/monitoring_provider.dart';
import '../services/pdf_export_service.dart';
import '../widgets/bar_chart_widget.dart';
import '../theme/colors.dart';
import 'room_detail_screen.dart';

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MonitoringProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          appBar: AppBar(
            backgroundColor: AppColors.lightBackground,
            elevation: 0,
            title: Text(
              'Statistik Konsumsi',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.print_outlined, color: AppColors.textSecondary),
                tooltip: 'Cetak Laporan Statistik',
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mempersiapkan laporan PDF...'), duration: Duration(seconds: 1)),
                  );
                  final provider = context.read<MonitoringProvider>();
                  final pdfService = PdfExportService();
                  await pdfService.generateStatistikReport(provider);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            top: false,
            child: _buildBody(context, provider),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MonitoringProvider provider) {
    if (provider.isLoading && !provider.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.ruangList.isEmpty && !provider.isLoading) {
      return RefreshIndicator(
        onRefresh: () => provider.refreshData(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text(
                    'Statistik belum tersedia karena tidak ada data ruangan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final chartData = provider.getMonthlyConsumptionForChart();
    final totalCurrentMonth = chartData['current'] ?? 0.0;
    final totalPreviousMonth = chartData['previous'] ?? 0.0;
    final previousMonthDate = DateTime(now.year, now.month - 1);

    final currentMonthDays = DateTime(now.year, now.month + 1, 0).day;
    final dailyAverageCurrent = totalCurrentMonth > 0 ? totalCurrentMonth / now.day.clamp(1, currentMonthDays) : 0.0;
    final dailyAveragePrevious = totalPreviousMonth > 0 ? totalPreviousMonth / DateTime(previousMonthDate.year, previousMonthDate.month + 1, 0).day : 0.0;

    double percentageChange = 0;
    if (totalPreviousMonth > 0) {
      percentageChange = ((totalCurrentMonth - totalPreviousMonth) / totalPreviousMonth) * 100;
    } else if (totalCurrentMonth > 0) {
      percentageChange = 100.0;
    }

    final roomStats = _getRoomStatistics(provider.ruangList);

    return RefreshIndicator(
      onRefresh: () => provider.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.shadow, offset: const Offset(0, 4), blurRadius: 12)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Perbandingan Bulanan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              Text('Konsumsi listrik dalam kWh', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: percentageChange >= 0 ? AppColors.error.withOpacity(0.1) : AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(percentageChange >= 0 ? Icons.trending_up : Icons.trending_down, size: 16, color: percentageChange >= 0 ? AppColors.error : AppColors.success),
                              const SizedBox(width: 4),
                              Text('${percentageChange.abs().toStringAsFixed(1)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: percentageChange >= 0 ? AppColors.error : AppColors.success)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: BarChartWidget(
                        totalCurrentMonth: totalCurrentMonth,
                        totalPreviousMonth: totalPreviousMonth,
                        currentMonthName: DateFormat('MMM yy', 'id_ID').format(now),
                        previousMonthName: DateFormat('MMM yy', 'id_ID').format(previousMonthDate),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildStatCard('Bulan Ini', '${totalCurrentMonth.toStringAsFixed(1)} kWh', 'Rata-rata ${dailyAverageCurrent.toStringAsFixed(1)} kWh/hari', Icons.calendar_today, AppColors.bluePrimary)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Bulan Lalu', '${totalPreviousMonth.toStringAsFixed(1)} kWh', 'Rata-rata ${dailyAveragePrevious.toStringAsFixed(1)} kWh/hari', Icons.history, AppColors.blueLight)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.shadow, offset: const Offset(0, 4), blurRadius: 12)],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Statistik per Ruang', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              Text('Klik untuk melihat detail ruangan', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (roomStats.isNotEmpty)
                      ...roomStats.asMap().entries.map((entry) {
                        final index = entry.key;
                        final stat = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(bottom: index == roomStats.length - 1 ? 0 : 8),
                          child: _buildRoomStatItem(context, stat),
                        );
                      })
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text('Tidak ada data ruang', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Ruang', provider.ruangList.length.toString(), Icons.home_work, AppColors.info)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Ruang Aktif', provider.ruangAktif.toString(), Icons.power, AppColors.success)),
                const SizedBox(width: 12),
                Expanded(child: _buildSummaryCard('Over Limit', provider.ruangOverLimit.toString(), Icons.warning, AppColors.warning)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadow, offset: const Offset(0, 2), blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          FittedBox(child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 2),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getRoomStatistics(List<RuangModel> ruangList) {
    if (ruangList.isEmpty) return [];
    final stats = ruangList.map((ruang) {
      final efficiency = ruang.batas > 0 ? (ruang.konsumsi / ruang.batas) * 100 : 0.0;
      return { 'id': ruang.id, 'name': ruang.nama, 'consumption': ruang.konsumsi, 'limit': ruang.batas, 'efficiency': efficiency, 'active': ruang.aktif, 'isOverLimit': ruang.isOverLimit };
    }).toList();
    stats.sort((a, b) => (b['consumption'] as double).compareTo(a['consumption'] as double));
    return stats;
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadow, offset: const Offset(0, 2), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color))),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis, maxLines: 2),
        ],
      ),
    );
  }

  Widget _buildRoomStatItem(BuildContext context, Map<String, dynamic> stat) {
    final isActive = stat['active'] as bool;
    final isOverLimit = stat['isOverLimit'] as bool;
    final efficiency = stat['efficiency'] as double;
    final consumption = stat['consumption'] as double;
    final limit = stat['limit'] as double;
    final name = stat['name'] as String;
    final roomId = stat['id'] as String;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RoomDetailScreen(roomId: roomId))),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isOverLimit ? AppColors.error.withOpacity(0.3) : AppColors.divider.withOpacity(0.3), width: 1),
            boxShadow: [BoxShadow(color: AppColors.shadow.withOpacity(0.1), offset: const Offset(0, 1), blurRadius: 3)],
          ),
          child: Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: isActive ? (isOverLimit ? AppColors.error : AppColors.success) : AppColors.textSecondary.withOpacity(0.5), shape: BoxShape.circle)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${consumption.toStringAsFixed(1)}W / ${limit.toStringAsFixed(1)}W', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: _getEfficiencyColor(efficiency).withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Text('${efficiency.toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getEfficiencyColor(efficiency))),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEfficiencyColor(double efficiency) {
    if (efficiency > 100) return AppColors.error;
    if (efficiency > 80) return AppColors.warning;
    return AppColors.success;
  }
}
