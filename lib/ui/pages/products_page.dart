import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/produit_derma.dart';
import '../../providers/produit_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/constants.dart';
import '../components/product_card.dart';
import '../dialogs/ai_search_dialog.dart';
import '../dialogs/product_form_dialog.dart';

/// Page de gestion des produits.
class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produitsAsync = ref.watch(produitProvider);
    return produitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
      data: (produits) => _buildContent(context, ref, produits),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<ProduitDerma> produits) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          const Expanded(child: Text('Mes Produits',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          Text('${produits.length} produit${produits.length > 1 ? 's' : ''}',
              style: const TextStyle(color: AppColors.texteSecondaire)),
        ]),
        const SizedBox(height: 12),

        // Boutons
        Wrap(spacing: 8, runSpacing: 8, children: [
          ElevatedButton.icon(
            onPressed: () {
              final hasKey = ref.read(settingsProvider).whenOrNull(
                  data: (s) => s.geminiApiKey.isNotEmpty) ?? false;
              if (!hasKey) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Configurez la cle API dans les parametres')));
                return;
              }
              showAiSearchDialog(context);
            },
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('+ Ajouter avec IA'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.violet, foregroundColor: Colors.white),
          ),
          ElevatedButton.icon(
            onPressed: () => showProductFormDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('+ Ajouter'),
          ),
        ]),
        const SizedBox(height: 20),

        if (produits.isEmpty)
          Container(
            width: double.infinity, padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: AppColors.panneau, borderRadius: BorderRadius.circular(15)),
            child: const Text(
              'Aucun produit enregistre\n\nCliquez sur \'+ Ajouter\'\npour commencer',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.texteSecondaire, fontSize: 14)),
          )
        else
          _groupedList(context, ref, produits),
      ]),
    );
  }

  Widget _groupedList(BuildContext context, WidgetRef ref, List<ProduitDerma> produits) {
    final groups = <String, List<MapEntry<int, ProduitDerma>>>{};
    for (var i = 0; i < produits.length; i++) {
      groups.putIfAbsent(produits[i].moment.value, () => []).add(MapEntry(i, produits[i]));
    }

    final widgets = <Widget>[];
    for (final moment in ['matin', 'journee', 'soir', 'tous']) {
      final items = groups[moment];
      if (items == null || items.isEmpty) continue;
      final color = AppColors.couleurMoment[moment] ?? AppColors.accent;
      final label = AppColors.labelMoment[moment] ?? moment.toUpperCase();

      widgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 12),
        child: Row(children: [
          Container(width: 6, height: 25,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          const Spacer(),
          Text('${items.length} produit${items.length > 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 11, color: AppColors.texteSecondaire)),
        ]),
      ));

      for (final entry in items) {
        widgets.add(ProductCard(
          product: entry.value,
          onEdit: () => showProductFormDialog(context,
              initialProduct: entry.value, editIndex: entry.key),
          onDelete: () => _confirmDelete(context, ref, entry.key, entry.value),
        ));
      }
    }
    return Column(children: widgets);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int index, ProduitDerma product) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Supprimer le produit ?'),
      content: Text('Voulez-vous vraiment supprimer "${product.nom}" ?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        TextButton(
          onPressed: () { ref.read(produitProvider.notifier).supprimer(index); Navigator.pop(context); },
          style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          child: const Text('Supprimer')),
      ],
    ));
  }
}
