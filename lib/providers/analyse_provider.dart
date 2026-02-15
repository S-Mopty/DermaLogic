// DermaLogic v3 - Analyse Provider
//
// Riverpod AsyncNotifier pour lancer les analyses IA.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/donnees_environnement.dart';
import '../core/services/analyseur_service.dart';
import '../core/services/gemini_service.dart';
import 'historique_provider.dart';
import 'produit_provider.dart';
import 'profil_provider.dart';
import 'settings_provider.dart';

/// Provider pour le resultat d'analyse.
final analyseProvider =
    AsyncNotifierProvider<AnalyseNotifier, Map<String, dynamic>?>(
        AnalyseNotifier.new);

class AnalyseNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() async {
    // Pas d'analyse au demarrage
    return null;
  }

  /// Lance une analyse complete.
  Future<void> lancer({
    required DonneesEnvironnementales conditionsActuelles,
    required List<PrevisionJournaliere> previsions,
    String ville = '',
    String mode = 'rapide',
    String instructionsJour = '',
    int? niveauStressJour,
  }) async {
    state = const AsyncLoading();

    try {
      // Recuperer les dependances
      final settings = await ref.read(settingsProvider.future);
      final gemini = GeminiService(apiKey: settings.geminiApiKey);

      final analyseur = AnalyseurService(
        produits: ref.read(produitRepositoryProvider),
        profil: ref.read(profilRepositoryProvider),
        historique: ref.read(historiqueRepositoryProvider),
        gemini: gemini,
      );

      final resultat = await analyseur.analyser(
        conditionsActuelles: conditionsActuelles,
        previsions: previsions,
        ville: ville,
        mode: mode,
        instructionsJour: instructionsJour,
        niveauStressJour: niveauStressJour,
      );

      state = AsyncData(resultat);

      // Rafraichir l'historique apres l'analyse
      ref.invalidate(historiqueProvider);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
