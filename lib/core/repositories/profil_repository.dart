// DermaLogic v3 - ProfilRepository
//
// Persistance du profil utilisateur.
// Fichier : profile.json
//
// Port de : Python core/profil.py

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/profil_utilisateur.dart';

/// Repository pour le profil utilisateur.
class ProfilRepository {
  ProfilUtilisateur _profil = ProfilUtilisateur();
  late File _file;

  /// Charge profile.json depuis le dossier de donnees.
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/profile.json');
    _profil = await _load();
  }

  /// Lecture du fichier JSON.
  Future<ProfilUtilisateur> _load() async {
    try {
      if (await _file.exists()) {
        final content = await _file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        return ProfilUtilisateur.fromJson(json);
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Profil] Erreur chargement: $e');
    }
    return ProfilUtilisateur();
  }

  /// Ecriture du fichier JSON.
  Future<void> _save() async {
    try {
      final content = const JsonEncoder.withIndent('  ').convert(_profil.toJson());
      await _file.writeAsString(content);
    } catch (e) {
      // ignore: avoid_print
      print('[Profil] Erreur sauvegarde: $e');
    }
  }

  /// Retourne le profil actuel.
  ProfilUtilisateur get profil => _profil;

  /// Sauvegarde un nouveau profil.
  Future<void> save(ProfilUtilisateur profil) async {
    _profil = profil;
    await _save();
  }
}
