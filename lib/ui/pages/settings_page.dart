import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/services/gemini_service.dart';
import '../../providers/config_provider.dart';
import '../../providers/historique_provider.dart';
import '../../providers/produit_provider.dart';
import '../../providers/profil_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/constants.dart';
import '../components/section_panel.dart';

/// Page des parametres : cle API Gemini + export.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _keyCtrl = TextEditingController();
  bool _obscure = true;
  String _saveStatus = '';
  Color _saveStatusColor = AppColors.texteSecondaire;
  bool _testing = false;
  String _testStatus = '';
  Color _testStatusColor = AppColors.texteSecondaire;
  String _exportStatus = '';
  Color _exportStatusColor = AppColors.texteSecondaire;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final settings = await ref.read(settingsProvider.future);
      if (mounted) _keyCtrl.text = settings.geminiApiKey;
    });
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final hasKey = settingsAsync.whenOrNull(
            data: (s) => s.geminiApiKey.isNotEmpty) ??
        false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Section cle API
          SectionPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.key, color: AppColors.accent),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Cle API Gemini',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: hasKey
                            ? AppColors.accent.withAlpha(51)
                            : AppColors.danger.withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        hasKey ? 'Connecte' : 'Non configure',
                        style: TextStyle(
                          fontSize: 11,
                          color: hasKey ? AppColors.accent : AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Entrez votre cle API Google Gemini pour utiliser l\'analyse IA.\n'
                  'Obtenez-la sur aistudio.google.com',
                  style: TextStyle(fontSize: 12, color: AppColors.texteSecondaire),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _keyCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Cle API Gemini',
                    hintText: 'Collez votre cle API ici',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.texteSecondaire,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(onPressed: _saveKey, child: const Text('Sauvegarder')),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _testing ? null : _testConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.carte,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_testing ? 'Test en cours...' : 'Tester la connexion'),
                    ),
                  ],
                ),
                if (_saveStatus.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_saveStatus, style: TextStyle(fontSize: 12, color: _saveStatusColor)),
                ],
                if (_testStatus.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_testStatus, style: TextStyle(fontSize: 12, color: _testStatusColor)),
                ],
              ],
            ),
          ),

          // Section export
          SectionPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.download, color: AppColors.accent),
                    SizedBox(width: 10),
                    Text('Exporter mes donnees',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Exportez toutes vos donnees (profil, produits, historique)\n'
                  'au format JSON pour sauvegarde ou migration.',
                  style: TextStyle(fontSize: 12, color: AppColors.texteSecondaire),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _export,
                  icon: const Icon(Icons.download),
                  label: const Text('Exporter en JSON'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.carte,
                    foregroundColor: Colors.white,
                  ),
                ),
                if (_exportStatus.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(_exportStatus, style: TextStyle(fontSize: 12, color: _exportStatusColor)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveKey() async {
    await ref.read(settingsProvider.notifier).saveGeminiKey(_keyCtrl.text.trim());
    if (!mounted) return;
    setState(() {
      _saveStatus = 'Cle sauvegardee avec succes';
      _saveStatusColor = AppColors.accent;
    });
  }

  Future<void> _testConnection() async {
    setState(() { _testing = true; _testStatus = ''; });
    try {
      final gemini = GeminiService(apiKey: _keyCtrl.text.trim());
      final result = await gemini.generer('Reponds uniquement "OK".');
      if (!mounted) return;
      setState(() {
        _testing = false;
        if (result != null && result.isNotEmpty) {
          _testStatus = 'Connexion reussie !';
          _testStatusColor = AppColors.accent;
        } else {
          _testStatus = 'Echec de connexion. Verifiez votre cle API.';
          _testStatusColor = AppColors.danger;
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _testing = false;
          _testStatus = 'Echec de connexion. Verifiez votre cle API.';
          _testStatusColor = AppColors.danger;
        });
      }
    }
  }

  Future<void> _export() async {
    try {
      final profil = await ref.read(profilProvider.future);
      final produits = await ref.read(produitProvider.future);
      final historique = await ref.read(historiqueProvider.future);
      final config = await ref.read(configProvider.future);
      final data = {
        'profil': profil.toJson(),
        'produits': produits.map((p) => p.toJson()).toList(),
        'historique': historique.map((h) => h.toJson()).toList(),
        'ville': config.villeActuelle.toJson(),
      };
      final dir = await getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final ts = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final file = File('${dir.path}/dermalogic_export_$ts.json');
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      if (mounted) {
        setState(() {
          _exportStatus = 'Exporte : ${file.path}';
          _exportStatusColor = AppColors.accent;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _exportStatus = 'Erreur export: $e';
          _exportStatusColor = AppColors.danger;
        });
      }
    }
  }
}
