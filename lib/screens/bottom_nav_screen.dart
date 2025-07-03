import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/monitoring_provider.dart';
import '../theme/colors.dart';
import 'monitoring_screen.dart';
import 'statistik_screen.dart';
import 'notifikasi_screen.dart';
import 'rekomendasi_screen.dart';
import 'qr_scanner_screen.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MonitoringScreen(),
    StatistikScreen(),
    NotifikasiScreen(),
    RekomendasiScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QRScannerScreen()),
          );
        },
        backgroundColor: AppColors.bluePrimary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: AppColors.cardBackground,
      elevation: 10,
      child: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Sisi Kiri
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildNavItem(icon: Icons.dashboard_rounded, label: 'Monitoring', index: 0),
                _buildNavItem(icon: Icons.bar_chart_rounded, label: 'Statistik', index: 1),
              ],
            ),
            // Sisi Kanan
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildNavItem(icon: Icons.notifications, label: 'Notifikasi', index: 2),
                _buildNavItem(icon: Icons.lightbulb_rounded, label: 'Rekomendasi', index: 3),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget baru untuk membuat setiap item navigasi
  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final bool isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.bluePrimary : AppColors.textSecondary;

    return Container(
      width: MediaQuery.of(context).size.width / 5,
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (index == 2)
              Consumer<MonitoringProvider>(
                builder: (context, provider, child) {
                  final unreadCount = provider.notifikasiList.where((n) => !n.isRead).length;
                  return unreadCount > 0
                      ? _buildNotificationIcon(icon, color, unreadCount)
                      : Icon(icon, color: color, size: 24);
                },
              )
            else
              Icon(icon, color: color, size: 24),

            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk ikon notifikasi dengan badge
  Widget _buildNotificationIcon(IconData icon, Color color, int count) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: color, size: 24),
        Positioned(
          top: -5,
          right: 15,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5)
            ),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            child: Text(
              count.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
