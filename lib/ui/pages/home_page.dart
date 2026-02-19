import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/donnees_environnement.dart';
import '../../providers/analyse_provider.dart';
import '../../providers/config_provider.dart';
import '../../providers/meteo_provider.dart';
import '../../providers/produit_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/constants.dart';
import '../components/environment_card.dart';
import '../components/forecast_card.dart';
import '../components/section_panel.dart';

/// Page d'accueil — dashboard meteo + analyse IA + resultats.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _showDetailPanel = false;
  final _instructionsController = TextEditingController();
  double _stressLevel = 5;
  bool _isAnalyzing = false;

  String _statusMessage = 'Lancez une analyse pour obtenir vos recommandations';
  Color _statusColor = AppColors.texteSecondaire;

  List<PrevisionJournaliere>? _previsions;
  bool _loadingPrevisions = false;

  @override
  void initState() {
    super.initState();
    // Charger les previsions au demarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerPrevisions();
    });
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _chargerPrevisions() async {
    setState(() => _loadingPrevisions = true);
    try {
      final previsions =
          await ref.read(meteoProvider.notifier).obtenirPrevisions();
      if (mounted) {
        setState(() {
          _previsions = previsions;
          _loadingPrevisions = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingPrevisions = false);
      }
    }
  }

  Future<void> _actualiser() async {
    await ref.read(meteoProvider.notifier).refresh();
    await _chargerPrevisions();
  }

  bool _verifierPreAnalyse() {
    // 1. Verifier la cle API
    final settings = ref.read(settingsProvider).value;
    if (settings == null || settings.geminiApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Configurez d'abord votre cle API Gemini dans Parametres"),
          backgroundColor: AppColors.danger,
        ),
      );
      context.go('/parametres');
      return false;
    }

    // 2. Verifier les donnees meteo
    final meteo = ref.read(meteoProvider).value;
    if (meteo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chargez d\'abord les donnees meteo'),
          backgroundColor: AppColors.danger,
        ),
      );
      return false;
    }

    // 3. Verifier les produits
    final produits = ref.read(produitProvider).value;
    if (produits == null || produits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ajoutez d'abord des produits dans 'Mes Produits'"),
          backgroundColor: AppColors.danger,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _lancerAnalyse(String mode) async {
    if (!_verifierPreAnalyse()) return;

    setState(() {
      _isAnalyzing = true;
      _statusMessage = 'Analyse IA en cours (~15-30s selon la connexion)...';
      _statusColor = AppColors.attention;
    });

    try {
      final conditions = ref.read(meteoProvider).value;
      if (conditions == null) {
        setState(() {
          _isAnalyzing = false;
          _statusMessage = 'Donnees meteo indisponibles';
          _statusColor = AppColors.danger;
        });
        return;
      }
      final previsions =
          _previsions ?? await ref.read(meteoProvider.notifier).obtenirPrevisions();
      final ville =
          ref.read(configProvider).value?.villeActuelle.nom ?? '';

      await ref.read(analyseProvider.notifier).lancer(
            conditionsActuelles: conditions,
            previsions: previsions,
            ville: ville,
            mode: mode,
            instructionsJour: _instructionsController.text,
            niveauStressJour: _stressLevel.round(),
          );

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _statusMessage = 'Analyse terminee';
          _statusColor = AppColors.accent;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _statusMessage = 'Echec de l\'analyse';
          _statusColor = AppColors.danger;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final meteoAsync = ref.watch(meteoProvider);
    final analyseAsync = ref.watch(analyseProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;

    return RefreshIndicator(
      onRefresh: _actualiser,
      color: AppColors.accent,
      backgroundColor: AppColors.panneau,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1 : Conditions environnementales ──
            _buildConditionsSection(meteoAsync, screenWidth),

            const SizedBox(height: 16),

            // ── Section 2 : Previsions 3 jours ──
            if (_previsions != null && _previsions!.isNotEmpty)
              _buildPrevisionsSection(screenWidth),

            // ── Section 3 : Boutons d'analyse ──
            _buildAnalyseButtons(),

            const SizedBox(height: 12),

            // ── Section 4 : Panneau detaille ──
            _buildDetailPanel(),

            // ── Section 5 : Statut ──
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 12,
                    color: _statusColor,
                  ),
                  child: Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // ── Section 6 : Resultats ──
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: _buildResultats(analyseAsync),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Section 1 : Conditions
  // ════════════════════════════════════════════════════════════════

  Widget _buildConditionsSection(
      AsyncValue<DonneesEnvironnementales?> meteoAsync, double screenWidth) {
    return SectionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Conditions actuelles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              meteoAsync.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _actualiser,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Actualiser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
            ],
          ),
          const SizedBox(height: 16),

          // Cartes
          meteoAsync.when(
            loading: () => _buildCardsGrid(
              screenWidth,
              isLoading: true,
            ),
            error: (e, _) => Center(
              child: Column(
                children: [
                  Text(
                    'Erreur de chargement meteo : $e',
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _actualiser,
                    icon: const Icon(Icons.refresh, size: 14),
                    label: const Text('Reessayer'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            data: (donnees) {
              if (donnees == null) {
                return const Center(
                  child: Text(
                    'Aucune donnee meteo. Cliquez sur Actualiser.',
                    style: TextStyle(
                      color: AppColors.texteSecondaire,
                      fontSize: 13,
                    ),
                  ),
                );
              }
              return _buildCardsGrid(screenWidth, donnees: donnees);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardsGrid(double screenWidth,
      {DonneesEnvironnementales? donnees, bool isLoading = false}) {
    final cards = isLoading
        ? List.generate(
            4,
            (_) => const EnvironmentCard(
              title: '',
              isLoading: true,
            ),
          )
        : [
            EnvironmentCard(
              title: 'Indice UV',
              value: donnees!.indiceUv.toStringAsFixed(1),
              level: donnees.niveauUv,
              levelColor: AppColors.couleurUv[donnees.niveauUv] ??
                  AppColors.texteSecondaire,
            ),
            EnvironmentCard(
              title: 'Humidite',
              value: '${donnees.humiditeRelative.toStringAsFixed(0)}%',
              level: donnees.niveauHumidite,
              levelColor: AppColors.couleurHumidite[donnees.niveauHumidite] ??
                  AppColors.texteSecondaire,
            ),
            EnvironmentCard(
              title: 'PM2.5',
              value: donnees.pm25 != null
                  ? '${donnees.pm25!.toStringAsFixed(0)} \u00b5g/m\u00b3'
                  : '--',
              level: donnees.niveauPollution,
              levelColor:
                  AppColors.couleurPollution[donnees.niveauPollution] ??
                      AppColors.texteSecondaire,
            ),
            EnvironmentCard(
              title: 'Temperature',
              value: '${donnees.temperature.toStringAsFixed(1)}\u00b0C',
              level: donnees.heure,
              levelColor: AppColors.texteSecondaire,
            ),
          ];

    // 2x2 grid responsive
    if (screenWidth >= 500) {
      // Row de 4
      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: c,
                  ),
                ))
            .toList(),
      );
    }
    // 2x2
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child:
                    Padding(padding: const EdgeInsets.all(4), child: cards[0])),
            Expanded(
                child:
                    Padding(padding: const EdgeInsets.all(4), child: cards[1])),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child:
                    Padding(padding: const EdgeInsets.all(4), child: cards[2])),
            Expanded(
                child:
                    Padding(padding: const EdgeInsets.all(4), child: cards[3])),
          ],
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Section 2 : Previsions
  // ════════════════════════════════════════════════════════════════

  Widget _buildPrevisionsSection(double screenWidth) {
    return SectionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Previsions 3 jours',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (_loadingPrevisions)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (screenWidth >= 500)
            Row(
              children: _previsions!
                  .take(3)
                  .map((p) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ForecastCard(
                            date: p.date,
                            uvMax: p.uvMax,
                            tempMin: p.temperatureMin,
                            tempMax: p.temperatureMax,
                            humidity: p.humiditeMoyenne,
                          ),
                        ),
                      ))
                  .toList(),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _previsions!
                    .take(3)
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 140,
                            child: ForecastCard(
                              date: p.date,
                              uvMax: p.uvMax,
                              tempMin: p.temperatureMin,
                              tempMax: p.temperatureMax,
                              humidity: p.humiditeMoyenne,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Section 3 : Boutons d'analyse
  // ════════════════════════════════════════════════════════════════

  Widget _buildAnalyseButtons() {
    return SectionPanel(
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing
                  ? null
                  : () => _lancerAnalyse('rapide'),
              icon: const Icon(Icons.flash_on, size: 18),
              label: Text(_isAnalyzing ? 'Analyse en cours...' : 'Analyse Rapide'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.carte,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing
                  ? null
                  : () {
                      setState(() {
                        _showDetailPanel = !_showDetailPanel;
                      });
                    },
              icon: const Icon(Icons.science, size: 18),
              label: const Text('Analyse Detaillee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.violet,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.carte,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Section 4 : Panneau detaille
  // ════════════════════════════════════════════════════════════════

  Widget _buildDetailPanel() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _showDetailPanel
          ? SectionPanel(
              title: 'Parametres de l\'analyse detaillee',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Instructions du jour
                  TextField(
                    controller: _instructionsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Instructions du jour',
                      hintText:
                          'Ex: peau irritee aujourd\'hui, maquillage prevu ce soir...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Slider stress
                  Text(
                    'Stress du jour : ${_stressLevel.round()}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.violet,
                      thumbColor: AppColors.violet,
                      inactiveTrackColor: AppColors.carte,
                      overlayColor: AppColors.violet.withAlpha(50),
                    ),
                    child: Slider(
                      value: _stressLevel,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _stressLevel.round().toString(),
                      onChanged: _isAnalyzing
                          ? null
                          : (v) => setState(() => _stressLevel = v),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bouton lancer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing
                          ? null
                          : () => _lancerAnalyse('detaille'),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: Text(_isAnalyzing
                          ? 'Analyse en cours...'
                          : 'Lancer l\'analyse detaillee'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.violet,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.carte,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Section 6 : Resultats
  // ════════════════════════════════════════════════════════════════

  Widget _buildResultats(AsyncValue<Map<String, dynamic>?> analyseAsync) {
    return analyseAsync.when(
      loading: () => const Center(
        key: ValueKey('analyse-loading'),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => SectionPanel(
        key: const ValueKey('analyse-error'),
        child: Text(
          'Erreur d\'analyse : $e',
          style: const TextStyle(color: AppColors.danger, fontSize: 13),
        ),
      ),
      data: (data) {
        if (data == null) return const SizedBox.shrink(key: ValueKey('analyse-empty'));
        return _buildResultatContent(data);
      },
    );
  }

  /// Parse une liste de routines de maniere securisee.
  List<Map<String, dynamic>> _parseRoutineList(dynamic data) {
    if (data is! List) return [];
    return data
        .map((e) => e is Map
            ? Map<String, dynamic>.from(e)
            : <String, dynamic>{'produit': e.toString(), 'raison': ''})
        .toList();
  }

  /// Parse une liste de strings de maniere securisee.
  List<String> _parseStringList(dynamic data) {
    if (data is! List) return [];
    return data.map((e) => e.toString()).toList();
  }

  Widget _buildResultatContent(Map<String, dynamic> data) {
    final resume = data['resume'] as String? ?? '';
    final routineMatin = _parseRoutineList(data['routine_matin']);
    final routineSoir = _parseRoutineList(data['routine_soir']);
    final alertes = _parseStringList(data['alertes']);
    final activites = _parseStringList(data['activites_jour']);
    final conseil = data['conseils_jour'] as String? ?? '';

    return SectionPanel(
      key: const ValueKey('analyse-result'),
      title: 'Resultat de l\'analyse',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resume
          if (resume.isNotEmpty) ...[
            Text(
              resume,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.texteSecondaire,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Divider(color: AppColors.carte, height: 24),
          ],

          // Routine Matin
          if (routineMatin.isNotEmpty) ...[
            const Text(
              'Routine Matin',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.attention,
              ),
            ),
            const SizedBox(height: 6),
            ...routineMatin.asMap().entries.map((entry) {
              final i = entry.key + 1;
              final item = entry.value;
              final nom = item['produit'] ?? '';
              final raison = item['raison'] ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '$i. $nom \u2014 $raison',
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],

          // Routine Soir
          if (routineSoir.isNotEmpty) ...[
            const Text(
              'Routine Soir',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.violet,
              ),
            ),
            const SizedBox(height: 6),
            ...routineSoir.asMap().entries.map((entry) {
              final i = entry.key + 1;
              final item = entry.value;
              final nom = item['produit'] ?? '';
              final raison = item['raison'] ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '$i. $nom \u2014 $raison',
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              );
            }),
            const SizedBox(height: 12),
          ],

          // Alertes
          if (alertes.isNotEmpty) ...[
            const Text(
              'Alertes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 6),
            ...alertes.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '  \u26a0 $a',
                    style:
                        const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                )),
            const SizedBox(height: 12),
          ],

          // Activites du jour
          if (activites.isNotEmpty) ...[
            const Text(
              'Pendant la journee',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.info,
              ),
            ),
            const SizedBox(height: 6),
            ...activites.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '  \u2022 $a',
                    style:
                        const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                )),
            const SizedBox(height: 12),
          ],

          // Conseil du jour
          if (conseil.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.accent.withAlpha(80),
                ),
              ),
              child: Text(
                '\ud83d\udca1 $conseil',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.accent,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
