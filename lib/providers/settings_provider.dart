// DermaLogic v3 - Settings Provider
//
// Riverpod AsyncNotifier pour les parametres (cle API Gemini).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/settings.dart';
import '../core/repositories/settings_repository.dart';

/// Repository singleton.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// Provider pour les parametres de l'application.
final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

class SettingsNotifier extends AsyncNotifier<Settings> {
  late SettingsRepository _repo;

  @override
  Future<Settings> build() async {
    _repo = ref.read(settingsRepositoryProvider);
    await _repo.init();
    return _repo.settings;
  }

  /// Sauvegarde la cle API Gemini.
  Future<void> saveGeminiKey(String key) async {
    await _repo.saveGeminiKey(key);
    state = AsyncData(_repo.settings);
  }

  /// Retourne la cle API Gemini actuelle.
  String get geminiKey => _repo.geminiKey;
}
