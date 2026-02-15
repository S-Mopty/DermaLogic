// DermaLogic v3 - Modeles VilleConfig + Configuration
//
// Port de : Python core/config.py L22-99

/// Configuration d'une ville avec ses donnees meteo en cache.
class VilleConfig {
  final String nom;
  final String pays;
  final double latitude;
  final double longitude;
  final String derniereMaj;
  final double indiceUv;
  final double humidite;
  final double temperature;
  final double? pm25;

  VilleConfig({
    required this.nom,
    required this.pays,
    required this.latitude,
    required this.longitude,
    this.derniereMaj = '',
    this.indiceUv = 0.0,
    this.humidite = 50.0,
    this.temperature = 20.0,
    this.pm25,
  });

  /// Serialise en JSON (compatible v2 Python).
  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'pays': pays,
      'latitude': latitude,
      'longitude': longitude,
      'derniere_maj': derniereMaj,
      'indice_uv': indiceUv,
      'humidite': humidite,
      'temperature': temperature,
      'pm2_5': pm25,
    };
  }

  /// Deserialise depuis JSON (compatible v2 Python).
  factory VilleConfig.fromJson(Map<String, dynamic> json) {
    return VilleConfig(
      nom: json['nom'] as String? ?? 'Paris',
      pays: json['pays'] as String? ?? 'France',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 48.8566,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 2.3522,
      derniereMaj: json['derniere_maj'] as String? ?? '',
      indiceUv: (json['indice_uv'] as num?)?.toDouble() ?? 0.0,
      humidite: (json['humidite'] as num?)?.toDouble() ?? 50.0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 20.0,
      pm25: (json['pm2_5'] as num?)?.toDouble(),
    );
  }

  /// Copie avec modification partielle.
  VilleConfig copyWith({
    String? nom,
    String? pays,
    double? latitude,
    double? longitude,
    String? derniereMaj,
    double? indiceUv,
    double? humidite,
    double? temperature,
    double? pm25,
  }) {
    return VilleConfig(
      nom: nom ?? this.nom,
      pays: pays ?? this.pays,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      derniereMaj: derniereMaj ?? this.derniereMaj,
      indiceUv: indiceUv ?? this.indiceUv,
      humidite: humidite ?? this.humidite,
      temperature: temperature ?? this.temperature,
      pm25: pm25 ?? this.pm25,
    );
  }

  @override
  String toString() => '$nom, $pays';
}

/// Configuration globale de l'application.
class Configuration {
  final VilleConfig villeActuelle;
  final List<VilleConfig> villesFavorites;

  Configuration({
    VilleConfig? villeActuelle,
    this.villesFavorites = const [],
  }) : villeActuelle = villeActuelle ??
            VilleConfig(
              nom: 'Paris',
              pays: 'France',
              latitude: 48.8566,
              longitude: 2.3522,
            );

  /// Serialise en JSON (compatible v2 Python).
  Map<String, dynamic> toJson() {
    return {
      'ville_actuelle': villeActuelle.toJson(),
      'villes_favorites': villesFavorites.map((v) => v.toJson()).toList(),
    };
  }

  /// Deserialise depuis JSON (compatible v2 Python).
  factory Configuration.fromJson(Map<String, dynamic> json) {
    final villeActuelle =
        VilleConfig.fromJson(json['ville_actuelle'] as Map<String, dynamic>? ?? {});
    final favorites = (json['villes_favorites'] as List<dynamic>?)
            ?.map((v) => VilleConfig.fromJson(v as Map<String, dynamic>))
            .toList() ??
        [];
    return Configuration(
      villeActuelle: villeActuelle,
      villesFavorites: favorites,
    );
  }

  /// Copie avec modification partielle.
  Configuration copyWith({
    VilleConfig? villeActuelle,
    List<VilleConfig>? villesFavorites,
  }) {
    return Configuration(
      villeActuelle: villeActuelle ?? this.villeActuelle,
      villesFavorites: villesFavorites ?? this.villesFavorites,
    );
  }
}
