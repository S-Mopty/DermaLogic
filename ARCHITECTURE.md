# DermaLogic v3 - Architecture de Reference

> Ce fichier documente toutes les interfaces (classes, enums, methodes, types)
> pour garantir la compatibilite entre tous les modules du projet.
>
> **Regle** : tout nouveau fichier doit respecter les signatures definies ici.

---

## Structure des dossiers

```
lib/
|-- main.dart
|-- core/
|   |-- models/
|   |   |-- produit_derma.dart
|   |   |-- profil_utilisateur.dart
|   |   |-- entree_historique.dart
|   |   |-- settings.dart
|   |   |-- donnees_environnement.dart
|   |   +-- ville_config.dart
|   |-- repositories/
|   |   |-- settings_repository.dart
|   |   |-- config_repository.dart
|   |   |-- profil_repository.dart
|   |   |-- historique_repository.dart
|   |   +-- produit_repository.dart
|   +-- services/
|       |-- gemini_service.dart
|       |-- meteo_service.dart
|       +-- analyseur_service.dart
|-- providers/
|   |-- settings_provider.dart
|   |-- config_provider.dart
|   |-- produit_provider.dart
|   |-- profil_provider.dart
|   |-- historique_provider.dart
|   |-- meteo_provider.dart
|   +-- analyse_provider.dart
|-- utils/
|   |-- json_utils.dart
|   +-- constants.dart
+-- ui/ (plus tard)
```

---

## 1. MODELS (`lib/core/models/`)

### 1.1 `produit_derma.dart`

```dart
/// Categories de produits dermatologiques.
enum Categorie {
  cleanser('cleanser'),
  treatment('treatment'),
  moisturizer('moisturizer'),
  protection('protection');

  final String value;
  const Categorie(this.value);

  factory Categorie.fromString(String s) =>
      Categorie.values.firstWhere((e) => e.value == s, orElse: () => Categorie.moisturizer);
}

/// Tags d'action principale des actifs.
enum ActiveTag {
  acne('acne'),
  hydration('hydration'),
  repair('repair');

  final String value;
  const ActiveTag(this.value);

  factory ActiveTag.fromString(String s) =>
      ActiveTag.values.firstWhere((e) => e.value == s, orElse: () => ActiveTag.hydration);
}

/// Moment d'utilisation recommande du produit.
enum MomentUtilisation {
  matin('matin'),
  journee('journee'),
  soir('soir'),
  tous('tous');

  final String value;
  const MomentUtilisation(this.value);

  factory MomentUtilisation.fromString(String s) =>
      MomentUtilisation.values.firstWhere((e) => e.value == s, orElse: () => MomentUtilisation.tous);
}

/// Representation d'un produit dermatologique.
class ProduitDerma {
  final String nom;
  final Categorie category;
  final MomentUtilisation moment;
  final bool photosensitive;
  final int occlusivity;      // 1-5
  final int cleansingPower;   // 1-5
  final ActiveTag activeTag;
  final Map<String, dynamic> customAttributes;

  ProduitDerma({
    required this.nom,
    required this.category,
    this.moment = MomentUtilisation.tous,
    this.photosensitive = false,
    this.occlusivity = 3,
    this.cleansingPower = 3,
    this.activeTag = ActiveTag.hydration,
    this.customAttributes = const {},
  }) : assert(occlusivity >= 1 && occlusivity <= 5),
       assert(cleansingPower >= 1 && cleansingPower <= 5);

  Map<String, dynamic> toJson();
  factory ProduitDerma.fromJson(Map<String, dynamic> json);
  ProduitDerma copyWith({...});
}
```

### 1.2 `profil_utilisateur.dart`

```dart
enum TypePeau {
  grasse('grasse'),
  seche('seche'),
  mixte('mixte'),
  normale('normale'),
  sensible('sensible');

  final String value;
  const TypePeau(this.value);
  factory TypePeau.fromString(String s);
}

enum TrancheAge {
  moins18('<18'),
  age1825('18-25'),
  age2635('26-35'),
  age3645('36-45'),
  age4655('46-55'),
  plus55('55+');

  final String value;
  const TrancheAge(this.value);
  factory TrancheAge.fromString(String s);
}

enum ObjectifPeau {
  hydratation('hydratation'),
  antiAcne('anti-acne'),
  eclat('eclat'),
  antiTaches('anti-taches'),
  antiAge('anti-age'),
  apaisement('apaisement'),
  protection('protection');

  final String value;
  const ObjectifPeau(this.value);
  factory ObjectifPeau.fromString(String s);
}

class ProfilUtilisateur {
  final TypePeau typePeau;
  final TrancheAge trancheAge;
  final int niveauStress;           // 1-10
  final List<String> maladiesPeau;
  final List<String> allergies;
  final List<ObjectifPeau> objectifs;
  final String instructionsQuotidiennes;

  ProfilUtilisateur({
    this.typePeau = TypePeau.normale,
    this.trancheAge = TrancheAge.age2635,
    this.niveauStress = 5,
    this.maladiesPeau = const [],
    this.allergies = const [],
    this.objectifs = const [],
    this.instructionsQuotidiennes = '',
  });

  Map<String, dynamic> toJson();
  factory ProfilUtilisateur.fromJson(Map<String, dynamic> json);
  ProfilUtilisateur copyWith({...});
}
```

### 1.3 `entree_historique.dart`

```dart
class EntreeHistorique {
  final String id;
  final String date;                         // ISO 8601
  final String mode;                         // "rapide" | "detaille"
  final String resumeIa;
  final List<Map<String, String>> routineMatin;   // [{produit, raison}]
  final List<Map<String, String>> routineSoir;    // [{produit, raison}]
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

  Map<String, dynamic> toJson();
  factory EntreeHistorique.fromJson(Map<String, dynamic> json);
}
```

### 1.4 `settings.dart`

```dart
class Settings {
  final String geminiApiKey;

  Settings({this.geminiApiKey = ''});

  Map<String, dynamic> toJson();
  factory Settings.fromJson(Map<String, dynamic> json);
  Settings copyWith({String? geminiApiKey});
}
```

### 1.5 `donnees_environnement.dart`

```dart
class DonneesEnvironnementales {
  final String date;
  final String heure;
  final double indiceUv;
  final double indiceUvMax;
  final double humiditeRelative;
  final double temperature;
  final double? pm25;
  final double? pm10;

  DonneesEnvironnementales({...});

  /// Categorisation OMS du niveau UV.
  String get niveauUv;    // "Faible" | "Modere" | "Eleve" | "Tres eleve" | "Extreme"

  /// Categorisation du niveau d'humidite.
  String get niveauHumidite;  // "Tres sec" | "Sec" | "Normal" | "Humide"

  /// Categorisation de la pollution (basee sur PM2.5 OMS).
  String get niveauPollution; // "Inconnu" | "Excellent" | "Bon" | "Modere" | "Mauvais" | "Tres mauvais"
}

class PrevisionJournaliere {
  final String date;
  final double uvMax;
  final double temperatureMax;
  final double temperatureMin;
  final double humiditeMoyenne;
  final double? pm25Moyen;

  PrevisionJournaliere({...});

  Map<String, dynamic> toJson();
  factory PrevisionJournaliere.fromJson(Map<String, dynamic> json);
}

class Localisation {
  final String nom;
  final String pays;
  final double latitude;
  final double longitude;

  Localisation({...});

  @override
  String toString() => '$nom, $pays';
}
```

### 1.6 `ville_config.dart`

```dart
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

  Map<String, dynamic> toJson();
  factory VilleConfig.fromJson(Map<String, dynamic> json);
  VilleConfig copyWith({...});

  @override
  String toString() => '$nom, $pays';
}

class Configuration {
  final VilleConfig villeActuelle;
  final List<VilleConfig> villesFavorites;

  Configuration({
    VilleConfig? villeActuelle,
    this.villesFavorites = const [],
  }) : villeActuelle = villeActuelle ?? VilleConfig(
         nom: 'Paris', pays: 'France',
         latitude: 48.8566, longitude: 2.3522,
       );

  Map<String, dynamic> toJson();
  factory Configuration.fromJson(Map<String, dynamic> json);
  Configuration copyWith({...});
}
```

---

## 2. UTILS (`lib/utils/`)

### 2.1 `json_utils.dart`

```dart
/// Extrait un objet JSON d'un texte brut, meme entoure de texte.
/// Gere : blocs <think>, blocs ```json```, JSON imbrique.
/// Utilise un parseur brace-balanced pour fiabilite.
Map<String, dynamic>? extraireJson(String texte);
```

### 2.2 `constants.dart`

```dart
/// Prompt pour l'analyse IA d'un produit cosmetique.
/// Placeholder : {nom_produit}
/// Modele : gemini-2.0-flash, 512 tokens, temperature 0.2
const String promptAnalyseProduit = '''...''';

/// Prompt pour l'analyse de routine dermatologique.
/// Placeholders : {type_peau}, {tranche_age}, {niveau_stress},
///   {maladies_peau}, {allergies}, {objectifs}, {produits_json},
///   {ville}, {uv}, {niveau_uv}, {uv_max}, {humidite},
///   {niveau_humidite}, {temperature}, {pm25}, {niveau_pollution},
///   {previsions_json}, {historique_json}, {instructions_supplementaires}
/// Modele : gemini-2.5-flash, 8192 tokens, temperature 0.4
const String promptAnalyseRoutine = '''...''';

/// Couleurs du theme sombre
class AppColors {
  static const fond = Color(0xFF0F0F1A);
  static const panneau = Color(0xFF16213E);
  static const carte = Color(0xFF1A1A2E);
  static const accent = Color(0xFF4ECCA3);
  static const danger = Color(0xFFE94560);
  static const texteSecondaire = Color(0xFF888888);
}
```

---

## 3. REPOSITORIES (`lib/core/repositories/`)

Pattern commun a tous les repositories :
- Constructeur avec `Future<void> init()` pour charger le fichier JSON
- `_load()` : lecture fichier JSON depuis `path_provider`
- `_save()` : ecriture fichier JSON
- Methodes CRUD specifiques au domaine

### 3.1 `settings_repository.dart`

```dart
class SettingsRepository {
  Settings _settings = Settings();

  Future<void> init();                              // charge settings.json
  Settings get settings;
  Future<void> saveGeminiKey(String key);
  String get geminiKey;
}
```

### 3.2 `config_repository.dart`

```dart
class ConfigRepository {
  Configuration _config = Configuration();

  Future<void> init();                              // charge config.json

  // Ville actuelle
  VilleConfig get villeActuelle;
  Future<void> setVilleActuelle(VilleConfig ville);
  Future<void> updateMeteoActuelle({
    required double indiceUv,
    required double humidite,
    required double temperature,
    double? pm25,
  });

  // Favoris
  List<VilleConfig> get favorites;
  bool isFavorite(String nom, String pays);
  Future<void> addFavorite(VilleConfig ville);
  Future<void> removeFavorite(String nom, String pays);
  Future<bool> toggleFavorite(VilleConfig ville);   // true=ajoute, false=supprime
  Future<void> updateMeteoFavorite({
    required String nom,
    required String pays,
    required double indiceUv,
    required double humidite,
    required double temperature,
    double? pm25,
  });
}
```

### 3.3 `profil_repository.dart`

```dart
class ProfilRepository {
  ProfilUtilisateur _profil = ProfilUtilisateur();

  Future<void> init();                              // charge profile.json
  ProfilUtilisateur get profil;
  Future<void> save(ProfilUtilisateur profil);
}
```

### 3.4 `historique_repository.dart`

```dart
class HistoriqueRepository {
  List<EntreeHistorique> _historique = [];

  Future<void> init();                              // charge historique.json
  List<EntreeHistorique> get tous;                  // tries par date decroissante
  List<EntreeHistorique> recents(int n);            // n derniers
  Future<void> ajouter(EntreeHistorique entree);
}
```

### 3.5 `produit_repository.dart`

```dart
class ProduitRepository {
  List<ProduitDerma> _produits = [];

  Future<void> init();                              // charge produits_derma.json
  List<ProduitDerma> get tous;
  Future<void> ajouter(ProduitDerma produit);
  Future<void> modifier(int index, ProduitDerma produit);
  Future<void> supprimer(int index);
}
```

---

## 4. SERVICES (`lib/core/services/`)

### 4.1 `gemini_service.dart`

```dart
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

  ResultatAnalyseIA({...});
}

class GeminiService {
  final String apiKey;

  GeminiService({required this.apiKey});

  bool get estConfigure => apiKey.isNotEmpty;

  /// Appel generique a Gemini.
  /// [model] : "gemini-2.0-flash" ou "gemini-2.5-flash"
  Future<String?> generer(
    String prompt, {
    String model = 'gemini-2.0-flash',
    int maxTokens = 512,
    double temperature = 0.2,
  });

  /// Analyse un produit cosmetique.
  /// Modele : gemini-2.0-flash, 512 tokens, temperature 0.2
  Future<ResultatAnalyseIA> analyserProduit(String nomProduit);

  /// Genere une routine dermatologique personnalisee.
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
  });
}
```

### 4.2 `meteo_service.dart`

```dart
class MeteoService {
  double latitude;
  double longitude;
  String nomVille;

  MeteoService({
    this.latitude = 48.8566,
    this.longitude = 2.3522,
    this.nomVille = 'Paris',
  });

  void setLocalisation(Localisation loc);

  /// Donnees environnementales du jour (UV, humidite, temperature, PM2.5).
  Future<DonneesEnvironnementales?> obtenirDonneesJour();

  /// Previsions meteo sur 3 jours.
  Future<List<PrevisionJournaliere>> obtenirPrevisions3Jours();

  /// Recherche de villes par nom (geocodage).
  static Future<List<Localisation>> rechercherVilles(String query, {int limit = 5});
}
```

**URLs API :**
- Meteo : `https://api.open-meteo.com/v1/forecast`
- Air quality : `https://air-quality-api.open-meteo.com/v1/air-quality`
- Geocodage : `https://geocoding-api.open-meteo.com/v1/search`

### 4.3 `analyseur_service.dart`

```dart
class AnalyseurService {
  final ProduitRepository produits;
  final ProfilRepository profil;
  final HistoriqueRepository historique;
  final GeminiService gemini;

  AnalyseurService({
    required this.produits,
    required this.profil,
    required this.historique,
    required this.gemini,
  });

  /// Lance une analyse complete.
  /// Pipeline : collecte contexte -> appel Gemini 2.5 Flash -> sauvegarde historique
  Future<Map<String, dynamic>> analyser({
    required DonneesEnvironnementales conditionsActuelles,
    required List<PrevisionJournaliere> previsions,
    String ville = '',
    String mode = 'rapide',
    String instructionsJour = '',
    int? niveauStressJour,
  });
}
```

---

## 5. PROVIDERS (`lib/providers/`)

Tous les providers utilisent Riverpod AsyncNotifier.

| Provider | Type | Etat | Depend de |
|---|---|---|---|
| `settingsProvider` | `AsyncNotifierProvider<SettingsNotifier, Settings>` | Settings | SettingsRepository |
| `configProvider` | `AsyncNotifierProvider<ConfigNotifier, Configuration>` | Configuration | ConfigRepository |
| `produitProvider` | `AsyncNotifierProvider<ProduitNotifier, List<ProduitDerma>>` | List<ProduitDerma> | ProduitRepository |
| `profilProvider` | `AsyncNotifierProvider<ProfilNotifier, ProfilUtilisateur>` | ProfilUtilisateur | ProfilRepository |
| `historiqueProvider` | `AsyncNotifierProvider<HistoriqueNotifier, List<EntreeHistorique>>` | List<EntreeHistorique> | HistoriqueRepository |
| `meteoProvider` | `AsyncNotifierProvider<MeteoNotifier, DonneesEnvironnementales?>` | DonneesEnvironnementales? | MeteoService + ConfigProvider |
| `analyseProvider` | `AsyncNotifierProvider<AnalyseNotifier, Map<String, dynamic>?>` | Map? | AnalyseurService |

---

## 6. Correspondance Python -> Dart

| Python | Dart |
|---|---|
| `@dataclass` | `class` avec constructeur nomme |
| `field(default_factory=list)` | `= const []` |
| `Enum` | `enum` avec `final String value` |
| `Optional[float]` | `double?` |
| `list[ProduitDerma]` | `List<ProduitDerma>` |
| `dict` | `Map<String, dynamic>` |
| `vers_dict()` | `toJson()` |
| `depuis_dict()` | `fromJson()` (factory constructor) |
| `__post_init__` validation | `assert` dans constructeur |
| `@property` | getter (`String get niveauUv`) |
| `json.load/dump` | `jsonDecode/jsonEncode` |
| `Path / pathlib` | `path_provider` + `dart:io File` |
| `requests.get/post` | `http.get/post` |
| `threading.Thread` | `Future` / `async-await` |

---

## 7. Fichiers JSON (format identique a v2)

| Fichier | Contenu |
|---|---|
| `settings.json` | `{"gemini_api_key": "..."}` |
| `profile.json` | `{"type_peau": "...", "tranche_age": "...", ...}` |
| `produits_derma.json` | `[{"nom": "...", "category": "...", ...}]` |
| `historique.json` | `[{"id": "...", "date": "...", ...}]` |
| `config.json` | `{"ville_actuelle": {...}, "villes_favorites": [...]}` |

> Les formats JSON sont 100% compatibles avec la v2 Python
> pour permettre la migration des donnees.
