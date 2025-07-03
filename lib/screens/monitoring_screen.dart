import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/monitoring_provider.dart';
import '../services/pdf_export_service.dart';
import '../utils/utils.dart';
import '../widgets/bar_chart_widget.dart';
import '../theme/colors.dart';

class MonitoringScreen extends StatelessWidget {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitoringProvider>();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: AppColors.textSecondary),
            tooltip: 'Cetak Laporan',
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mempersiapkan laporan PDF...'), duration: Duration(seconds: 1)),
              );
              final provider = context.read<MonitoringProvider>();
              final pdfService = PdfExportService();
              await pdfService.generateMonitoringReport(provider);
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
  }

  Widget _buildBody(BuildContext context, MonitoringProvider provider) {
    if (provider.isLoading && !provider.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.ruangList.isEmpty && !provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Tidak ada data ruangan yang dapat ditampilkan.\nCoba refresh halaman.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<MonitoringProvider>().refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            const Text(
              'Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildSummaryCards(context),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/statistik'),
              child: _buildChartSection(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.blueDark, AppColors.bluePrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                      Utils.getGreeting(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Berikut ringkasan sistem Anda saat ini',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              _buildLiveIndicator(),
            ],
          ),
          const SizedBox(height: 16),
          Consumer<MonitoringProvider>(
            builder: (context, provider, _) => Row(
              children: [
                _buildHeaderStat(
                  'Total Konsumsi',
                  '${provider.totalKonsumsi.toStringAsFixed(0)}W',
                  Icons.flash_on,
                ),
                const SizedBox(width: 16),
                _buildHeaderStat(
                  'Efisiensi Global',
                  '${provider.efisiensiEnergi.toStringAsFixed(1)}%',
                  Icons.eco,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Live',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Consumer<MonitoringProvider>(
      builder: (context, provider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Ruang',
                '${provider.ruangList.length}',
                Icons.domain,
                AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Ruang Aktif',
                provider.ruangAktifFormatted,
                Icons.room,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Over Limit',
                provider.ruangOverLimitFormatted,
                Icons.warning,
                AppColors.warning,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    final provider = context.watch<MonitoringProvider>();
    final now = DateTime.now();
    final chartData = provider.getMonthlyConsumptionForChart();
    final currentMonthKWh = chartData['current'] ?? 0.0;
    final previousMonthKWh = chartData['previous'] ?? 0.0;
    final previousMonthDate = DateTime(now.year, now.month - 1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bluePrimary.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Analisis Bulanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    SizedBox(height: 4),
                    Text('Perbandingan konsumsi kWh', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.bluePrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.arrow_forward, color: AppColors.bluePrimary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: BarChartWidget(
              totalCurrentMonth: currentMonthKWh,
              totalPreviousMonth: previousMonthKWh,
              currentMonthName: DateFormat('MMM yy', 'id_ID').format(now),
              previousMonthName: DateFormat('MMM yy', 'id_ID').format(previousMonthDate),
            ),
          ),
        ],
      ),
    );
  }
}
