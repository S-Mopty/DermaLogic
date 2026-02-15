// DermaLogic v3 - Modele ProfilUtilisateur
//
// Enums : TypePeau, TrancheAge, ObjectifPeau
// Classe : ProfilUtilisateur
//
// Port de : Python core/models.py L148-211

/// Types de peau.
enum TypePeau {
  grasse('grasse'),
  seche('seche'),
  mixte('mixte'),
  normale('normale'),
  sensible('sensible');

  final String value;
  const TypePeau(this.value);

  factory TypePeau.fromString(String s) => TypePeau.values.firstWhere(
        (e) => e.value == s,
        orElse: () => TypePeau.normale,
      );
}

/// Tranches d'age.
enum TrancheAge {
  moins18('<18'),
  age1825('18-25'),
  age2635('26-35'),
  age3645('36-45'),
  age4655('46-55'),
  plus55('55+');

  final String value;
  const TrancheAge(this.value);

  factory TrancheAge.fromString(String s) => TrancheAge.values.firstWhere(
        (e) => e.value == s,
        orElse: () => TrancheAge.age2635,
      );
}

/// Objectifs de soin de la peau.
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

  factory ObjectifPeau.fromString(String s) => ObjectifPeau.values.firstWhere(
        (e) => e.value == s,
        orElse: () => ObjectifPeau.hydratation,
      );
}

/// Profil dermatologique de l'utilisateur.
class ProfilUtilisateur {
  final TypePeau typePeau;
  final TrancheAge trancheAge;
  final int niveauStress; // 1-10
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

  /// Serialise en JSON (compatible v2 Python).
  Map<String, dynamic> toJson() {
    return {
      'type_peau': typePeau.value,
      'tranche_age': trancheAge.value,
      'niveau_stress': niveauStress,
      'maladies_peau': maladiesPeau,
      'allergies': allergies,
      'objectifs': objectifs.map((o) => o.value).toList(),
      'instructions_quotidiennes': instructionsQuotidiennes,
    };
  }

  /// Deserialise depuis JSON (compatible v2 Python).
  factory ProfilUtilisateur.fromJson(Map<String, dynamic> json) {
    // Parser les objectifs avec gestion d'erreur
    final objectifsRaw = json['objectifs'] as List<dynamic>? ?? [];
    final objectifs = <ObjectifPeau>[];
    for (final o in objectifsRaw) {
      final str = o.toString();
      try {
        objectifs.add(ObjectifPeau.fromString(str));
      } catch (_) {
        // Ignorer les valeurs invalides
      }
    }

    return ProfilUtilisateur(
      typePeau: TypePeau.fromString(json['type_peau'] as String? ?? 'normale'),
      trancheAge:
          TrancheAge.fromString(json['tranche_age'] as String? ?? '26-35'),
      niveauStress:
          (json['niveau_stress'] as num?)?.toInt().clamp(1, 10) ?? 5,
      maladiesPeau: (json['maladies_peau'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      objectifs: objectifs,
      instructionsQuotidiennes:
          json['instructions_quotidiennes'] as String? ?? '',
    );
  }

  /// Copie avec modification partielle.
  ProfilUtilisateur copyWith({
    TypePeau? typePeau,
    TrancheAge? trancheAge,
    int? niveauStress,
    List<String>? maladiesPeau,
    List<String>? allergies,
    List<ObjectifPeau>? objectifs,
    String? instructionsQuotidiennes,
  }) {
    return ProfilUtilisateur(
      typePeau: typePeau ?? this.typePeau,
      trancheAge: trancheAge ?? this.trancheAge,
      niveauStress: niveauStress ?? this.niveauStress,
      maladiesPeau: maladiesPeau ?? this.maladiesPeau,
      allergies: allergies ?? this.allergies,
      objectifs: objectifs ?? this.objectifs,
      instructionsQuotidiennes:
          instructionsQuotidiennes ?? this.instructionsQuotidiennes,
    );
  }
}
