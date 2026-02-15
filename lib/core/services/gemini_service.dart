// DermaLogic v3 - GeminiService
//
// Client pour l'API Gemini de Google.
// - Analyse de produits cosmetiques (gemini-2.0-flash, 512 tokens)
// - Analyse de routine dermatologique (gemini-2.5-flash, 8192 tokens)
//
// Port de : Python api/gemini.py

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/donnees_environnement.dart';
import '../models/entree_historique.dart';
import '../models/produit_derma.dart';
import '../models/profil_utilisateur.dart';
import '../../utils/constants.dart';
import '../../utils/json_utils.dart';

/// Resultat de l'analyse IA d'un produit.
class ResultatAnalyseIA {
  final bool succes;
  final String nom;
  final String category;
  final String moment;
  final bool photosensitive;
  final int occlusivity;
  final int cleansingPower;
  final String activeTag;
  final String erreur;

  ResultatAnalyseIA({
    required this.succes,
    this.nom = '',
    this.category = 'moisturizer',
    this.moment = 'tous',
    this.photosensitive = false,
    this.occlusivity = 3,
    this.cleansingPower = 3,
    this.activeTag = 'hydration',
    this.erreur = '',
  });
}

/// Client pour l'API Gemini de Google.
class GeminiService {
  final String apiKey;

  GeminiService({required this.apiKey});

  /// Retourne true si la cle API est definie.
  bool get estConfigure => apiKey.isNotEmpty;

  /// Envoie un prompt a Gemini et retourne la reponse brute.
  ///
  /// [model] : "gemini-2.0-flash" ou "gemini-2.5-flash"
  /// [maxTokens] : nombre max de tokens en sortie
  /// [temperature] : creativite (0.0 = deterministe, 1.0 = creatif)
  Future<String?> generer(
    String prompt, {
    String model = 'gemini-2.0-flash',
    int maxTokens = 512,
    double temperature = 0.2,
  }) async {
    if (apiKey.isEmpty) {
      print('[Gemini] Erreur: cle API non configuree');
      return null;
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final payload = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': temperature,
        'maxOutputTokens': maxTokens,
      }
    };

    print('[Gemini] Envoi requete vers $model...');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 120));

      print('[Gemini] Reponse recue (HTTP ${response.statusCode})');

      if (response.statusCode != 200) {
        print('[Gemini] Erreur HTTP: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;

      if (candidates != null && candidates.isNotEmpty) {
        final candidate = candidates[0] as Map<String, dynamic>;
        final finishReason = candidate['finishReason'] as String?;
        if (finishReason != null && finishReason != 'STOP') {
          print('[Gemini] ATTENTION: finishReason=$finishReason');
        }

        final content = candidate['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;

        if (parts != null && parts.isNotEmpty) {
          // Gemini 2.5 Flash : ignorer les parts "thought"
          String texteFinal = '';
          for (final part in parts) {
            final partMap = part as Map<String, dynamic>;
            if (partMap['thought'] == true) {
              final thoughtLen = (partMap['text'] as String?)?.length ?? 0;
              print('[Gemini] Part thinking ignoree ($thoughtLen car.)');
              continue;
            }
            texteFinal = (partMap['text'] as String?)?.trim() ?? '';
          }
          // Fallback : derniere part si toutes sont des thoughts
          if (texteFinal.isEmpty) {
            texteFinal =
                (parts.last as Map<String, dynamic>)['text'] as String? ?? '';
            texteFinal = texteFinal.trim();
            print('[Gemini] Fallback: derniere part utilisee (${texteFinal.length} car.)');
          }
          print('[Gemini] Reponse OK (${texteFinal.length} caracteres)');
          return texteFinal;
        }
      }

      print('[Gemini] Reponse vide (aucun candidat)');
      return null;
    } catch (e) {
      print('[Gemini] Erreur: $e');
      return null;
    }
  }

  /// Analyse un produit cosmetique et retourne ses caracteristiques.
  ///
  /// Modele : gemini-2.0-flash, 512 tokens, temperature 0.2
  Future<ResultatAnalyseIA> analyserProduit(String nomProduit) async {
    print('[Gemini] Analyse produit: $nomProduit');

    final prompt = promptAnalyseProduit.replaceAll('{nom_produit}', nomProduit);
    final reponse = await generer(prompt);

    if (reponse == null) {
      return ResultatAnalyseIA(
        succes: false,
        erreur: 'Pas de reponse de Gemini. Verifie ta connexion internet et ta cle API.',
      );
    }

    final data = extraireJson(reponse);

    if (data == null) {
      return ResultatAnalyseIA(
        succes: false,
        erreur: 'Impossible de parser la reponse:\n${reponse.substring(0, reponse.length.clamp(0, 150))}...',
      );
    }

    // Valider les champs
    const categoriesValides = ['cleanser', 'treatment', 'moisturizer', 'protection'];
    const momentsValides = ['matin', 'journee', 'soir', 'tous'];
    const tagsValides = ['hydration', 'acne', 'repair'];

    var category = data['category'] as String? ?? 'moisturizer';
    if (!categoriesValides.contains(category)) category = 'moisturizer';

    var moment = data['moment'] as String? ?? 'tous';
    if (!momentsValides.contains(moment)) moment = 'tous';

    var activeTag = data['active_tag'] as String? ?? 'hydration';
    if (!tagsValides.contains(activeTag)) activeTag = 'hydration';

    final occlusivity = (data['occlusivity'] as num?)?.toInt().clamp(1, 5) ?? 3;
    final cleansingPower = (data['cleansing_power'] as num?)?.toInt().clamp(1, 5) ?? 3;

    return ResultatAnalyseIA(
      succes: true,
      nom: data['nom'] as String? ?? nomProduit,
      category: category,
      moment: moment,
      photosensitive: data['photosensitive'] as bool? ?? false,
      occlusivity: occlusivity,
      cleansingPower: cleansingPower,
      activeTag: activeTag,
    );
  }

  /// Genere une routine dermatologique personnalisee.
  ///
  /// Modele : gemini-2.5-flash, 8192 tokens, temperature 0.4
  Future<Map<String, dynamic>> analyserRoutine({
    required List<ProduitDerma> produits,
    required DonneesEnvironnementales conditionsActuelles,
    required List<PrevisionJournaliere> previsions,
    required ProfilUtilisateur profil,
    required List<EntreeHistorique> historiqueRecent,
    String ville = '',
    String mode = 'rapide',
    String instructionsJour = '',
    int? niveauStressJour,
  }) async {
    // Construire les JSONs pour le prompt
    final produitsJson = const JsonEncoder.withIndent('  ')
        .convert(produits.map((p) => p.toJson()).toList());

    final previsionsJson = previsions.isNotEmpty
        ? const JsonEncoder.withIndent('  ')
            .convert(previsions.map((p) => p.toJson()).toList())
        : 'Aucune prevision disponible';

    String historiqueJson;
    if (historiqueRecent.isNotEmpty) {
      final histData = historiqueRecent.map((h) => {
        'date': h.date,
        'mode': h.mode,
        'routine_matin': h.routineMatin,
        'routine_soir': h.routineSoir,
        'resume': h.resumeIa,
      }).toList();
      historiqueJson = const JsonEncoder.withIndent('  ').convert(histData);
    } else {
      historiqueJson = 'Aucun historique disponible (premiere analyse)';
    }

    // Instructions supplementaires (mode detaille)
    var instructionsSupplementaires = '';
    if (mode == 'detaille') {
      final parts = <String>['## INSTRUCTIONS DU JOUR (MODE DETAILLE)'];
      if (niveauStressJour != null) {
        parts.add('- Niveau de stress actuel: $niveauStressJour/10');
      }
      if (instructionsJour.isNotEmpty) {
        parts.add('- Instructions specifiques: $instructionsJour');
      }
      instructionsSupplementaires = parts.join('\n');
    }

    final stress = niveauStressJour ?? profil.niveauStress;

    // Construire le prompt avec remplacement des placeholders
    final prompt = promptAnalyseRoutine
        .replaceAll('{type_peau}', profil.typePeau.value)
        .replaceAll('{tranche_age}', profil.trancheAge.value)
        .replaceAll('{niveau_stress}', stress.toString())
        .replaceAll('{maladies_peau}',
            profil.maladiesPeau.isNotEmpty ? profil.maladiesPeau.join(', ') : 'Aucune')
        .replaceAll('{allergies}',
            profil.allergies.isNotEmpty ? profil.allergies.join(', ') : 'Aucune')
        .replaceAll('{objectifs}',
            profil.objectifs.isNotEmpty
                ? profil.objectifs.map((o) => o.value).join(', ')
                : 'Aucun specifie')
        .replaceAll('{produits_json}', produitsJson)
        .replaceAll('{ville}', ville)
        .replaceAll('{uv}', conditionsActuelles.indiceUv.toString())
        .replaceAll('{niveau_uv}', conditionsActuelles.niveauUv)
        .replaceAll('{uv_max}', conditionsActuelles.indiceUvMax.toString())
        .replaceAll('{humidite}', conditionsActuelles.humiditeRelative.toString())
        .replaceAll('{niveau_humidite}', conditionsActuelles.niveauHumidite)
        .replaceAll('{temperature}', conditionsActuelles.temperature.toString())
        .replaceAll('{pm25}',
            conditionsActuelles.pm25?.toString() ?? 'N/A')
        .replaceAll('{niveau_pollution}', conditionsActuelles.niveauPollution)
        .replaceAll('{previsions_json}', previsionsJson)
        .replaceAll('{historique_json}', historiqueJson)
        .replaceAll('{instructions_supplementaires}', instructionsSupplementaires);

    print('[Gemini] Analyse routine ($mode) - Ville: $ville');
    print('[Gemini] Produits: ${produits.length} | Stress: $stress/10');

    // Utiliser Gemini 2.5 Flash
    final reponse = await generer(
      prompt,
      model: 'gemini-2.5-flash',
      maxTokens: 8192,
      temperature: 0.4,
    );

    final Map<String, dynamic> erreurResult = {
      'routine_matin': <dynamic>[],
      'routine_soir': <dynamic>[],
      'alertes': <dynamic>[],
      'conseils_jour': '',
      'activites_jour': <dynamic>[],
      'resume': '',
    };

    if (reponse == null) {
      return {
        ...erreurResult,
        'erreur': 'Pas de reponse de Gemini. Verifie ta connexion internet et ta cle API.',
      };
    }

    final resultat = extraireJson(reponse);

    if (resultat == null) {
      return {
        ...erreurResult,
        'erreur': 'Impossible de parser la reponse IA:\n${reponse.substring(0, reponse.length.clamp(0, 200))}...',
      };
    }

    // S'assurer que tous les champs existent
    return {
      'routine_matin': resultat['routine_matin'] ?? [],
      'routine_soir': resultat['routine_soir'] ?? [],
      'alertes': resultat['alertes'] ?? [],
      'conseils_jour': resultat['conseils_jour'] ?? '',
      'activites_jour': resultat['activites_jour'] ?? [],
      'resume': resultat['resume'] ?? '',
    };
  }
}
