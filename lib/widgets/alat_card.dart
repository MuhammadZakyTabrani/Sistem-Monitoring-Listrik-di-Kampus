import 'package:flutter/material.dart';
import '../models/alat_model.dart';
import '../theme/colors.dart';

class AlatCard extends StatelessWidget {
  final AlatModel alat;
  final VoidCallback onToggle;

  const AlatCard({
    super.key,
    required this.alat,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: alat.status ? Colors.white : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alat.status
              ? AppColors.success.withOpacity(0.5)
              : AppColors.divider,
          width: 1.5,
        ),
        boxShadow: alat.status
            ? [
          BoxShadow(
            color: AppColors.success.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
            : [],
      ),
      child: Row(
        children: [
          // Ikon Alat
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: alat.status
                  ? AppColors.success.withOpacity(0.15)
                  : AppColors.divider.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              getIconData(alat.iconName),
              color: alat.status ? AppColors.success : AppColors.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Nama dan Konsumsi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alat.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alat.status
                      ? '${alat.konsumsi.toStringAsFixed(1)} W'
                      : 'Nonaktif',
                  style: TextStyle(
                    fontSize: 14,
                    color: alat.status
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Tombol Switch
          Switch(
            value: alat.status,
            onChanged: (newValue) {
              onToggle();
            },
            activeColor: AppColors.success,
            inactiveThumbColor: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
