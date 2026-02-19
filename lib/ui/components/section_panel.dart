import 'package:flutter/material.dart';

import '../../utils/constants.dart';

/// Panneau conteneur reutilisable avec fond sombre et coins arrondis.
class SectionPanel extends StatelessWidget {
  final Widget child;
  final String? title;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const SectionPanel({
    super.key,
    required this.child,
    this.title,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.panneau,
        borderRadius: BorderRadius.circular(15),
      ),
      child: title != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                child,
              ],
            )
          : child,
    );
  }
}
