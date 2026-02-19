import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/produit_derma.dart';
import '../../providers/produit_provider.dart';
import '../../utils/constants.dart';

/// Affiche le formulaire produit en dialog.
Future<void> showProductFormDialog(
  BuildContext context, {
  ProduitDerma? initialProduct,
  int? editIndex,
  bool fromAi = false,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => ProductFormDialog(
      initialProduct: initialProduct,
      editIndex: editIndex,
      fromAi: fromAi,
    ),
  );
}

/// Formulaire d'ajout / modification de produit.
class ProductFormDialog extends ConsumerStatefulWidget {
  final ProduitDerma? initialProduct;
  final int? editIndex;
  final bool fromAi;

  const ProductFormDialog({
    super.key,
    this.initialProduct,
    this.editIndex,
    this.fromAi = false,
  });

  bool get isEditing => editIndex != null;

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  late TextEditingController _nomCtrl;
  late Categorie _category;
  late MomentUtilisation _moment;
  late bool _photosensitive;
  late double _occlusivity;
  late double _cleansingPower;
  late ActiveTag _activeTag;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProduct;
    _nomCtrl = TextEditingController(text: p?.nom ?? '');
    _category = p?.category ?? Categorie.moisturizer;
    _moment = p?.moment ?? MomentUtilisation.tous;
    _photosensitive = p?.photosensitive ?? false;
    _occlusivity = (p?.occlusivity ?? 3).toDouble();
    _cleansingPower = (p?.cleansingPower ?? 3).toDouble();
    _activeTag = p?.activeTag ?? ActiveTag.hydration;
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final dialogWidth = (screenWidth * 0.9).clamp(0.0, 400.0);
    final dialogHeight = (screenHeight * 0.8).clamp(0.0, 520.0);

    String title;
    if (widget.isEditing) {
      title = 'Modifier le Produit';
    } else if (widget.fromAi) {
      title = 'Nouveau Produit (IA)';
    } else {
      title = 'Nouveau Produit';
    }

    return Dialog(
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (widget.fromAi) ...[
                const SizedBox(height: 4),
                const Text(
                  'Verifie les informations avant d\'ajouter',
                  style: TextStyle(fontSize: 12, color: AppColors.violet),
                ),
              ],
              const SizedBox(height: 16),

              // Formulaire scrollable
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom
                      TextField(
                        controller: _nomCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nom',
                          hintText: 'Ex: Mon Serum Niacinamide',
                          errorText: _nameError,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Categorie
                      DropdownButtonFormField<Categorie>(
                        initialValue: _category,
                        decoration: const InputDecoration(labelText: 'Categorie'),
                        dropdownColor: AppColors.panneau,
                        items: const [
                          DropdownMenuItem(value: Categorie.cleanser, child: Text('Nettoyant')),
                          DropdownMenuItem(value: Categorie.treatment, child: Text('Traitement')),
                          DropdownMenuItem(value: Categorie.moisturizer, child: Text('Hydratant')),
                          DropdownMenuItem(value: Categorie.protection, child: Text('Protection')),
                        ],
                        onChanged: (v) => setState(() => _category = v!),
                      ),
                      const SizedBox(height: 14),

                      // Moment
                      DropdownButtonFormField<MomentUtilisation>(
                        initialValue: _moment,
                        decoration: const InputDecoration(labelText: 'Moment d\'utilisation'),
                        dropdownColor: AppColors.panneau,
                        items: const [
                          DropdownMenuItem(value: MomentUtilisation.matin, child: Text('Matin')),
                          DropdownMenuItem(value: MomentUtilisation.journee, child: Text('Journee')),
                          DropdownMenuItem(value: MomentUtilisation.soir, child: Text('Soir')),
                          DropdownMenuItem(value: MomentUtilisation.tous, child: Text('Tous moments')),
                        ],
                        onChanged: (v) => setState(() => _moment = v!),
                      ),
                      const SizedBox(height: 14),

                      // Photosensible
                      SwitchListTile(
                        title: const Text('Photosensible (reagit aux UV)', style: TextStyle(fontSize: 14)),
                        value: _photosensitive,
                        activeThumbColor: AppColors.danger,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (v) => setState(() => _photosensitive = v),
                      ),
                      const SizedBox(height: 8),

                      // Occlusivite
                      _sliderField(
                        'Occlusivite (1=leger, 5=riche)',
                        _occlusivity,
                        AppColors.accent,
                        (v) => setState(() => _occlusivity = v),
                      ),
                      const SizedBox(height: 8),

                      // Nettoyage
                      _sliderField(
                        'Pouvoir nettoyant (1=doux, 5=fort)',
                        _cleansingPower,
                        const Color(0xFF00B4D8),
                        (v) => setState(() => _cleansingPower = v),
                      ),
                      const SizedBox(height: 14),

                      // Action principale
                      DropdownButtonFormField<ActiveTag>(
                        initialValue: _activeTag,
                        decoration: const InputDecoration(labelText: 'Action principale'),
                        dropdownColor: AppColors.panneau,
                        items: const [
                          DropdownMenuItem(value: ActiveTag.hydration, child: Text('Hydratation')),
                          DropdownMenuItem(value: ActiveTag.acne, child: Text('Anti-acne')),
                          DropdownMenuItem(value: ActiveTag.repair, child: Text('Reparation')),
                        ],
                        onChanged: (v) => setState(() => _activeTag = v!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(widget.isEditing ? 'Modifier' : 'Ajouter'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sliderField(
    String label,
    double value,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 13)),
            ),
            Text(
              '${value.round()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _submit() {
    final nom = _nomCtrl.text.trim();
    if (nom.isEmpty) {
      setState(() => _nameError = 'Le nom est requis');
      return;
    }
    setState(() => _nameError = null);

    final produit = ProduitDerma(
      nom: nom,
      category: _category,
      moment: _moment,
      photosensitive: _photosensitive,
      occlusivity: _occlusivity.round(),
      cleansingPower: _cleansingPower.round(),
      activeTag: _activeTag,
    );

    final notifier = ref.read(produitProvider.notifier);
    if (widget.isEditing) {
      notifier.modifier(widget.editIndex!, produit);
    } else {
      notifier.ajouter(produit);
    }

    Navigator.of(context).pop();
  }
}
