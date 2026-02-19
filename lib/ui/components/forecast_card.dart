import 'package:flutter/material.dart';

import '../../utils/constants.dart';

/// Carte compacte pour une prevision journaliere.
class ForecastCard extends StatelessWidget {
  final String date;
  final double uvMax;
  final double tempMin;
  final double tempMax;
  final double humidity;

  const ForecastCard({
    super.key,
    required this.date,
    required this.uvMax,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    final uvColor = _uvColor(uvMax);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.carte,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'UV ${uvMax.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: uvColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${tempMin.toStringAsFixed(0)}° / ${tempMax.toStringAsFixed(0)}°',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.texteSecondaire,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${humidity.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.texteSecondaire,
            ),
          ),
        ],
      ),
    );
  }

  Color _uvColor(double uv) {
    if (uv < 3) return AppColors.accent;
    if (uv < 6) return const Color(0xFFF9ED69);
    if (uv < 8) return const Color(0xFFF38181);
    if (uv < 11) return AppColors.danger;
    return AppColors.violet;
  }
}
