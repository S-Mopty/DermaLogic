import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: DermaLogicApp()));
}

class DermaLogicApp extends StatelessWidget {
  const DermaLogicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DermaLogic v3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4ECCA3),
          error: Color(0xFFE94560),
          surface: Color(0xFF16213E),
        ),
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'DermaLogic v3\nMigration Flutter en cours...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Color(0xFF4ECCA3)),
          ),
        ),
      ),
    );
  }
}
