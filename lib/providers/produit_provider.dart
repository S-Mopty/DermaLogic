// DermaLogic v3 - Produit Provider
//
// Riverpod AsyncNotifier pour les produits dermatologiques.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/produit_derma.dart';
import '../core/repositories/produit_repository.dart';

/// Repository singleton.
final produitRepositoryProvider = Provider<ProduitRepository>((ref) {
  return ProduitRepository();
});

/// Provider pour la liste des produits.
final produitProvider =
    AsyncNotifierProvider<ProduitNotifier, List<ProduitDerma>>(
        ProduitNotifier.new);

class ProduitNotifier extends AsyncNotifier<List<ProduitDerma>> {
  late ProduitRepository _repo;

  @override
  Future<List<ProduitDerma>> build() async {
    _repo = ref.read(produitRepositoryProvider);
    await _repo.init();
    return _repo.tous;
  }

  /// Ajoute un produit.
  Future<void> ajouter(ProduitDerma produit) async {
    await _repo.ajouter(produit);
    state = AsyncData(_repo.tous);
  }

  /// Modifie un produit par son index.
  Future<void> modifier(int index, ProduitDerma produit) async {
    await _repo.modifier(index, produit);
    state = AsyncData(_repo.tous);
  }

  /// Supprime un produit par son index.
  Future<void> supprimer(int index) async {
    await _repo.supprimer(index);
    state = AsyncData(_repo.tous);
  }
}
