import 'package:flutter/material.dart';
import '../theme/colors.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color? cardColor;
  final Color? iconColor;
  final Color? textColor;
  final String? subtitle;
  final double? percentage;
  final bool showTrend;
  final bool isIncreasing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final Gradient? gradient;
  final bool isLoading;
  final Widget? customTrailing;
  final IconData? increasingIcon;
  final IconData? decreasingIcon;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    this.cardColor,
    this.iconColor,
    this.textColor,
    this.subtitle,
    this.percentage,
    this.showTrend = false,
    this.isIncreasing = true,
    this.onTap,
    this.padding,
    this.elevation,
    this.gradient,
    this.isLoading = false,
    this.customTrailing,
    this.increasingIcon,
    this.decreasingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Material(
      elevation: elevation ?? 2,
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor ?? AppColors.cardBackground,
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: elevation != null
                ? null
                : [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading && percentage == null) {
      return _buildLoadingState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        _buildTitle(),
        const SizedBox(height: 4),
        _buildValueSection(),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          _buildSubtitle(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildIconContainer(),
        if (customTrailing != null)
          customTrailing!
        else if (showTrend)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: percentage != null
                ? _buildTrendIndicator()
                : _buildShimmer(60, 24, borderRadius: 12),
          ),
      ],
    );
  }

  Widget _buildIconContainer() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor?.withOpacity(0.1) ??
            Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: iconColor ?? AppColors.textPrimary,
        size: 20,
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final trendColor = isIncreasing ? AppColors.error : AppColors.success;
    final trendIcon = isIncreasing
        ? (increasingIcon ?? Icons.trending_up)
        : (decreasingIcon ?? Icons.trending_down);

    return Container(
      key: const ValueKey('trend_indicator'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            color: trendColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '${percentage!.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        color: textColor ?? AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildValueSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor ?? AppColors.textPrimary,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (unit.isNotEmpty) ...[
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              unit,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      subtitle!,
      style: TextStyle(
        fontSize: 12,
        color: textColor ?? AppColors.textLight,
        fontWeight: FontWeight.w400,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildShimmer(32, 32, borderRadius: 8),
            if (showTrend) _buildShimmer(60, 24, borderRadius: 12),
          ],
        ),
        const SizedBox(height: 12),
        _buildShimmer(80, 14),
        const SizedBox(height: 8),
        _buildShimmer(120, 24),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          _buildShimmer(100, 12),
        ],
      ],
    );
  }

  Widget _buildShimmer(double width, double height, {double? borderRadius}) {
    return Container(
      key: ValueKey('shimmer_$width'),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius ?? 4),
      ),
    );
  }
}
