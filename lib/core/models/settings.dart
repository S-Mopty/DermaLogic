// DermaLogic v3 - Modele Settings
//
// Port de : Python core/models.py L277-298

/// Parametres de l'application.
class Settings {
  final String geminiApiKey;

  Settings({this.geminiApiKey = ''});

  /// Serialise en JSON (compatible v2 Python).
  Map<String, dynamic> toJson() {
    return {
      'gemini_api_key': geminiApiKey,
    };
  }

  /// Deserialise depuis JSON (compatible v2 Python).
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      geminiApiKey: json['gemini_api_key'] as String? ?? '',
    );
  }

  /// Copie avec modification partielle.
  Settings copyWith({String? geminiApiKey}) {
    return Settings(
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
    );
  }
}
