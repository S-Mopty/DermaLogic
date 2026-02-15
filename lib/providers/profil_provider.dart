// DermaLogic v3 - Profil Provider
//
// Riverpod AsyncNotifier pour le profil utilisateur.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/profil_utilisateur.dart';
import '../core/repositories/profil_repository.dart';

/// Repository singleton.
final profilRepositoryProvider = Provider<ProfilRepository>((ref) {
  return ProfilRepository();
});

/// Provider pour le profil utilisateur.
final profilProvider =
    AsyncNotifierProvider<ProfilNotifier, ProfilUtilisateur>(
        ProfilNotifier.new);

class ProfilNotifier extends AsyncNotifier<ProfilUtilisateur> {
  late ProfilRepository _repo;

  @override
  Future<ProfilUtilisateur> build() async {
    _repo = ref.read(profilRepositoryProvider);
    await _repo.init();
    return _repo.profil;
  }

  /// Sauvegarde un nouveau profil.
  Future<void> save(ProfilUtilisateur profil) async {
    await _repo.save(profil);
    state = AsyncData(_repo.profil);
  }
}
