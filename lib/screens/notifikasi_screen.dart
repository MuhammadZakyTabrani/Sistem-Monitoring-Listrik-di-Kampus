import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitoring_provider.dart';
import '../models/notifikasi_model.dart';
import '../theme/colors.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.bluePrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Consumer<MonitoringProvider>(
            builder: (context, provider, child) {
              final unreadCount = provider.notifikasiList
                  .where((notif) => !notif.isRead)
                  .length;

              if (unreadCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.mark_email_read),
                  onPressed: () {
                    _showMarkAllAsReadDialog(context, provider);
                  },
                  tooltip: 'Tandai semua sebagai dibaca',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bluePrimary,
              Color(0xFFE3F2FD),
              AppColors.lightBackground,
            ],
            stops: [0.0, 0.2, 0.4],
          ),
        ),
        child: Consumer<MonitoringProvider>(
          builder: (context, provider, child) {
            final notifikasiList = provider.notifikasiList;

            if (notifikasiList.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                _buildNotificationSummary(notifikasiList),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.lightBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 20,
                          bottom: 16,
                        ),
                        itemCount: notifikasiList.length,
                        itemBuilder: (context, index) {
                          final notifikasi = notifikasiList[index];
                          return _buildNotificationCard(
                            context,
                            notifikasi,
                            provider,
                          );
                        },
                      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off,
              size: 60,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Semua sistem berjalan normal',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSummary(List<NotifikasiItem> notifikasiList) {
    final unreadCount = notifikasiList.where((n) => !n.isRead).length;
    final warningCount = notifikasiList
        .where((n) => n.type == NotifikasiType.warning)
        .length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Total',
              notifikasiList.length.toString(),
              Icons.notifications,
              Colors.white,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Belum Dibaca',
              unreadCount.toString(),
              Icons.mark_email_unread,
              Colors.white,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Peringatan',
              warningCount.toString(),
              Icons.warning,
              AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(
      BuildContext context,
      NotifikasiItem notifikasi,
      MonitoringProvider provider,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notifikasi.isRead ? Colors.white : const Color(0xFFF3F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: notifikasi.isRead
              ? AppColors.divider
              : AppColors.bluePrimary.withOpacity(0.3),
          width: notifikasi.isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!notifikasi.isRead) {
              provider.markNotificationAsRead(notifikasi.id);
            }
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.bluePrimary.withOpacity(0.1),
          highlightColor: AppColors.bluePrimary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: notifikasi.typeColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notifikasi.typeIcon,
                    color: notifikasi.typeColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notifikasi.judul,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notifikasi.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!notifikasi.isRead)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.bluePrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notifikasi.isi,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notifikasi.formattedTime,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                          if (notifikasi.type == NotifikasiType.warning) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'PERINGATAN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.warning,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMarkAllAsReadDialog(BuildContext context, MonitoringProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Tandai Semua Sebagai Dibaca',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
              'Apakah Anda yakin ingin menandai semua notifikasi sebagai sudah dibaca?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final unreadNotifications = provider.notifikasiList
                    .where((notif) => !notif.isRead)
                    .toList();

                for (var notif in unreadNotifications) {
                  provider.markNotificationAsRead(notif.id);
                }
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${unreadNotifications.length} notifikasi ditandai sebagai dibaca'),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bluePrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Ya, Tandai Semua'),
            ),
          ],
        );
      },
    );
  }
}
