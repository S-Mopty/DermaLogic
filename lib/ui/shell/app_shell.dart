import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/config_provider.dart';
import '../../utils/constants.dart';
import '../dialogs/city_selection_dialog.dart';
import 'desktop_nav_bar.dart';

/// Shell responsive : desktop nav bar en haut / mobile nav bar en bas.
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _breakpoint = 768.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= _breakpoint;
    final currentPath = _currentPath(context);

    // Nom de la ville actuelle
    final configAsync = ref.watch(configProvider);
    final cityName = configAsync.whenOrNull(
          data: (config) => config.villeActuelle.toString(),
        ) ??
        'Paris';

    final scaffold = isDesktop
        ? _desktopLayout(context, currentPath, cityName)
        : _mobileLayout(context, currentPath, cityName);

    // Empecher le bouton Back systeme de pop la derniere route GoRouter.
    // Sur "/" → bloquer le pop (l'app reste ouverte).
    // Sur une autre page → retourner a "/".
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && currentPath != '/') {
          context.go('/');
        }
      },
      child: scaffold,
    );
  }

  Widget _desktopLayout(
      BuildContext context, String currentPath, String cityName) {
    return Scaffold(
      body: Column(
        children: [
          DesktopNavBar(
            currentPath: currentPath,
            cityName: cityName,
            onNavigate: (path) => context.go(path),
            onCityClick: () => _openCityDialog(context),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _mobileLayout(
      BuildContext context, String currentPath, String cityName) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DermaLogic - $cityName'),
        actions: [
          IconButton(
            onPressed: () => _openCityDialog(context),
            icon: const Icon(Icons.location_on, color: AppColors.accent),
            tooltip: 'Changer de ville',
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _mobileIndex(currentPath),
        onDestinationSelected: (index) {
          context.go(_mobileRoutes[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analyse',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Produits',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historique',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Parametres',
          ),
        ],
      ),
    );
  }

  static const _mobileRoutes = [
    '/',
    '/produits',
    '/profil',
    '/historique',
    '/parametres',
  ];

  int _mobileIndex(String path) {
    final index = _mobileRoutes.indexOf(path);
    return index >= 0 ? index : 0;
  }

  String _currentPath(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    // Normaliser : "/" reste "/", "/produits" reste "/produits", etc.
    if (location == '/' || location.isEmpty) return '/';
    return '/${ location.split('/').where((s) => s.isNotEmpty).first}';
  }

  void _openCityDialog(BuildContext context) {
    showCitySelectionDialog(context);
  }
}
