// DermaLogic v3 - Meteo Provider
//
// Riverpod AsyncNotifier pour les donnees meteo.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/donnees_environnement.dart';
import '../core/services/meteo_service.dart';
import 'config_provider.dart';

/// Service meteo singleton.
final meteoServiceProvider = Provider<MeteoService>((ref) {
  return MeteoService();
});

/// Provider pour les donnees environnementales.
final meteoProvider =
    AsyncNotifierProvider<MeteoNotifier, DonneesEnvironnementales?>(
        MeteoNotifier.new);

class MeteoNotifier extends AsyncNotifier<DonneesEnvironnementales?> {
  late MeteoService _service;

  @override
  Future<DonneesEnvironnementales?> build() async {
    _service = ref.read(meteoServiceProvider);

    // Ecouter les changements de config pour mettre a jour la localisation
    final config = await ref.watch(configProvider.future);
    _service.latitude = config.villeActuelle.latitude;
    _service.longitude = config.villeActuelle.longitude;
    _service.nomVille = config.villeActuelle.toString();

    return _service.obtenirDonneesJour();
  }

  /// Rafraichit les donnees meteo.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _service.obtenirDonneesJour());
  }

  /// Retourne les previsions sur 3 jours.
  Future<List<PrevisionJournaliere>> obtenirPrevisions() {
    return _service.obtenirPrevisions3Jours();
  }
}
