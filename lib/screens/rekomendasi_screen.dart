import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitoring_provider.dart';
import '../models/ruang_model.dart';
import '../theme/colors.dart';

class RekomendasiScreen extends StatefulWidget {
  const RekomendasiScreen({super.key});

  @override
  State<RekomendasiScreen> createState() => _RekomendasiScreenState();
}

class _RekomendasiScreenState extends State<RekomendasiScreen> {
  @override
  void initState() {
    super.initState();
    // Pastikan data dimuat saat screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MonitoringProvider>(context, listen: false);
      // provider.refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rekomendasi Efisiensi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.bluePrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bluePrimary,
              AppColors.lightBackground,
            ],
            stops: [0.0, 0.25],
          ),
        ),
        child: Consumer<MonitoringProvider>(
          builder: (context, provider, child) {
            // Debug: Print data untuk memeriksa apakah data tersedia
            print('Rekomendasi Screen - Jumlah ruang: ${provider.ruangList.length}');
            print('Rekomendasi Screen - Total konsumsi: ${provider.totalKonsumsi}');

            // Pastikan data sudah dimuat
            if (provider.ruangList.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Memuat data ruang...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            }

            final rekomendasi = _generateRekomendasi(provider.ruangList);
            print('Rekomendasi Screen - Jumlah rekomendasi: ${rekomendasi.length}');

            return Column(
              children: [
                _buildOverviewCard(provider),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: rekomendasi.isEmpty
                        ? _buildEmptyState()
                        : Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: rekomendasi.length,
                            itemBuilder: (context, index) {
                              final item = rekomendasi[index];
                              return _buildRekomendasiCard(item, index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOverviewCard(MonitoringProvider provider) {
    final totalKonsumsi = provider.totalKonsumsi;
    final ruangOverLimit = provider.ruangOverLimit;
    final efisiensiScore = _calculateEfficiencyScore(provider.ruangList);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Ringkasan Efisiensi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  'Total Konsumsi',
                  '${(totalKonsumsi / 1000).toStringAsFixed(1)}kW',
                  Icons.flash_on,
                  Colors.white,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildOverviewItem(
                  'Ruang Berlebih',
                  ruangOverLimit.toString(),
                  Icons.warning_amber_rounded,
                  ruangOverLimit > 0 ? AppColors.warning : Colors.white,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildOverviewItem(
                  'Skor Efisiensi',
                  '${efisiensiScore.toInt()}%',
                  Icons.eco,
                  _getEfficiencyColor(efisiensiScore),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco,
              size: 60,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Semua Ruang Efisien!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tidak ada rekomendasi perbaikan\nyang diperlukan saat ini',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRekomendasiCard(Map<String, dynamic> rekomendasi, int index) {
    final prioritas = rekomendasi['prioritas'] as String;
    final color = _getPriorityColor(prioritas);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    prioritas.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rekomendasi['ruang'] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getPriorityIcon(prioritas),
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              'Konsumsi Saat Ini',
                              '${(rekomendasi['konsumsi'] as double).toInt()}W',
                              Icons.flash_on,
                              AppColors.warning,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          Expanded(
                            child: _buildInfoItem(
                              'Batas Normal',
                              '${(rekomendasi['batas'] as double).toInt()}W',
                              Icons.speed,
                              AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              'Selisih',
                              '+${(rekomendasi['selisih'] as double).toInt()}W',
                              Icons.trending_up,
                              AppColors.error,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.grey[300],
                          ),
                          Expanded(
                            child: _buildInfoItem(
                              'Potensi Hemat',
                              '${(rekomendasi['potensialPenghematan'] as double).toInt()}W',
                              Icons.savings,
                              AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 20,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Rekomendasi Aksi:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...((rekomendasi['aksi'] as List<String>).asMap().entries.map((entry) {
                  final index = entry.key;
                  final aksi = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.1)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            aksi,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _generateRekomendasi(List<RuangModel> ruangList) {
    final List<Map<String, dynamic>> rekomendasi = [];

    // Debug: Print informasi setiap ruang
    for (var ruang in ruangList) {
      print('Ruang: ${ruang.nama}, Aktif: ${ruang.aktif}, Konsumsi: ${ruang.konsumsi}, Batas: ${ruang.batas}, Over Limit: ${ruang.isOverLimit}');
    }

    for (var ruang in ruangList.where((r) => r.aktif)) {
      if (ruang.isOverLimit) {
        final selisih = ruang.konsumsi - ruang.batas;
        final persentaseSelisih = (selisih / ruang.batas) * 100;

        String prioritas;
        List<String> aksi;

        if (persentaseSelisih > 50) {
          prioritas = 'Tinggi';
          aksi = [
            'Matikan peralatan yang tidak digunakan segera',
            'Periksa sistem AC dan pencahayaan',
            'Lakukan audit energi menyeluruh',
            'Pertimbangkan upgrade ke peralatan hemat energi',
          ];
        } else if (persentaseSelisih > 25) {
          prioritas = 'Sedang';
          aksi = [
            'Optimalisasi penggunaan AC',
            'Ganti lampu dengan LED',
            'Atur jadwal penggunaan peralatan',
            'Edukasi pengguna tentang hemat energi',
          ];
        } else {
          prioritas = 'Rendah';
          aksi = [
            'Monitor penggunaan secara berkala',
            'Reminder untuk mematikan peralatan',
            'Pertimbangkan sensor otomatis',
          ];
        }

        rekomendasi.add({
          'ruang': ruang.nama,
          'konsumsi': ruang.konsumsi,
          'batas': ruang.batas,
          'selisih': selisih,
          'prioritas': prioritas,
          'potensialPenghematan': selisih * 0.8,
          'aksi': aksi,
        });
      }
    }

    // Sort berdasarkan prioritas
    rekomendasi.sort((a, b) {
      final priorityOrder = {'Tinggi': 0, 'Sedang': 1, 'Rendah': 2};
      return priorityOrder[a['prioritas']]!.compareTo(priorityOrder[b['prioritas']]!);
    });

    return rekomendasi;
  }

  double _calculateEfficiencyScore(List<RuangModel> ruangList) {
    if (ruangList.isEmpty) return 100;

    final activeRooms = ruangList.where((r) => r.aktif).toList();
    if (activeRooms.isEmpty) return 100;

    int efficientRooms = 0;
    for (var ruang in activeRooms) {
      if (!ruang.isOverLimit) {
        efficientRooms++;
      }
    }

    return (efficientRooms / activeRooms.length) * 100;
  }

  Color _getPriorityColor(String prioritas) {
    switch (prioritas) {
      case 'Tinggi':
        return AppColors.error;
      case 'Sedang':
        return AppColors.warning;
      case 'Rendah':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getPriorityIcon(String prioritas) {
    switch (prioritas) {
      case 'Tinggi':
        return Icons.priority_high;
      case 'Sedang':
        return Icons.warning_amber_rounded;
      case 'Rendah':
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }

  Color _getEfficiencyColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }
}
