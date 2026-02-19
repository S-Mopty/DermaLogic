import 'package:flutter/material.dart';

import '../../core/models/produit_derma.dart';
import '../../utils/constants.dart';

/// Carte d'un produit avec bande de categorie, badges et actions.
class ProductCard extends StatelessWidget {
  final ProduitDerma product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final catColor =
        AppColors.couleurCategorie[product.category.value] ?? AppColors.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.carte,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Bande couleur categorie
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: catColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom
                    Text(
                      product.nom,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _badge(
                          _categoryLabel(product.category),
                          catColor,
                        ),
                        if (product.photosensitive)
                          _badge('PHOTOSENSIBLE', AppColors.danger),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Details
                    Text(
                      'Occlusivite: ${product.occlusivity}/5 | '
                      'Nettoyage: ${product.cleansingPower}/5 | '
                      '${_activeLabel(product.activeTag)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.texteSecondaire,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: AppColors.accent, size: 20),
                  tooltip: 'Modifier',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: AppColors.danger, size: 20),
                  tooltip: 'Supprimer',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _categoryLabel(Categorie cat) {
    switch (cat) {
      case Categorie.cleanser:
        return 'Nettoyant';
      case Categorie.treatment:
        return 'Traitement';
      case Categorie.moisturizer:
        return 'Hydratant';
      case Categorie.protection:
        return 'Protection';
    }
  }

  String _activeLabel(ActiveTag tag) {
    switch (tag) {
      case ActiveTag.hydration:
        return 'Hydratation';
      case ActiveTag.acne:
        return 'Anti-acne';
      case ActiveTag.repair:
        return 'Reparation';
    }
  }
}
