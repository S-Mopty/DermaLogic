import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/donnees_environnement.dart';
import '../../core/models/ville_config.dart';
import '../../core/services/meteo_service.dart';
import '../../providers/config_provider.dart';
import '../../utils/constants.dart';

/// Affiche le dialog de selection de ville.
Future<void> showCitySelectionDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => const CitySelectionDialog(),
  );
}

/// Dialog de recherche et selection de ville avec onglets Rechercher / Favoris.
class CitySelectionDialog extends ConsumerStatefulWidget {
  const CitySelectionDialog({super.key});

  @override
  ConsumerState<CitySelectionDialog> createState() =>
      _CitySelectionDialogState();
}

class _CitySelectionDialogState extends ConsumerState<CitySelectionDialog> {
  int _tabIndex = 0; // 0 = Rechercher, 1 = Favoris
  final _searchCtrl = TextEditingController();
  List<Localisation> _results = [];
  bool _searching = false;
  String? _searchError;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final dialogWidth = (screenWidth * 0.9).clamp(0.0, 450.0);
    final dialogHeight = (screenHeight * 0.8).clamp(0.0, 500.0);

    final configAsync = ref.watch(configProvider);
    final config = configAsync.valueOrNull;

    return Dialog(
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ville actuelle
              if (config != null) _currentCityBar(config),
              const SizedBox(height: 12),

              // Onglets
              _tabButtons(),
              const SizedBox(height: 12),

              // Contenu
              Expanded(
                child: _tabIndex == 0
                    ? _searchTab()
                    : _favoritesTab(config),
              ),

              // Fermer
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer',
                      style: TextStyle(color: AppColors.texteSecondaire)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _currentCityBar(Configuration config) {
    final ville = config.villeActuelle;
    final isFav = config.villesFavorites.any(
        (v) => v.nom == ville.nom && v.pays == ville.pays);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.carte,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Text(
            'Ville actuelle:',
            style: TextStyle(fontSize: 12, color: AppColors.texteSecondaire),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ville.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              final villeConfig = VilleConfig(
                nom: ville.nom,
                pays: ville.pays,
                latitude: ville.latitude,
                longitude: ville.longitude,
              );
              await ref.read(configProvider.notifier).toggleFavorite(villeConfig);
            },
            icon: Icon(
              isFav ? Icons.star : Icons.star_border,
              color: AppColors.etoile,
            ),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _tabButtons() {
    return Row(
      children: [
        _tabButton('Rechercher', 0),
        const SizedBox(width: 8),
        _tabButton('Favoris', 1),
      ],
    );
  }

  Widget _tabButton(String label, int index) {
    final isActive = _tabIndex == index;
    return Expanded(
      child: TextButton(
        onPressed: () => setState(() => _tabIndex = index),
        style: TextButton.styleFrom(
          backgroundColor: isActive ? AppColors.accent : Colors.transparent,
          foregroundColor: isActive ? AppColors.fond : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      ),
    );
  }

  // ============================================================
  // TAB RECHERCHER
  // ============================================================
  Widget _searchTab() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ex: Lyon, Marseille, Bordeaux...',
                  isDense: true,
                ),
                onSubmitted: (_) => _doSearch(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _searching ? null : _doSearch,
              child: Text(_searching ? '...' : 'Rechercher'),
            ),
          ],
        ),
        if (_searchError != null) ...[
          const SizedBox(height: 8),
          Text(_searchError!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
        ],
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _results.length,
            itemBuilder: (_, i) => _searchResultCard(_results[i]),
          ),
        ),
      ],
    );
  }

  Future<void> _doSearch() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final results = await MeteoService.rechercherVilles(query);
      setState(() {
        _results = results;
        _searching = false;
        if (results.isEmpty) _searchError = 'Aucun resultat pour "$query"';
      });
    } catch (e) {
      setState(() {
        _searching = false;
        _searchError = 'Erreur: $e';
      });
    }
  }

  Widget _searchResultCard(Localisation loc) {
    final config = ref.watch(configProvider).valueOrNull;
    final isFav = config?.villesFavorites.any(
            (v) => v.nom == loc.nom && v.pays == loc.pays) ??
        false;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.carte,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              final villeConfig = VilleConfig(
                nom: loc.nom,
                pays: loc.pays,
                latitude: loc.latitude,
                longitude: loc.longitude,
              );
              await ref.read(configProvider.notifier).toggleFavorite(villeConfig);
            },
            icon: Icon(
              isFav ? Icons.star : Icons.star_border,
              color: AppColors.etoile,
              size: 20,
            ),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.nom,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${loc.pays} (${loc.latitude.toStringAsFixed(2)}, ${loc.longitude.toStringAsFixed(2)})',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.texteSecondaire,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: () => _selectCity(loc),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Choisir'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB FAVORIS
  // ============================================================
  Widget _favoritesTab(Configuration? config) {
    final favorites = config?.villesFavorites ?? [];
    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          'Aucune ville favorite\n\nRecherchez une ville et cliquez\nsur l\'etoile pour l\'ajouter',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.texteSecondaire),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Donnees meteo en cache - pas de connexion requise',
          style: TextStyle(fontSize: 11, color: AppColors.violet),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (_, i) => _favoriteCard(favorites[i]),
          ),
        ),
      ],
    );
  }

  Widget _favoriteCard(VilleConfig ville) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.carte,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              await ref.read(configProvider.notifier).toggleFavorite(ville);
            },
            icon: const Icon(Icons.star, color: AppColors.etoile, size: 20),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ville.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'UV: ${ville.indiceUv.toStringAsFixed(1)} | '
                  'H: ${ville.humidite.toStringAsFixed(0)}% | '
                  'T: ${ville.temperature.toStringAsFixed(1)}C'
                  '${ville.pm25 != null ? ' | PM2.5: ${ville.pm25!.toStringAsFixed(0)}' : ''}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.texteSecondaire,
                  ),
                ),
                Text(
                  ville.derniereMaj.isNotEmpty
                      ? 'Mis a jour: ${ville.derniereMaj}'
                      : 'Pas encore de donnees',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.texteSecondaire,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 30,
            child: ElevatedButton(
              onPressed: () => _selectFavorite(ville),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Choisir'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELECTION
  // ============================================================
  Future<void> _selectCity(Localisation loc) async {
    final ville = VilleConfig(
      nom: loc.nom,
      pays: loc.pays,
      latitude: loc.latitude,
      longitude: loc.longitude,
    );
    await ref.read(configProvider.notifier).setVilleActuelle(ville);
    // Meteo se rafraichit automatiquement via le watch dans meteoProvider
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _selectFavorite(VilleConfig ville) async {
    await ref.read(configProvider.notifier).setVilleActuelle(ville);
    // Mettre a jour les donnees meteo avec le cache du favori
    await ref.read(configProvider.notifier).updateMeteoActuelle(
          indiceUv: ville.indiceUv,
          humidite: ville.humidite,
          temperature: ville.temperature,
          pm25: ville.pm25,
        );
    if (mounted) Navigator.of(context).pop();
  }
}
