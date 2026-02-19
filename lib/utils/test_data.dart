// Donnees de test pour DermaLogic v3.
// Appeler seedTestData() au demarrage pour pre-remplir l'app.

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Injecte des donnees de test dans les fichiers JSON de l'app.
/// Ne fait rien si les fichiers existent deja (ne pas ecraser).
Future<void> seedTestData({bool force = false}) async {
  final dir = await getApplicationDocumentsDirectory();

  await _writeIfAbsent('${dir.path}/config.json', _configJson, force: force);
  await _writeIfAbsent('${dir.path}/profile.json', _profileJson, force: force);
  await _writeIfAbsent(
      '${dir.path}/produits_derma.json', _produitsJson, force: force);
  await _writeIfAbsent(
      '${dir.path}/historique.json', _historiqueJson, force: force);
  // Ne pas ecrire settings.json (cle API = l'utilisateur doit la mettre)

  print('[TestData] Donnees de test chargees dans ${dir.path}');
}

Future<void> _writeIfAbsent(String path, Object data,
    {bool force = false}) async {
  final file = File(path);
  if (!force && await file.exists()) return;
  final content = const JsonEncoder.withIndent('  ').convert(data);
  await file.writeAsString(content);
}

// ═══════════════════════════════════════════════════════════════
// CONFIG — ville actuelle + favoris
// ═══════════════════════════════════════════════════════════════

const _configJson = {
  'ville_actuelle': {
    'nom': 'Paris',
    'pays': 'France',
    'latitude': 48.8566,
    'longitude': 2.3522,
    'derniere_maj': '2025-06-15 09:30',
    'indice_uv': 5.2,
    'humidite': 62.0,
    'temperature': 24.5,
    'pm2_5': 18.3,
  },
  'villes_favorites': [
    {
      'nom': 'Lyon',
      'pays': 'France',
      'latitude': 45.7640,
      'longitude': 4.8357,
      'derniere_maj': '2025-06-15 08:45',
      'indice_uv': 6.1,
      'humidite': 55.0,
      'temperature': 26.0,
      'pm2_5': 14.5,
    },
    {
      'nom': 'Marseille',
      'pays': 'France',
      'latitude': 43.2965,
      'longitude': 5.3698,
      'derniere_maj': '2025-06-14 18:20',
      'indice_uv': 7.8,
      'humidite': 70.0,
      'temperature': 28.5,
      'pm2_5': 22.0,
    },
    {
      'nom': 'Montreal',
      'pays': 'Canada',
      'latitude': 45.5017,
      'longitude': -73.5673,
      'derniere_maj': '2025-06-14 15:00',
      'indice_uv': 4.0,
      'humidite': 48.0,
      'temperature': 22.0,
      'pm2_5': 8.5,
    },
  ],
};

// ═══════════════════════════════════════════════════════════════
// PROFIL — utilisateur test
// ═══════════════════════════════════════════════════════════════

const _profileJson = {
  'type_peau': 'mixte',
  'tranche_age': '26-35',
  'niveau_stress': 6,
  'maladies_peau': ['acne legere', 'rosacea'],
  'allergies': ['sodium laureth sulfate', 'parfum synthetique'],
  'objectifs': ['anti-acne', 'hydratation', 'protection'],
  'instructions_quotidiennes':
      'Eviter les produits agressifs le matin. Masque hydratant 2x par semaine.',
};

// ═══════════════════════════════════════════════════════════════
// PRODUITS — 8 produits de test couvrant toutes les categories
// ═══════════════════════════════════════════════════════════════

const _produitsJson = [
  // ── MATIN ──
  {
    'nom': 'CeraVe Gel Moussant',
    'category': 'cleanser',
    'moment': 'matin',
    'photosensitive': false,
    'occlusivity': 1,
    'cleansing_power': 4,
    'active_tag': 'hydration',
  },
  {
    'nom': 'The Ordinary Niacinamide 10%',
    'category': 'treatment',
    'moment': 'matin',
    'photosensitive': false,
    'occlusivity': 1,
    'cleansing_power': 1,
    'active_tag': 'acne',
  },
  {
    'nom': 'La Roche-Posay Anthelios SPF50+',
    'category': 'protection',
    'moment': 'matin',
    'photosensitive': true,
    'occlusivity': 3,
    'cleansing_power': 1,
    'active_tag': 'hydration',
  },

  // ── SOIR ──
  {
    'nom': 'Bioderma Sensibio H2O',
    'category': 'cleanser',
    'moment': 'soir',
    'photosensitive': false,
    'occlusivity': 1,
    'cleansing_power': 5,
    'active_tag': 'hydration',
  },
  {
    'nom': 'Paula\'s Choice BHA 2%',
    'category': 'treatment',
    'moment': 'soir',
    'photosensitive': true,
    'occlusivity': 1,
    'cleansing_power': 2,
    'active_tag': 'acne',
  },
  {
    'nom': 'CeraVe Creme Hydratante',
    'category': 'moisturizer',
    'moment': 'soir',
    'photosensitive': false,
    'occlusivity': 4,
    'cleansing_power': 1,
    'active_tag': 'repair',
  },

  // ── TOUS MOMENTS ──
  {
    'nom': 'Avene Eau Thermale Spray',
    'category': 'treatment',
    'moment': 'tous',
    'photosensitive': false,
    'occlusivity': 1,
    'cleansing_power': 1,
    'active_tag': 'hydration',
  },

  // ── JOURNEE ──
  {
    'nom': 'Vichy Mineral 89 Booster',
    'category': 'moisturizer',
    'moment': 'journee',
    'photosensitive': false,
    'occlusivity': 2,
    'cleansing_power': 1,
    'active_tag': 'hydration',
  },
];

// ═══════════════════════════════════════════════════════════════
// HISTORIQUE — 3 analyses de test
// ═══════════════════════════════════════════════════════════════

const _historiqueJson = [
  {
    'id': 'test_001',
    'date': '2025-06-15T08:30:00.000Z',
    'mode': 'detaille',
    'resume_ia':
        'Conditions estivales avec UV modere a eleve. Votre peau mixte necessite une protection solaire renforcee et une hydratation equilibree. Attention a la pollution urbaine moderee.',
    'routine_matin': [
      {
        'produit': 'CeraVe Gel Moussant',
        'raison':
            'Nettoyage doux au pH neutre pour ne pas perturber la barriere cutanee',
      },
      {
        'produit': 'The Ordinary Niacinamide 10%',
        'raison':
            'Regulation du sebum et reduction des pores dilates, ideal pour peau mixte',
      },
      {
        'produit': 'La Roche-Posay Anthelios SPF50+',
        'raison':
            'Protection UV indispensable avec indice UV de 5.2 (modere a eleve)',
      },
    ],
    'routine_soir': [
      {
        'produit': 'Bioderma Sensibio H2O',
        'raison':
            'Demaquillage et nettoyage en douceur apres une journee d\'exposition',
      },
      {
        'produit': 'Paula\'s Choice BHA 2%',
        'raison':
            'Exfoliation chimique pour traiter l\'acne legere et desincruster les pores',
      },
      {
        'produit': 'CeraVe Creme Hydratante',
        'raison':
            'Reparation nocturne avec ceramides, restaure la barriere cutanee',
      },
    ],
    'alertes': [
      'UV modere a eleve (5.2) : reappliquer la protection solaire toutes les 2h en exterieur',
      'Pollution moderee (PM2.5: 18.3) : double nettoyage recommande le soir',
      'Stress eleve (6/10) : risque de poussee d\'acne, privilegier les actifs apaisants',
    ],
    'conseils_jour':
        'Bonne hydratation orale (minimum 1.5L d\'eau). Eviter l\'exposition solaire directe entre 12h et 16h. Le BHA du soir est photosensibilisant, assurez-vous de bien appliquer le SPF demain matin.',
    'activites_jour': [
      'Boire 1.5L d\'eau minimum',
      'Brumisation Avene si sensation de tiraillement',
      'Eviter exposition solaire 12h-16h',
      'Exercice de respiration anti-stress (5 min)',
    ],
  },
  {
    'id': 'test_002',
    'date': '2025-06-14T07:15:00.000Z',
    'mode': 'rapide',
    'resume_ia':
        'Conditions favorables avec UV faible. Routine standard recommandee. Humidite correcte pour votre type de peau.',
    'routine_matin': [
      {
        'produit': 'CeraVe Gel Moussant',
        'raison': 'Nettoyage matinal de base',
      },
      {
        'produit': 'Vichy Mineral 89 Booster',
        'raison': 'Hydratation legere adaptee a la journee',
      },
      {
        'produit': 'La Roche-Posay Anthelios SPF50+',
        'raison': 'Protection UV preventive meme par faible ensoleillement',
      },
    ],
    'routine_soir': [
      {
        'produit': 'Bioderma Sensibio H2O',
        'raison': 'Nettoyage du soir',
      },
      {
        'produit': 'CeraVe Creme Hydratante',
        'raison': 'Hydratation nocturne reparatrice',
      },
    ],
    'alertes': [
      'Aucune alerte particuliere pour aujourd\'hui',
    ],
    'conseils_jour':
        'Journee ideale pour appliquer un masque hydratant si prevu dans votre routine hebdomadaire.',
    'activites_jour': [
      'Activite en exterieur possible sans risque',
      'Hydratation reguliere',
    ],
  },
  {
    'id': 'test_003',
    'date': '2025-06-12T19:45:00.000Z',
    'mode': 'detaille',
    'resume_ia':
        'Journee chaude avec UV tres eleve et humidite basse. Votre rosacea pourrait etre aggravee par la chaleur. Routine adaptee avec focus sur la protection et l\'apaisement.',
    'routine_matin': [
      {
        'produit': 'CeraVe Gel Moussant',
        'raison': 'Nettoyage doux, eviter eau trop chaude pour la rosacea',
      },
      {
        'produit': 'Avene Eau Thermale Spray',
        'raison': 'Apaisement immediat et rafraichissement de la peau sensible',
      },
      {
        'produit': 'La Roche-Posay Anthelios SPF50+',
        'raison': 'Protection CRITIQUE avec UV tres eleve (8.5)',
      },
    ],
    'routine_soir': [
      {
        'produit': 'Bioderma Sensibio H2O',
        'raison': 'Demaquillage ultra-doux pour peau sensibilisee par le soleil',
      },
      {
        'produit': 'Avene Eau Thermale Spray',
        'raison': 'Apaisement post-exposition solaire',
      },
      {
        'produit': 'CeraVe Creme Hydratante',
        'raison':
            'Restauration de la barriere cutanee alteree par la chaleur et les UV',
      },
    ],
    'alertes': [
      'UV TRES ELEVE (8.5) : protection solaire obligatoire, reapplication toutes les 90 min',
      'Humidite basse (35%) : risque de deshydratation cutanee severe',
      'Chaleur elevee : risque d\'aggravation de la rosacea, eviter les boissons chaudes',
      'ATTENTION : suspendre le BHA ce soir, peau trop sensibilisee par les UV',
    ],
    'conseils_jour':
        'Journee critique pour votre peau. Restez a l\'ombre autant que possible. Doublez l\'hydratation. Pas d\'exfoliation chimique aujourd\'hui ni demain. Si rougeurs persistantes, appliquer une compresse froide.',
    'activites_jour': [
      'Rester a l\'ombre entre 11h et 17h',
      'Boire 2L d\'eau minimum',
      'Compresses froides si rougeurs',
      'Brumisation reguliere toutes les heures',
      'Pas de sport en exterieur',
    ],
  },
];
