// DermaLogic v3 - ConfigRepository
//
// Persistance de la configuration (ville actuelle + favoris).
// Fichier : config.json
//
// Port de : Python core/config.py L106-252

import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../models/ville_config.dart';

/// Repository pour la configuration de l'application.
class ConfigRepository {
  Configuration _config = Configuration();
  late File _file;

  /// Charge config.json depuis le dossier de donnees.
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/config.json');
    _config = await _load();
  }

  /// Lecture du fichier JSON.
  Future<Configuration> _load() async {
    try {
      if (await _file.exists()) {
        final content = await _file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return Configuration.fromJson(json);
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Config] Erreur chargement: $e');
    }
    return Configuration();
  }

  /// Ecriture du fichier JSON.
  Future<void> _save() async {
    try {
      final content = const JsonEncoder.withIndent('  ').convert(_config.toJson());
      await _file.writeAsString(content);
    } catch (e) {
      // ignore: avoid_print
      print('[Config] Erreur sauvegarde: $e');
    }
  }

  // =========================================================================
  // VILLE ACTUELLE
  // =========================================================================

  /// Retourne la ville actuelle.
  VilleConfig get villeActuelle => _config.villeActuelle;

  /// Definit la ville actuelle et sauvegarde.
  Future<void> setVilleActuelle(VilleConfig ville) async {
    _config = _config.copyWith(villeActuelle: ville);
    await _save();
  }

  /// Met a jour les donnees meteo de la ville actuelle.
  Future<void> updateMeteoActuelle({
    required double indiceUv,
    required double humidite,
    required double temperature,
    double? pm25,
  }) async {
    final ville = _config.villeActuelle.copyWith(
      indiceUv: indiceUv,
      humidite: humidite,
      temperature: temperature,
      pm25: pm25,
      derniereMaj: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    );
    _config = _config.copyWith(villeActuelle: ville);
    await _save();
  }

  // =========================================================================
  // FAVORIS
  // =========================================================================

  /// Retourne la liste des villes favorites.
  List<VilleConfig> get favorites => List.unmodifiable(_config.villesFavorites);

  /// Verifie si une ville est en favoris.
  bool isFavorite(String nom, String pays) {
    return _config.villesFavorites.any((v) => v.nom == nom && v.pays == pays);
  }

  /// Ajoute une ville aux favoris.
  Future<void> addFavorite(VilleConfig ville) async {
    if (!isFavorite(ville.nom, ville.pays)) {
      _config = _config.copyWith(
        villesFavorites: [..._config.villesFavorites, ville],
      );
      await _save();
    }
  }

  /// Supprime une ville des favoris.
  Future<void> removeFavorite(String nom, String pays) async {
    _config = _config.copyWith(
      villesFavorites: _config.villesFavorites
          .where((v) => !(v.nom == nom && v.pays == pays))
          .toList(),
    );
    await _save();
  }

  /// Bascule l'etat favori d'une ville. Retourne true si ajoute, false si supprime.
  Future<bool> toggleFavorite(VilleConfig ville) async {
    if (isFavorite(ville.nom, ville.pays)) {
      await removeFavorite(ville.nom, ville.pays);
      return false;
    } else {
      await addFavorite(ville);
      return true;
    }
  }

  /// Met a jour les donnees meteo d'une ville favorite.
  Future<void> updateMeteoFavorite({
    required String nom,
    required String pays,
    required double indiceUv,
    required double humidite,
    required double temperature,
    double? pm25,
  }) async {
    final updatedFavorites = _config.villesFavorites.map((v) {
      if (v.nom == nom && v.pays == pays) {
        return v.copyWith(
          indiceUv: indiceUv,
          humidite: humidite,
          temperature: temperature,
          pm25: pm25,
          derniereMaj: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        );
      }
      return v;
    }).toList();
    _config = _config.copyWith(villesFavorites: updatedFavorites);
    await _save();
  }
}
