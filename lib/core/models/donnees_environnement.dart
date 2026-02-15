// DermaLogic v3 - Modeles Environnement
//
// Classes : DonneesEnvironnementales, PrevisionJournaliere, Localisation
//
// Port de : Python api/open_meteo.py L24-131

/// Donnees environnementales recuperees pour une localisation.
class DonneesEnvironnementales {
  final String date;
  final String heure;
  final double indiceUv;
  final double indiceUvMax;
  final double humiditeRelative;
  final double temperature;
  final double? pm25;
  final double? pm10;

  DonneesEnvironnementales({
    required this.date,
    required this.heure,
    required this.indiceUv,
    required this.indiceUvMax,
    required this.humiditeRelative,
    required this.temperature,
    this.pm25,
    this.pm10,
  });

  /// Categorisation OMS du niveau UV.
  String get niveauUv {
    if (indiceUv < 3) return 'Faible';
    if (indiceUv < 6) return 'Modere';
    if (indiceUv < 8) return 'Eleve';
    if (indiceUv < 11) return 'Tres eleve';
    return 'Extreme';
  }

  /// Categorisation du niveau d'humidite.
  String get niveauHumidite {
    if (humiditeRelative < 30) return 'Tres sec';
    if (humiditeRelative < 50) return 'Sec';
    if (humiditeRelative < 70) return 'Normal';
    return 'Humide';
  }

  /// Categorisation de la pollution (basee sur PM2.5 OMS).
  String get niveauPollution {
    if (pm25 == null) return 'Inconnu';
    if (pm25! < 10) return 'Excellent';
    if (pm25! < 25) return 'Bon';
    if (pm25! < 50) return 'Modere';
    if (pm25! < 75) return 'Mauvais';
    return 'Tres mauvais';
  }
}

/// Prevision meteo pour une journee.
class PrevisionJournaliere {
  final String date;
  final double uvMax;
  final double temperatureMax;
  final double temperatureMin;
  final double humiditeMoyenne;
  final double? pm25Moyen;

  PrevisionJournaliere({
    required this.date,
    required this.uvMax,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.humiditeMoyenne,
    this.pm25Moyen,
  });

  /// Serialise en JSON (pour le prompt IA).
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'uv_max': uvMax,
      'temperature_max': temperatureMax,
      'temperature_min': temperatureMin,
      'humidite_moyenne': humiditeMoyenne,
      'pm2_5_moyen': pm25Moyen,
    };
  }

  /// Deserialise depuis JSON.
  factory PrevisionJournaliere.fromJson(Map<String, dynamic> json) {
    return PrevisionJournaliere(
      date: json['date'] as String? ?? '',
      uvMax: (json['uv_max'] as num?)?.toDouble() ?? 0,
      temperatureMax: (json['temperature_max'] as num?)?.toDouble() ?? 0,
      temperatureMin: (json['temperature_min'] as num?)?.toDouble() ?? 0,
      humiditeMoyenne: (json['humidite_moyenne'] as num?)?.toDouble() ?? 50,
      pm25Moyen: (json['pm2_5_moyen'] as num?)?.toDouble(),
    );
  }
}

/// Represente une localisation geographique.
class Localisation {
  final String nom;
  final String pays;
  final double latitude;
  final double longitude;

  Localisation({
    required this.nom,
    required this.pays,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() => '$nom, $pays';
}
