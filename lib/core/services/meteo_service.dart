// DermaLogic v3 - MeteoService
//
// Client pour les APIs Open-Meteo (meteo + qualite de l'air + geocodage).
//
// URLs :
// - Meteo : https://api.open-meteo.com/v1/forecast
// - Air quality : https://air-quality-api.open-meteo.com/v1/air-quality
// - Geocodage : https://geocoding-api.open-meteo.com/v1/search
//
// Port de : Python api/open_meteo.py

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/donnees_environnement.dart';

/// Client pour les APIs Open-Meteo.
class MeteoService {
  static const _baseUrlMeteo = 'https://api.open-meteo.com/v1/forecast';
  static const _baseUrlAir = 'https://air-quality-api.open-meteo.com/v1/air-quality';
  static const _baseUrlGeo = 'https://geocoding-api.open-meteo.com/v1/search';

  double latitude;
  double longitude;
  String nomVille;

  MeteoService({
    this.latitude = 48.8566,
    this.longitude = 2.3522,
    this.nomVille = 'Paris',
  });

  /// Change la localisation courante.
  void setLocalisation(Localisation loc) {
    latitude = loc.latitude;
    longitude = loc.longitude;
    nomVille = loc.toString();
  }

  /// Recupere les donnees meteo depuis Open-Meteo.
  Future<Map<String, dynamic>?> _obtenirDonneesMeteo() async {
    final url = Uri.parse(_baseUrlMeteo).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,uv_index',
      'daily': 'uv_index_max',
      'timezone': 'auto',
    });

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('[API] Erreur meteo: $e');
    }
    return null;
  }

  /// Recupere les donnees de qualite de l'air depuis Open-Meteo.
  Future<Map<String, dynamic>?> _obtenirQualiteAir() async {
    final url = Uri.parse(_baseUrlAir).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': 'pm10,pm2_5',
      'timezone': 'auto',
    });

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('[API] Erreur qualite air: $e');
    }
    return null;
  }

  /// Recupere toutes les donnees environnementales du jour.
  Future<DonneesEnvironnementales?> obtenirDonneesJour() async {
    final donneesMeteo = await _obtenirDonneesMeteo();
    final donneesAir = await _obtenirQualiteAir();

    if (donneesMeteo == null) return null;

    final maintenant = DateTime.now();
    final current = donneesMeteo['current'] as Map<String, dynamic>? ?? {};
    final daily = donneesMeteo['daily'] as Map<String, dynamic>? ?? {};
    final airCurrent = donneesAir?['current'] as Map<String, dynamic>? ?? {};

    final uvMaxList = daily['uv_index_max'] as List<dynamic>?;

    return DonneesEnvironnementales(
      date: DateFormat('yyyy-MM-dd').format(maintenant),
      heure: DateFormat('HH:mm').format(maintenant),
      indiceUv: (current['uv_index'] as num?)?.toDouble() ?? 0,
      indiceUvMax: uvMaxList != null && uvMaxList.isNotEmpty
          ? (uvMaxList[0] as num?)?.toDouble() ?? 0
          : 0,
      humiditeRelative: (current['relative_humidity_2m'] as num?)?.toDouble() ?? 50,
      temperature: (current['temperature_2m'] as num?)?.toDouble() ?? 20,
      pm25: (airCurrent['pm2_5'] as num?)?.toDouble(),
      pm10: (airCurrent['pm10'] as num?)?.toDouble(),
    );
  }

  /// Recupere les previsions meteo sur 3 jours.
  Future<List<PrevisionJournaliere>> obtenirPrevisions3Jours() async {
    // Requete meteo quotidienne
    final urlMeteo = Uri.parse(_baseUrlMeteo).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'daily': 'uv_index_max,temperature_2m_max,temperature_2m_min,relative_humidity_2m_mean',
      'forecast_days': '3',
      'timezone': 'auto',
    });

    // Requete qualite de l'air horaire
    final urlAir = Uri.parse(_baseUrlAir).replace(queryParameters: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'hourly': 'pm2_5',
      'forecast_days': '3',
      'timezone': 'auto',
    });

    Map<String, dynamic>? dataMeteo;
    try {
      final resp = await http.get(urlMeteo).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        dataMeteo = jsonDecode(resp.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('[API] Erreur previsions meteo: $e');
      return [];
    }

    if (dataMeteo == null) return [];

    // Recuperer qualite de l'air (optionnel)
    final pm25ParJour = <String, double>{};
    try {
      final resp = await http.get(urlAir).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final dataAir = jsonDecode(resp.body) as Map<String, dynamic>;
        final hourly = dataAir['hourly'] as Map<String, dynamic>? ?? {};
        final heures = hourly['time'] as List<dynamic>? ?? [];
        final pm25Valeurs = hourly['pm2_5'] as List<dynamic>? ?? [];

        // Regrouper PM2.5 par jour
        final pm25ParJourListe = <String, List<double>>{};
        for (var i = 0; i < heures.length && i < pm25Valeurs.length; i++) {
          if (pm25Valeurs[i] != null) {
            final jour = (heures[i] as String).substring(0, 10);
            pm25ParJourListe.putIfAbsent(jour, () => []);
            pm25ParJourListe[jour]!.add((pm25Valeurs[i] as num).toDouble());
          }
        }

        // Calculer les moyennes
        for (final entry in pm25ParJourListe.entries) {
          final vals = entry.value;
          pm25ParJour[entry.key] = vals.reduce((a, b) => a + b) / vals.length;
        }
      }
    } catch (_) {
      // Pas grave si on n'a pas la qualite de l'air
    }

    // Construire les previsions
    final daily = dataMeteo['daily'] as Map<String, dynamic>? ?? {};
    final dates = daily['time'] as List<dynamic>? ?? [];
    final uvMax = daily['uv_index_max'] as List<dynamic>? ?? [];
    final tempMax = daily['temperature_2m_max'] as List<dynamic>? ?? [];
    final tempMin = daily['temperature_2m_min'] as List<dynamic>? ?? [];
    final humidite = daily['relative_humidity_2m_mean'] as List<dynamic>? ?? [];

    final previsions = <PrevisionJournaliere>[];
    for (var i = 0; i < dates.length; i++) {
      final date = dates[i] as String;
      previsions.add(PrevisionJournaliere(
        date: date,
        uvMax: i < uvMax.length ? (uvMax[i] as num?)?.toDouble() ?? 0 : 0,
        temperatureMax: i < tempMax.length ? (tempMax[i] as num?)?.toDouble() ?? 0 : 0,
        temperatureMin: i < tempMin.length ? (tempMin[i] as num?)?.toDouble() ?? 0 : 0,
        humiditeMoyenne: i < humidite.length ? (humidite[i] as num?)?.toDouble() ?? 50 : 50,
        pm25Moyen: pm25ParJour[date],
      ));
    }

    return previsions;
  }

  /// Recherche de villes par nom (geocodage).
  static Future<List<Localisation>> rechercherVilles(
    String query, {
    int limit = 5,
  }) async {
    final url = Uri.parse(_baseUrlGeo).replace(queryParameters: {
      'name': query,
      'count': limit.toString(),
      'language': 'fr',
      'format': 'json',
    });

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>? ?? [];
        return results.map((r) {
          final m = r as Map<String, dynamic>;
          return Localisation(
            nom: m['name'] as String? ?? '',
            pays: m['country'] as String? ?? '',
            latitude: (m['latitude'] as num?)?.toDouble() ?? 0,
            longitude: (m['longitude'] as num?)?.toDouble() ?? 0,
          );
        }).toList();
      }
    } catch (e) {
      print('[API] Erreur recherche ville: $e');
    }
    return [];
  }
}
