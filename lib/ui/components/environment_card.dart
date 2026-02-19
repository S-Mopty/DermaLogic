import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/constants.dart';

/// Carte compacte pour une metrique environnementale (UV, humidite, PM2.5, temperature).
class EnvironmentCard extends StatelessWidget {
  final String title;
  final String value;
  final String level;
  final Color levelColor;
  final bool isLoading;

  const EnvironmentCard({
    super.key,
    required this.title,
    this.value = '--',
    this.level = '',
    this.levelColor = AppColors.texteSecondaire,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.carte,
        borderRadius: BorderRadius.circular(12),
      ),
      child: isLoading ? _buildShimmer() : _buildContent(),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.carte,
      highlightColor: AppColors.carteHover,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 45,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.texteSecondaire,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (level.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            level,
            style: TextStyle(
              fontSize: 10,
              color: levelColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
