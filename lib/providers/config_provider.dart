// DermaLogic v3 - Config Provider
//
// Riverpod AsyncNotifier pour la configuration (ville + favoris).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/ville_config.dart';
import '../core/repositories/config_repository.dart';

/// Repository singleton.
final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  return ConfigRepository();
});

/// Provider pour la configuration de l'application.
final configProvider =
    AsyncNotifierProvider<ConfigNotifier, Configuration>(ConfigNotifier.new);

class ConfigNotifier extends AsyncNotifier<Configuration> {
  late ConfigRepository _repo;

  @override
  Future<Configuration> build() async {
    _repo = ref.read(configRepositoryProvider);
    await _repo.init();
    return Configuration(
      villeActuelle: _repo.villeActuelle,
      villesFavorites: _repo.favorites,
    );
  }

  /// Definit la ville actuelle.
  Future<void> setVilleActuelle(VilleConfig ville) async {
    await _repo.setVilleActuelle(ville);
    state = AsyncData(Configuration(
      villeActuelle: _repo.villeActuelle,
      villesFavorites: _repo.favorites,
    ));
  }

  /// Met a jour les donnees meteo de la ville actuelle.
  Future<void> updateMeteoActuelle({
    required double indiceUv,
    required double humidite,
    required double temperature,
    double? pm25,
  }) async {
    await _repo.updateMeteoActuelle(
      indiceUv: indiceUv,
      humidite: humidite,
      temperature: temperature,
      pm25: pm25,
    );
    state = AsyncData(Configuration(
      villeActuelle: _repo.villeActuelle,
      villesFavorites: _repo.favorites,
    ));
  }

  /// Bascule l'etat favori d'une ville.
  Future<bool> toggleFavorite(VilleConfig ville) async {
    final added = await _repo.toggleFavorite(ville);
    state = AsyncData(Configuration(
      villeActuelle: _repo.villeActuelle,
      villesFavorites: _repo.favorites,
    ));
    return added;
  }
}
