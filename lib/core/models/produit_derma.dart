// DermaLogic v3 - Modele ProduitDerma
//
// Enums : Categorie, MomentUtilisation, ActiveTag
// Classe : ProduitDerma
//
// Port de : Python core/models.py L22-141

/// Categories de produits dermatologiques.
enum Categorie {
  cleanser('cleanser'),
  treatment('treatment'),
  moisturizer('moisturizer'),
  protection('protection');

  final String value;
  const Categorie(this.value);

  factory Categorie.fromString(String s) => Categorie.values.firstWhere(
        (e) => e.value == s,
        orElse: () => Categorie.moisturizer,
      );
}

/// Tags d'action principale des actifs.
enum ActiveTag {
  acne('acne'),
  hydration('hydration'),
  repair('repair');

  final String value;
  const ActiveTag(this.value);

  factory ActiveTag.fromString(String s) => ActiveTag.values.firstWhere(
        (e) => e.value == s,
        orElse: () => ActiveTag.hydration,
      );
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
      MomentUtilisation.values.firstWhere(
        (e) => e.value == s,
        orElse: () => MomentUtilisation.tous,
      );
}

/// Representation d'un produit dermatologique.
class ProduitDerma {
  final String nom;
  final Categorie category;
  final MomentUtilisation moment;
  final bool photosensitive;
  final int occlusivity; // 1-5
  final int cleansingPower; // 1-5
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
  })  : assert(occlusivity >= 1 && occlusivity <= 5,
            'occlusivity doit etre entre 1 et 5'),
        assert(cleansingPower >= 1 && cleansingPower <= 5,
            'cleansingPower doit etre entre 1 et 5');

  /// Serialise en JSON (compatible v2 Python).
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'nom': nom,
      'category': category.value,
      'moment': moment.value,
      'photosensitive': photosensitive,
      'occlusivity': occlusivity,
      'cleansing_power': cleansingPower,
      'active_tag': activeTag.value,
    };
    if (customAttributes.isNotEmpty) {
      map['custom_attributes'] = customAttributes;
    }
    return map;
  }

  /// Deserialise depuis JSON (compatible v2 Python).
  factory ProduitDerma.fromJson(Map<String, dynamic> json) {
    return ProduitDerma(
      nom: json['nom'] as String? ?? '',
      category: Categorie.fromString(json['category'] as String? ?? 'moisturizer'),
      moment: MomentUtilisation.fromString(json['moment'] as String? ?? 'tous'),
      photosensitive: json['photosensitive'] as bool? ?? false,
      occlusivity: (json['occlusivity'] as num?)?.toInt().clamp(1, 5) ?? 3,
      cleansingPower: (json['cleansing_power'] as num?)?.toInt().clamp(1, 5) ?? 3,
      activeTag: ActiveTag.fromString(json['active_tag'] as String? ?? 'hydration'),
      customAttributes:
          (json['custom_attributes'] as Map<String, dynamic>?) ?? {},
    );
  }

  /// Copie avec modification partielle.
  ProduitDerma copyWith({
    String? nom,
    Categorie? category,
    MomentUtilisation? moment,
    bool? photosensitive,
    int? occlusivity,
    int? cleansingPower,
    ActiveTag? activeTag,
    Map<String, dynamic>? customAttributes,
  }) {
    return ProduitDerma(
      nom: nom ?? this.nom,
      category: category ?? this.category,
      moment: moment ?? this.moment,
      photosensitive: photosensitive ?? this.photosensitive,
      occlusivity: occlusivity ?? this.occlusivity,
      cleansingPower: cleansingPower ?? this.cleansingPower,
      activeTag: activeTag ?? this.activeTag,
      customAttributes: customAttributes ?? this.customAttributes,
    );
  }

  @override
  String toString() => 'ProduitDerma($nom, ${category.value})';
}
