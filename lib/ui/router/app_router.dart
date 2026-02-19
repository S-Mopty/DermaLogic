import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/history_page.dart';
import '../pages/home_page.dart';
import '../pages/products_page.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';
import '../shell/app_shell.dart';

/// Transition de page douce (fade).
CustomTransitionPage<void> _fadePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 200),
  );
}

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
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              child: const HomePage(),
            ),
          ),
          GoRoute(
            path: '/produits',
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              child: const ProductsPage(),
            ),
          ),
          GoRoute(
            path: '/profil',
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              child: const ProfilePage(),
            ),
          ),
          GoRoute(
            path: '/historique',
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              child: const HistoryPage(),
            ),
          ),
          GoRoute(
            path: '/parametres',
            pageBuilder: (context, state) => _fadePage(
              key: state.pageKey,
              child: const SettingsPage(),
            ),
          ),
        ],
      ),
    ],
  );
});
