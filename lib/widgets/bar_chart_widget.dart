import 'package:flutter/material.dart';
import '../theme/colors.dart';

class BarChartWidget extends StatelessWidget {
  final double totalCurrentMonth;
  final double totalPreviousMonth;
  final String currentMonthName;
  final String previousMonthName;

  const BarChartWidget({
    Key? key,
    required this.totalCurrentMonth,
    required this.totalPreviousMonth,
    required this.currentMonthName,
    required this.previousMonthName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure values are not NaN or infinite
    final safeTotalCurrent = _getSafeValue(totalCurrentMonth);
    final safeTotalPrevious = _getSafeValue(totalPreviousMonth);

    // Find the maximum value for scaling
    final maxValue = [safeTotalCurrent, safeTotalPrevious, 100.0].reduce((a, b) => a > b ? a : b);

    // Calculate heights (minimum 20% to show small bars, maximum 80%)
    final currentHeight = maxValue > 0 ? ((safeTotalCurrent / maxValue * 0.6) + 0.2).clamp(0.2, 0.8) : 0.2;
    final previousHeight = maxValue > 0 ? ((safeTotalPrevious / maxValue * 0.6) + 0.2).clamp(0.2, 0.8) : 0.2;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Chart area with flexible height
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Reserve space for labels and values
                final chartHeight = constraints.maxHeight - 40;

                return Column(
                  children: [
                    // Chart bars
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: _buildBar(
                              maxHeight: chartHeight * 0.8,
                              heightRatio: currentHeight,
                              color: AppColors.bluePrimary,
                              label: _formatLabel(currentMonthName),
                              value: _formatValue(safeTotalCurrent),
                              isCurrentMonth: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: _buildBar(
                              maxHeight: chartHeight * 0.8,
                              heightRatio: previousHeight,
                              color: AppColors.blueLight,
                              label: _formatLabel(previousMonthName),
                              value: _formatValue(safeTotalPrevious),
                              isCurrentMonth: false,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Fixed height for legend
                    SizedBox(
                      height: 32,
                      child: _buildLegend(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  double _getSafeValue(double value) {
    if (value.isNaN || value.isInfinite || value < 0) {
      return 0.0;
    }
    return value;
  }

  String _formatLabel(String label) {
    // Format date labels more consistently
    final parts = label.split('/');
    if (parts.length == 2) {
      final month = int.tryParse(parts[0]);
      final year = int.tryParse(parts[1]);
      if (month != null && year != null) {
        final monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei',
          'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
        if (month >= 1 && month <= 12) {
          return '${monthNames[month]} ${year.toString().substring(2)}';
        }
      }
    }
    return label;
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildBar({
    required double maxHeight,
    required double heightRatio,
    required Color color,
    required String label,
    required String value,
    required bool isCurrentMonth,
  }) {
    final barHeight = (maxHeight * heightRatio).clamp(16.0, maxHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Value on top of bar
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),

        // Bar with animation
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          width: 28,
          height: barHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                color,
                color.withOpacity(0.7),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),

        // Label with constrained height
        Container(
          height: 16,
          margin: const EdgeInsets.only(top: 4),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem(
            color: AppColors.bluePrimary,
            label: 'Bulan Ini',
          ),
          const SizedBox(width: 12),
          _buildLegendItem(
            color: AppColors.blueLight,
            label: 'Bulan Lalu',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
