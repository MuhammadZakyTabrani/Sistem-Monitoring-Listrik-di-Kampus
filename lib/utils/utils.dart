import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  // Format currency (Rupiah)
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Format number with thousand separator
  static String formatNumber(double number) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(number);
  }

  // Format power consumption
  static String formatPower(double power) {
    if (power >= 1000) {
      return '${(power / 1000).toStringAsFixed(1)} kW';
    } else {
      return '${power.toStringAsFixed(0)} W';
    }
  }

  // Format energy consumption
  static String formatEnergy(double energy) {
    if (energy >= 1000) {
      return '${(energy / 1000).toStringAsFixed(1)} kWh';
    } else {
      return '${energy.toStringAsFixed(0)} Wh';
    }
  }

  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  // Format time
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm', 'id_ID').format(time);
  }

  // Format date time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(dateTime);
  }

  // Format relative time (e.g., "2 jam yang lalu")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  // Calculate percentage change
  static double calculatePercentageChange(double oldValue, double newValue) {
    if (oldValue == 0) return 0;
    return ((newValue - oldValue) / oldValue) * 100;
  }

  // Get status color based on power consumption
  static Color getStatusColor(double power, double threshold) {
    if (power > threshold * 1.2) {
      return Colors.red;
    } else if (power > threshold * 0.8) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  // Get status text based on power consumption
  static String getStatusText(double power, double threshold) {
    if (power > threshold * 1.2) {
      return 'Tinggi';
    } else if (power > threshold * 0.8) {
      return 'Sedang';
    } else {
      return 'Normal';
    }
  }

  // Calculate energy cost
  static double calculateEnergyCost(double energyKwh, double tariffPerKwh) {
    return energyKwh * tariffPerKwh;
  }

  // Generate random color
  static Color generateRandomColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
    ];
    colors.shuffle();
    return colors.first;
  }

  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Ya',
        String cancelText = 'Batal',
      }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone number
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,9}$').hasMatch(phone);
  }

  // Get time of day greeting
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  // Get month name in Indonesian
  static String getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  // Get day name in Indonesian
  static String getDayName(int weekday) {
    const days = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    return days[weekday - 1];
  }
}
