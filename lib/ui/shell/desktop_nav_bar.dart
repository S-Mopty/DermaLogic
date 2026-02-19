import 'package:flutter/material.dart';

import '../../utils/constants.dart';

/// Barre de navigation horizontale desktop.
class DesktopNavBar extends StatelessWidget {
  final String currentPath;
  final String cityName;
  final void Function(String path) onNavigate;
  final VoidCallback onCityClick;

  const DesktopNavBar({
    super.key,
    required this.currentPath,
    required this.cityName,
    required this.onNavigate,
    required this.onCityClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      color: AppColors.panneau,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Logo
          const Text(
            'DermaLogic',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 25),

          // Boutons de navigation
          _navButton('Analyse', '/', context),
          _navButton('Produits', '/produits', context),
          _navButton('Profil', '/profil', context),
          _navButton('Historique', '/historique', context),

          const Spacer(),

          // Ville actuelle
          Text(
            cityName,
            style: const TextStyle(
              color: AppColors.texteSecondaire,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 28,
            child: TextButton(
              onPressed: onCityClick,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.carte,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Changer', style: TextStyle(fontSize: 12)),
            ),
          ),
          const SizedBox(width: 8),

          // Icone parametres
          IconButton(
            onPressed: () => onNavigate('/parametres'),
            icon: Icon(
              Icons.settings,
              color: currentPath == '/parametres'
                  ? AppColors.accent
                  : AppColors.texteSecondaire,
              size: 22,
            ),
            tooltip: 'Parametres',
          ),
        ],
      ),
    );
  }

  Widget _navButton(String label, String path, BuildContext context) {
    final isActive = currentPath == path;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: TextButton(
        onPressed: () => onNavigate(path),
        style: TextButton.styleFrom(
          backgroundColor: isActive ? AppColors.accent : Colors.transparent,
          foregroundColor: isActive ? AppColors.fond : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
