import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/history_page.dart';
import '../pages/home_page.dart';
import '../pages/products_page.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';
import '../shell/app_shell.dart';

/// Provider GoRouter pour la navigation.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/produits',
            builder: (context, state) => const ProductsPage(),
          ),
          GoRoute(
            path: '/profil',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/historique',
            builder: (context, state) => const HistoryPage(),
          ),
          GoRoute(
            path: '/parametres',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
});
