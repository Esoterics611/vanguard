/// Types of organizational units in the Army hierarchy
enum UnitType {
  squad(
    displayName: 'Squad',
    minSize: 2,
    maxSize: 10,
    icon: '\u25C6', // ◆
    leaderRank: 'SGT',
  ),
  section(
    displayName: 'Section',
    minSize: 10,
    maxSize: 25,
    icon: '\ud83d\udd37', // 🔷
    leaderRank: 'SSG',
  ),
  platoon(
    displayName: 'Platoon',
    minSize: 20,
    maxSize: 50,
    icon: '\u2b50', // ⭐
    leaderRank: '2LT/1LT',
  ),
  company(
    displayName: 'Company',
    minSize: 40,
    maxSize: 100,
    icon: '\ud83c\udfdb\ufe0f', // 🏛️
    leaderRank: 'CPT',
  );

  const UnitType({
    required this.displayName,
    required this.minSize,
    required this.maxSize,
    required this.icon,
    required this.leaderRank,
  });

  final String displayName;
  final int minSize;
  final int maxSize;
  final String icon;
  final String leaderRank;

  /// Returns the split threshold (when unit should split)
  int get splitThreshold => maxSize + 1;

  /// Returns true if this unit type can have child units
  bool get canHaveChildren => this != UnitType.squad;

  /// Returns the child unit type
  UnitType? get childType {
    switch (this) {
      case UnitType.company:
        return UnitType.platoon;
      case UnitType.platoon:
        return UnitType.section;
      case UnitType.section:
        return UnitType.squad;
      case UnitType.squad:
        return null;
    }
  }

  /// Returns the parent unit type
  UnitType? get parentType {
    switch (this) {
      case UnitType.squad:
        return UnitType.section;
      case UnitType.section:
        return UnitType.platoon;
      case UnitType.platoon:
        return UnitType.company;
      case UnitType.company:
        return null;
    }
  }

  static UnitType fromString(String value) {
    return UnitType.values.firstWhere(
      (u) => u.name == value.toLowerCase(),
      orElse: () => UnitType.squad,
    );
  }
}
