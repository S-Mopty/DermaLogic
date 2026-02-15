// DermaLogic v3 - SettingsRepository
//
// Persistance des parametres (cle API Gemini).
// Fichier : settings.json
//
// Port de : Python core/settings.py

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/settings.dart';

/// Repository pour les parametres de l'application.
class SettingsRepository {
  Settings _settings = Settings();
  late File _file;

  /// Charge settings.json depuis le dossier de donnees.
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/settings.json');
    _settings = await _load();
  }

  /// Lecture du fichier JSON.
  Future<Settings> _load() async {
    try {
      if (await _file.exists()) {
        final content = await _file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return Settings.fromJson(json);
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Settings] Erreur chargement: $e');
    }
    return Settings();
  }

  /// Ecriture du fichier JSON.
  Future<void> _save() async {
    try {
      final content = const JsonEncoder.withIndent('  ').convert(_settings.toJson());
      await _file.writeAsString(content);
    } catch (e) {
      // ignore: avoid_print
      print('[Settings] Erreur sauvegarde: $e');
    }
  }

  /// Retourne les parametres actuels.
  Settings get settings => _settings;

  /// Retourne la cle API Gemini.
  String get geminiKey => _settings.geminiApiKey;

  /// Sauvegarde une nouvelle cle API Gemini.
  Future<void> saveGeminiKey(String key) async {
    _settings = _settings.copyWith(geminiApiKey: key);
    await _save();
  }
}
