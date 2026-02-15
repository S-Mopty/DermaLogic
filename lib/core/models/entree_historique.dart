// DermaLogic v3 - Modele EntreeHistorique
//
// Port de : Python core/models.py L219-270

/// Entree dans l'historique des analyses.
class EntreeHistorique {
  final String id;
  final String date; // ISO 8601
  final String mode; // "rapide" | "detaille"
  final String resumeIa;
  final List<Map<String, dynamic>> routineMatin; // [{produit, raison}]
  final List<Map<String, dynamic>> routineSoir; // [{produit, raison}]
  final List<String> alertes;
  final String conseilsJour;
  final List<String> activitesJour;

  EntreeHistorique({
    required this.id,
    required this.date,
    required this.mode,
    this.resumeIa = '',
    this.routineMatin = const [],
    this.routineSoir = const [],
    this.alertes = const [],
    this.conseilsJour = '',
    this.activitesJour = const [],
  });

  /// Serialise en JSON (compatible v2 Python).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'mode': mode,
      'resume_ia': resumeIa,
      'routine_matin': routineMatin,
      'routine_soir': routineSoir,
      'alertes': alertes,
      'conseils_jour': conseilsJour,
      'activites_jour': activitesJour,
    };
  }

  /// Deserialise depuis JSON (compatible v2 Python).
  factory EntreeHistorique.fromJson(Map<String, dynamic> json) {
    return EntreeHistorique(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      mode: json['mode'] as String? ?? 'rapide',
      resumeIa: json['resume_ia'] as String? ?? '',
      routineMatin: _parseRoutineList(json['routine_matin']),
      routineSoir: _parseRoutineList(json['routine_soir']),
      alertes: (json['alertes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      conseilsJour: json['conseils_jour'] as String? ?? '',
      activitesJour: (json['activites_jour'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Parse une liste de routines (matin ou soir).
  /// Chaque element est un Map avec "produit" et "raison".
  static List<Map<String, dynamic>> _parseRoutineList(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];
    return data.map((e) {
      if (e is Map) {
        return Map<String, dynamic>.from(e);
      }
      return <String, dynamic>{'produit': e.toString(), 'raison': ''};
    }).toList();
  }
}
