// DermaLogic v3 - Utilitaire d'extraction JSON
//
// Extrait un objet JSON d'un texte brut (reponse IA).
// Gere : blocs <think>, blocs ```json```, JSON imbrique.
//
// Port de : Python api/gemini.py L267-325

import 'dart:convert';

/// Extrait un objet JSON d'un texte brut, meme s'il est entoure de texte.
///
/// Etapes :
/// 1. Supprime les blocs `<think>...</think>`
/// 2. Supprime les blocs de code markdown ` ```json ``` `
/// 3. Tente un `jsonDecode` direct
/// 4. Si echec, cherche le JSON imbrique avec balance des accolades
///
/// Retourne `null` si aucun JSON valide n'est trouve.
Map<String, dynamic>? extraireJson(String? texte) {
  if (texte == null || texte.isEmpty) return null;

  var cleaned = texte.trim();

  // 1. Enlever les blocs de reflexion <think>...</think>
  cleaned = cleaned.replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '');
  cleaned = cleaned.trim();

  // 2. Enlever les blocs de code markdown
  cleaned = cleaned.replaceAll(RegExp(r'```(?:json)?\s*'), '');
  cleaned = cleaned.replaceAll('```', '');
  cleaned = cleaned.trim();

  // 3. Essayer de parser directement
  try {
    final result = jsonDecode(cleaned);
    if (result is Map<String, dynamic>) return result;
  } catch (_) {}

  // 4. Chercher le JSON imbrique avec balance des accolades
  var start = cleaned.indexOf('{');
  while (start != -1) {
    var depth = 0;
    var inString = false;
    var escape = false;

    for (var i = start; i < cleaned.length; i++) {
      final char = cleaned[i];

      if (escape) {
        escape = false;
        continue;
      }
      if (char == r'\' && inString) {
        escape = true;
        continue;
      }
      if (char == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;

      if (char == '{') {
        depth++;
      } else if (char == '}') {
        depth--;
        if (depth == 0) {
          final candidate = cleaned.substring(start, i + 1);
          try {
            final result = jsonDecode(candidate);
            if (result is Map<String, dynamic>) return result;
          } catch (_) {
            // Continuer a chercher un autre objet JSON
          }
          start = cleaned.indexOf('{', i + 1);
          break;
        }
      }
    }

    // Si on sort de la boucle sans trouver, arreter
    if (depth != 0) break;
  }

  return null;
}
