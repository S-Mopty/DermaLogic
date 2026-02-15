// DermaLogic v3 - ProduitRepository
//
// Persistance des produits dermatologiques.
// Fichier : produits_derma.json
//
// Port de : Python gui/data.py

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/produit_derma.dart';

/// Repository pour les produits dermatologiques.
class ProduitRepository {
  List<ProduitDerma> _produits = [];
  late File _file;

  /// Charge produits_derma.json depuis le dossier de donnees.
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/produits_derma.json');
    _produits = await _load();
  }

  /// Lecture du fichier JSON.
  Future<List<ProduitDerma>> _load() async {
    try {
      if (await _file.exists()) {
        final content = await _file.readAsString();
        final json = jsonDecode(content) as List<dynamic>;
        return json
            .map((e) => ProduitDerma.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Produits] Erreur chargement: $e');
    }
    return [];
  }

  /// Ecriture du fichier JSON.
  Future<void> _save() async {
    try {
      final data = _produits.map((e) => e.toJson()).toList();
      final content = const JsonEncoder.withIndent('  ').convert(data);
      await _file.writeAsString(content);
    } catch (e) {
      // ignore: avoid_print
      print('[Produits] Erreur sauvegarde: $e');
    }
  }

  /// Retourne une copie de la liste des produits.
  List<ProduitDerma> get tous => List.unmodifiable(_produits);

  /// Ajoute un produit et sauvegarde.
  Future<void> ajouter(ProduitDerma produit) async {
    _produits.add(produit);
    await _save();
  }

  /// Modifie un produit existant par son index et sauvegarde.
  Future<void> modifier(int index, ProduitDerma produit) async {
    if (index >= 0 && index < _produits.length) {
      _produits[index] = produit;
      await _save();
    }
  }

  /// Supprime un produit par son index et sauvegarde.
  Future<void> supprimer(int index) async {
    if (index >= 0 && index < _produits.length) {
      _produits.removeAt(index);
      await _save();
    }
  }
}
