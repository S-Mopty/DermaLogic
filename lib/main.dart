import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/router/app_router.dart';
import 'ui/theme/app_theme.dart';
import 'utils/test_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les donnees de test (ne fait rien si les fichiers existent deja)
  await seedTestData();

  runApp(const ProviderScope(child: DermaLogicApp()));
}

class DermaLogicApp extends ConsumerWidget {
  const DermaLogicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'DermaLogic v3',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
