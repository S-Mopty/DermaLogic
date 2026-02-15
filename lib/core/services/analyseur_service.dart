// DermaLogic v3 - AnalyseurService
//
// Orchestrateur d'analyse dermatologique par IA.
// Pipeline : collecte contexte -> appel Gemini -> sauvegarde historique.
//
// Port de : Python core/analyseur.py

import 'package:uuid/uuid.dart';

import '../models/donnees_environnement.dart';
import '../models/entree_historique.dart';
import '../repositories/historique_repository.dart';
import '../repositories/produit_repository.dart';
import '../repositories/profil_repository.dart';
import 'gemini_service.dart';

/// Orchestrateur d'analyse dermatologique par IA.
class AnalyseurService {
  final ProduitRepository produits;
  final ProfilRepository profil;
  final HistoriqueRepository historique;
  final GeminiService gemini;

  AnalyseurService({
    required this.produits,
    required this.profil,
    required this.historique,
    required this.gemini,
  });

  /// Lance une analyse complete.
  ///
  /// Pipeline :
  /// 1. Recupere produits, profil, historique recent (3)
  /// 2. Envoie tout le contexte a Gemini 2.5 Flash
  /// 3. Sauvegarde le resultat dans l'historique
  /// 4. Retourne le resultat pour l'UI
  Future<Map<String, dynamic>> analyser({
    required DonneesEnvironnementales conditionsActuelles,
    required List<PrevisionJournaliere> previsions,
    String ville = '',
    String mode = 'rapide',
    String instructionsJour = '',
    int? niveauStressJour,
  }) async {
    // 1. Collecter le contexte
    final listeProduits = produits.tous;
    final profilUtilisateur = profil.profil;
    final historiqueRecent = historique.recents(3);

    // 2. Appeler Gemini
    final resultat = await gemini.analyserRoutine(
      produits: listeProduits,
      conditionsActuelles: conditionsActuelles,
      previsions: previsions,
      profil: profilUtilisateur,
      historiqueRecent: historiqueRecent,
      ville: ville,
      mode: mode,
      instructionsJour: instructionsJour,
      niveauStressJour: niveauStressJour,
    );

    // 3. Sauvegarder dans l'historique (sauf si erreur)
    if (!resultat.containsKey('erreur')) {
      final entree = EntreeHistorique(
        id: const Uuid().v4(),
        date: DateTime.now().toIso8601String(),
        mode: mode,
        resumeIa: resultat['resume'] as String? ?? '',
        routineMatin: _parseRoutineList(resultat['routine_matin']),
        routineSoir: _parseRoutineList(resultat['routine_soir']),
        alertes: (resultat['alertes'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        conseilsJour: resultat['conseils_jour'] as String? ?? '',
        activitesJour: (resultat['activites_jour'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
      await historique.ajouter(entree);
    }

    return resultat;
  }

  /// Parse une liste de routines depuis la reponse Gemini.
  List<Map<String, dynamic>> _parseRoutineList(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map((e) {
      if (e is Map) return Map<String, dynamic>.from(e);
      return <String, dynamic>{'produit': e.toString(), 'raison': ''};
    }).toList();
  }
}
