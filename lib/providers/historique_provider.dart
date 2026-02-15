// DermaLogic v3 - Historique Provider
//
// Riverpod AsyncNotifier pour l'historique des analyses.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/entree_historique.dart';
import '../core/repositories/historique_repository.dart';

/// Repository singleton.
final historiqueRepositoryProvider = Provider<HistoriqueRepository>((ref) {
  return HistoriqueRepository();
});

/// Provider pour l'historique des analyses.
final historiqueProvider =
    AsyncNotifierProvider<HistoriqueNotifier, List<EntreeHistorique>>(
        HistoriqueNotifier.new);

class HistoriqueNotifier extends AsyncNotifier<List<EntreeHistorique>> {
  late HistoriqueRepository _repo;

  @override
  Future<List<EntreeHistorique>> build() async {
    _repo = ref.read(historiqueRepositoryProvider);
    await _repo.init();
    return _repo.tous;
  }

  /// Ajoute une entree dans l'historique.
  Future<void> ajouter(EntreeHistorique entree) async {
    await _repo.ajouter(entree);
    state = AsyncData(_repo.tous);
  }

  /// Retourne les n dernieres analyses.
  List<EntreeHistorique> recents(int n) => _repo.recents(n);
}
