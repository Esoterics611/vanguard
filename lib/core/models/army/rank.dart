/// Military rank enum with associated properties
/// Follows US Army rank structure from Guest to Captain
enum Rank {
  guest(
    abbreviation: '-',
    displayName: 'Guest',
    votingPower: 0,
    tokenMultiplierBasisPoints: 0,
    xpRequired: 0,
  ),
  pvt(
    abbreviation: 'PVT',
    displayName: 'Private',
    votingPower: 1,
    tokenMultiplierBasisPoints: 100,
    xpRequired: 0,
  ),
  pv2(
    abbreviation: 'PV2',
    displayName: 'Private 2nd Class',
    votingPower: 2,
    tokenMultiplierBasisPoints: 120,
    xpRequired: 5,
  ),
  pfc(
    abbreviation: 'PFC',
    displayName: 'Private First Class',
    votingPower: 3,
    tokenMultiplierBasisPoints: 150,
    xpRequired: 10,
  ),
  cpl(
    abbreviation: 'CPL',
    displayName: 'Corporal',
    votingPower: 5,
    tokenMultiplierBasisPoints: 200,
    xpRequired: 20,
  ),
  sgt(
    abbreviation: 'SGT',
    displayName: 'Sergeant',
    votingPower: 10,
    tokenMultiplierBasisPoints: 300,
    xpRequired: 40,
  ),
  ssg(
    abbreviation: 'SSG',
    displayName: 'Staff Sergeant',
    votingPower: 15,
    tokenMultiplierBasisPoints: 400,
    xpRequired: 60,
  ),
  sfc(
    abbreviation: 'SFC',
    displayName: 'Sergeant First Class',
    votingPower: 20,
    tokenMultiplierBasisPoints: 500,
    xpRequired: 80,
  ),
  firstSgt(
    abbreviation: '1SG',
    displayName: 'First Sergeant',
    votingPower: 25,
    tokenMultiplierBasisPoints: 600,
    xpRequired: 100,
  ),
  secondLt(
    abbreviation: '2LT',
    displayName: 'Second Lieutenant',
    votingPower: 30,
    tokenMultiplierBasisPoints: 800,
    xpRequired: 120,
  ),
  firstLt(
    abbreviation: '1LT',
    displayName: 'First Lieutenant',
    votingPower: 35,
    tokenMultiplierBasisPoints: 1000,
    xpRequired: 150,
  ),
  cpt(
    abbreviation: 'CPT',
    displayName: 'Captain',
    votingPower: 50,
    tokenMultiplierBasisPoints: 1500,
    xpRequired: 200,
  );

  const Rank({
    required this.abbreviation,
    required this.displayName,
    required this.votingPower,
    required this.tokenMultiplierBasisPoints,
    required this.xpRequired,
  });

  final String abbreviation;
  final String displayName;
  final int votingPower;
  final int tokenMultiplierBasisPoints;
  final int xpRequired;

  /// Token multiplier as a decimal (1.0 = 1x, 1.5 = 1.5x)
  double get tokenMultiplier => tokenMultiplierBasisPoints / 100;

  /// Whether this is an officer rank (2LT+)
  bool get isOfficer => index >= Rank.secondLt.index;

  /// Whether this is an NCO rank (SGT to 1SG)
  bool get isNCO => index >= Rank.sgt.index && index < Rank.secondLt.index;

  /// Whether this is an enlisted rank (PVT to CPL)
  bool get isEnlisted => index >= Rank.pvt.index && index < Rank.sgt.index;

  /// Whether this is Captain rank
  bool get isCaptain => this == Rank.cpt;

  /// Get the next rank (null if at max)
  Rank? get nextRank {
    final nextIndex = index + 1;
    if (nextIndex >= Rank.values.length) return null;
    return Rank.values[nextIndex];
  }

  /// Get the previous rank (null if at min)
  Rank? get previousRank {
    final prevIndex = index - 1;
    if (prevIndex < 0) return null;
    return Rank.values[prevIndex];
  }

  /// Check if this rank can promote someone to a target rank
  bool canPromoteTo(Rank targetRank, Rank currentRank) {
    // Must be promoting to adjacent rank
    if (targetRank.index != currentRank.index + 1) return false;

    switch (targetRank) {
      case Rank.pv2:
        return index >= Rank.ssg.index;
      case Rank.pfc:
      case Rank.cpl:
        return index >= Rank.secondLt.index;
      case Rank.sgt:
        return index >= Rank.cpt.index;
      case Rank.ssg:
      case Rank.sfc:
      case Rank.firstSgt:
        return this == Rank.cpt;
      case Rank.secondLt:
      case Rank.firstLt:
      case Rank.cpt:
        return false; // DAO only
      default:
        return false;
    }
  }

  static Rank fromString(String value) {
    return Rank.values.firstWhere(
      (r) => r.name == value || r.abbreviation == value,
      orElse: () => Rank.guest,
    );
  }
}
