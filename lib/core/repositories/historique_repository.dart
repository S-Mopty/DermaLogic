// DermaLogic v3 - HistoriqueRepository
//
// Persistance de l'historique des analyses IA.
// Fichier : historique.json
//
// Port de : Python core/historique.py

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/entree_historique.dart';

/// Repository pour l'historique des analyses.
class HistoriqueRepository {
  List<EntreeHistorique> _historique = [];
  late File _file;

  /// Charge historique.json depuis le dossier de donnees.
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/historique.json');
    _historique = await _load();
  }

  /// Lecture du fichier JSON.
  Future<List<EntreeHistorique>> _load() async {
    try {
      if (await _file.exists()) {
        final content = await _file.readAsString();
        final json = jsonDecode(content) as List<dynamic>;
        return json
            .map((e) => EntreeHistorique.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Historique] Erreur chargement: $e');
    }
    return [];
  }

  /// Ecriture du fichier JSON.
  Future<void> _save() async {
    try {
      final data = _historique.map((e) => e.toJson()).toList();
      final content = const JsonEncoder.withIndent('  ').convert(data);
      await _file.writeAsString(content);
    } catch (e) {
      // ignore: avoid_print
      print('[Historique] Erreur sauvegarde: $e');
    }
  }

  /// Retourne tout l'historique (plus recent en premier).
  List<EntreeHistorique> get tous {
    final sorted = List<EntreeHistorique>.from(_historique);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  /// Retourne les n dernieres analyses (plus recent en premier).
  List<EntreeHistorique> recents(int n) => tous.take(n).toList();

  /// Ajoute une entree dans l'historique et sauvegarde.
  Future<void> ajouter(EntreeHistorique entree) async {
    _historique.add(entree);
    await _save();
  }
}
