import 'package:flutter/material.dart';
import '../models/ruang_model.dart';
import '../theme/colors.dart';

class RuangCard extends StatelessWidget {
  final RuangModel ruang;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const RuangCard({
    super.key,
    required this.ruang,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: ruang.isOverLimit && ruang.aktif
                ? Border.all(color: AppColors.error, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildPowerInfo(),
              const SizedBox(height: 12),
              _buildProgressBar(),
              const SizedBox(height: 12),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ruang.aktif ? AppColors.success : AppColors.textLight,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ruang.nama,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                ruang.status,
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: ruang.aktif,
          onChanged: onToggle != null ? (_) => onToggle!() : null,
          activeColor: AppColors.success,
          activeTrackColor: AppColors.success.withOpacity(0.3),
          inactiveThumbColor: AppColors.textLight,
          inactiveTrackColor: AppColors.textLight.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildPowerInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Konsumsi Saat Ini',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  size: 16,
                  color: _getPowerColor(),
                ),
                const SizedBox(width: 4),
                Text(
                  '${ruang.konsumsi.toStringAsFixed(0)}W',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getPowerColor(),
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Batas Maksimal',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${ruang.batas.toStringAsFixed(0)}W',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final percentage = ruang.persentasePenggunaan / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Penggunaan',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${ruang.persentasePenggunaan.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getPercentageColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: AppColors.divider,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: AppColors.textLight,
        ),
        const SizedBox(width: 4),
        Text(
          'Update: ${ruang.lastUpdated.toString().substring(11, 19)}',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textLight,
          ),
        ),
        const Spacer(),
        if (ruang.isOverLimit && ruang.aktif)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning,
                  size: 12,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  'Melebihi Batas',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Color _getStatusColor() {
    if (!ruang.aktif) return AppColors.textLight;
    switch (ruang.status) {
      case 'Normal':
        return AppColors.success;
      case 'Tinggi':
        return AppColors.warning;
      case 'Kritis':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getPowerColor() {
    if (!ruang.aktif) return AppColors.textLight;
    if (ruang.konsumsi > ruang.batas) return AppColors.error;
    if (ruang.konsumsi > ruang.batas * 0.8) return AppColors.warning;
    return AppColors.success;
  }

  Color _getPercentageColor() {
    if (ruang.persentasePenggunaan > 100) return AppColors.error;
    if (ruang.persentasePenggunaan > 80) return AppColors.warning;
    return AppColors.success;
  }

  Color _getProgressColor() {
    if (ruang.persentasePenggunaan > 100) return AppColors.error;
    if (ruang.persentasePenggunaan > 80) return AppColors.warning;
    if (ruang.persentasePenggunaan > 60) return AppColors.info;
    return AppColors.success;
  }
}
