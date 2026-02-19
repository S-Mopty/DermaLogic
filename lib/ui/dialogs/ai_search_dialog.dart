import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/produit_derma.dart';
import '../../core/services/gemini_service.dart';
import '../../providers/settings_provider.dart';
import '../../utils/constants.dart';
import 'product_form_dialog.dart';

/// Affiche le dialog de recherche IA.
Future<void> showAiSearchDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (_) => const AiSearchDialog(),
  );
}

/// Dialog de recherche de produit par IA Gemini.
class AiSearchDialog extends ConsumerStatefulWidget {
  const AiSearchDialog({super.key});

  @override
  ConsumerState<AiSearchDialog> createState() => _AiSearchDialogState();
}

class _AiSearchDialogState extends ConsumerState<AiSearchDialog> {
  final _nameCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = (screenWidth * 0.9).clamp(0.0, 420.0);

    return Dialog(
      child: SizedBox(
        width: dialogWidth,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              const Text(
                'Analyse par IA',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'L\'IA va analyser le produit et remplir automatiquement '
                'les caracteristiques. Tu pourras les modifier ensuite.',
                style: TextStyle(fontSize: 12, color: AppColors.texteSecondaire),
              ),
              const SizedBox(height: 16),

              // Champ nom
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.carte,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nom du produit',
                    hintText: 'Ex: CeraVe Creme Hydratante, Paula\'s Choice BHA...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                  onSubmitted: (_) => _analyze(),
                ),
              ),
              const SizedBox(height: 8),

              // Status
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(fontSize: 12, color: AppColors.danger),
                ),
              const SizedBox(height: 12),

              // Bouton
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: _loading ? null : _analyze,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violet,
                    disabledBackgroundColor: AppColors.violet.withValues(alpha: 0.5),
                  ),
                  child: Text(
                    _loading
                        ? 'Analyse en cours...'
                        : (_error != null ? 'Reessayer' : 'Analyser avec l\'IA'),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Annuler
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler',
                      style: TextStyle(color: AppColors.texteSecondaire)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _analyze() async {
    final nom = _nameCtrl.text.trim();
    if (nom.isEmpty) {
      setState(() => _error = 'Entre le nom d\'un produit');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final settings = await ref.read(settingsProvider.future);
      final gemini = GeminiService(apiKey: settings.geminiApiKey);
      final result = await gemini.analyserProduit(nom);

      if (!mounted) return;

      if (result.succes) {
        // Fermer ce dialog
        Navigator.of(context).pop();

        // Ouvrir le formulaire pre-rempli
        if (mounted) {
          final produit = ProduitDerma(
            nom: result.nom,
            category: Categorie.fromString(result.category),
            moment: MomentUtilisation.fromString(result.moment),
            photosensitive: result.photosensitive,
            occlusivity: result.occlusivity,
            cleansingPower: result.cleansingPower,
            activeTag: ActiveTag.fromString(result.activeTag),
          );

          showProductFormDialog(
            context,
            initialProduct: produit,
            fromAi: true,
          );
        }
      } else {
        setState(() {
          _loading = false;
          _error = result.erreur.isNotEmpty
              ? result.erreur
              : 'Erreur lors de l\'analyse';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Erreur: $e';
        });
      }
    }
  }
}
