// DermaLogic v3 - Constantes et Prompts
//
// Prompts IA pour Gemini + constantes du theme.
//
// Port de : Python api/gemini.py L24-154 + gui/theme.py

import 'package:flutter/material.dart';

// =============================================================================
// PROMPT EXPERT POUR ANALYSE DE PRODUIT
// =============================================================================

/// Prompt pour l'analyse IA d'un produit cosmetique.
///
/// Placeholder : `{nom_produit}`
/// Modele : gemini-2.0-flash, 512 tokens, temperature 0.2
const String promptAnalyseProduit = '''Tu es un expert dermatologue et cosmetologue avec 20 ans d'experience dans l'analyse des produits de soin de la peau. Tu connais parfaitement les ingredients actifs, leur comportement face aux UV, leur texture et leur fonction.

Je vais te donner le nom d'un produit cosmetique. Tu dois analyser ce produit et me retourner ses caracteristiques au format JSON strict.

REGLES IMPORTANTES :
1. Reponds UNIQUEMENT avec un objet JSON valide
2. Pas de texte avant ou apres le JSON
3. Pas de bloc de code markdown (pas de ```)
4. Utilise tes connaissances sur les formulations cosmetiques
5. Si tu ne connais pas le produit exact, analyse en fonction de la marque et du type de produit

STRUCTURE JSON EXACTE A RETOURNER :
{{"nom": "Nom complet du produit", "category": "moisturizer", "moment": "tous", "photosensitive": false, "occlusivity": 3, "cleansing_power": 3, "active_tag": "hydration"}}

VALEURS POSSIBLES :
- category: "cleanser", "treatment", "moisturizer", "protection"
- moment: "matin", "journee", "soir", "tous"
- photosensitive: true ou false
- occlusivity: nombre entier de 1 a 5
- cleansing_power: nombre entier de 1 a 5
- active_tag: "hydration", "acne", "repair"

GUIDE D'EVALUATION :

category:
- "cleanser" : nettoyants, demaquillants, eaux micellaires, gels nettoyants
- "treatment" : serums, acides, retinol, vitamine C, niacinamide
- "moisturizer" : cremes, baumes, lotions hydratantes
- "protection" : ecrans solaires, SPF, protections UV

moment:
- "matin" : SPF, antioxydants, protections
- "soir" : retinol, AHA/BHA, traitements intensifs
- "journee" : reapplication SPF, brumes
- "tous" : nettoyants, hydratants basiques, produits sans actifs photosensibles

photosensitive = true si contient :
- Retinol, retinaldehyde, tretinoine
- AHA (acide glycolique, lactique, mandelique)
- BHA (acide salicylique a haute concentration)
- Vitamine C pure (acide ascorbique)
- Benzoyl peroxide

occlusivity (1=tres leger, 5=tres riche) :
- 1 : eaux, brumes, gels, lotions legeres
- 2 : serums, fluides legers
- 3 : cremes legeres, emulsions
- 4 : cremes riches, baumes legers
- 5 : baumes epais, huiles, onguents

cleansing_power (1=tres doux, 5=tres puissant) :
- 1 : eaux micellaires douces, laits
- 2 : gels doux sans sulfate
- 3 : nettoyants mousse standards
- 4 : nettoyants purifiants, anti-acne
- 5 : demaquillants waterproof, nettoyants profonds

active_tag :
- "hydration" : acide hyaluronique, glycerine, ceramides, uree
- "acne" : BHA, niacinamide, zinc, peroxyde de benzoyle
- "repair" : panthenol, centella, allantoine, ceramides

PRODUIT A ANALYSER : {nom_produit}

Retourne UNIQUEMENT le JSON, rien d'autre.''';

// =============================================================================
// PROMPT EXPERT POUR ANALYSE DE ROUTINE
// =============================================================================

/// Prompt pour l'analyse de routine dermatologique.
///
/// Placeholders : {type_peau}, {tranche_age}, {niveau_stress},
///   {maladies_peau}, {allergies}, {objectifs}, {produits_json},
///   {ville}, {uv}, {niveau_uv}, {uv_max}, {humidite},
///   {niveau_humidite}, {temperature}, {pm25}, {niveau_pollution},
///   {previsions_json}, {historique_json}, {instructions_supplementaires}
/// Modele : gemini-2.5-flash, 8192 tokens, temperature 0.4
const String promptAnalyseRoutine = '''Tu es un dermatologue expert avec 20 ans d'experience.
Tu dois creer une routine de soins personnalisee basee sur le contexte suivant.

## PROFIL PATIENT
- Type de peau: {type_peau}
- Tranche d'age: {tranche_age}
- Niveau de stress: {niveau_stress}/10
- Conditions cutanees: {maladies_peau}
- Allergies/intolerances: {allergies}
- Objectifs: {objectifs}

## PRODUITS DISPONIBLES
{produits_json}

## CONDITIONS ENVIRONNEMENTALES ACTUELLES
- Ville: {ville}
- UV actuel: {uv} ({niveau_uv})
- UV max du jour: {uv_max}
- Humidite: {humidite}% ({niveau_humidite})
- Temperature: {temperature}C
- PM2.5: {pm25} ug/m3 ({niveau_pollution})

## PREVISIONS 3 JOURS
{previsions_json}

## HISTORIQUE DES 3 DERNIERES ANALYSES
{historique_json}

{instructions_supplementaires}

## REGLES
1. Utilise UNIQUEMENT les produits de la liste ci-dessus
2. Respecte les contra-indications (photosensibilite + UV eleve, allergies du patient)
3. Ordonne les produits du plus aqueux au plus occlusif
4. Adapte la routine aux conditions meteo actuelles et previsions
5. Si le patient a des maladies de peau, priorise les produits adaptes
6. Assure la continuite avec les analyses precedentes (pas de changements brusques)
7. Prends en compte le stress du patient (stress eleve = routine apaisante, produits doux)
8. Si pollution elevee, insiste sur le nettoyage
9. Tout le texte doit etre en francais
10. IMPORTANT : Sois CONCIS. Chaque "raison" doit faire 1 phrase courte (max 20 mots). Les alertes et conseils doivent etre brefs (1-2 phrases max). Le resume doit faire 1 phrase.

## FORMAT DE REPONSE (JSON strict)
{{
    "routine_matin": [
        {{"produit": "Nom du produit", "raison": "Raison courte en 1 phrase"}}
    ],
    "routine_soir": [
        {{"produit": "Nom du produit", "raison": "Raison courte en 1 phrase"}}
    ],
    "alertes": ["Alerte courte si applicable"],
    "conseils_jour": "Conseil bref pour aujourd'hui",
    "activites_jour": ["Activite ou habitude recommandee pour la journee en lien avec la peau et la meteo"],
    "resume": "Resume en 1 phrase"
}}

NOTES :
- "activites_jour" : 2 a 4 conseils pratiques sur ce que le patient peut faire pendant la journee (alimentation, hydratation, sport, protection, gestes a eviter...) en tenant compte de la meteo, du stress et du profil.

Retourne UNIQUEMENT le JSON valide, rien d'autre. Pas de commentaires, pas de markdown.''';

// =============================================================================
// THEME - COULEURS DU THEME SOMBRE
// =============================================================================

/// Couleurs du theme sombre DermaLogic.
class AppColors {
  AppColors._();

  // Couleurs de base
  static const Color fond = Color(0xFF0F0F1A);
  static const Color panneau = Color(0xFF16213E);
  static const Color carte = Color(0xFF1A1A2E);
  static const Color carteHover = Color(0xFF252545);
  static const Color accent = Color(0xFF4ECCA3);
  static const Color accentHover = Color(0xFF3DB892);
  static const Color danger = Color(0xFFE94560);
  static const Color violet = Color(0xFF9B59B6);
  static const Color texteSecondaire = Color(0xFF888888);
  static const Color textePrincipal = Color(0xFFFFFFFF);
  static const Color etoile = Color(0xFFF1C40F);

  // Couleurs par categorie de produit
  static const Map<String, Color> couleurCategorie = {
    'cleanser': Color(0xFF00B4D8),
    'treatment': Color(0xFFF9ED69),
    'moisturizer': Color(0xFF4ECCA3),
    'protection': Color(0xFFF38181),
  };

  // Couleurs par moment d'utilisation
  static const Map<String, Color> couleurMoment = {
    'matin': Color(0xFFF9ED69),
    'journee': Color(0xFF00B4D8),
    'soir': Color(0xFF9B59B6),
    'tous': Color(0xFF4ECCA3),
  };

  // Labels des moments
  static const Map<String, String> labelMoment = {
    'matin': 'MATIN',
    'journee': 'JOURNEE',
    'soir': 'SOIR',
    'tous': 'TOUS MOMENTS',
  };

  // Couleurs par niveau UV
  static const Map<String, Color> couleurUv = {
    'Faible': Color(0xFF4ECCA3),
    'Modere': Color(0xFFF9ED69),
    'Eleve': Color(0xFFF38181),
    'Tres eleve': Color(0xFFE94560),
    'Extreme': Color(0xFF9B59B6),
  };

  // Couleurs par niveau d'humidite
  static const Map<String, Color> couleurHumidite = {
    'Tres sec': Color(0xFFE94560),
    'Sec': Color(0xFFF9ED69),
    'Normal': Color(0xFF4ECCA3),
    'Humide': Color(0xFF00B4D8),
  };

  // Couleurs par niveau de pollution
  static const Map<String, Color> couleurPollution = {
    'Inconnu': Color(0xFF888888),
    'Excellent': Color(0xFF4ECCA3),
    'Bon': Color(0xFF4ECCA3),
    'Modere': Color(0xFFF9ED69),
    'Mauvais': Color(0xFFF38181),
    'Tres mauvais': Color(0xFFE94560),
  };
}
