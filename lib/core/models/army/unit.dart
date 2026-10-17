import 'package:freezed_annotation/freezed_annotation.dart';
import 'unit_type.dart';

part 'unit.freezed.dart';
part 'unit.g.dart';

/// Represents a unit (Squad, Section, Platoon, Company) in the Army hierarchy
@freezed
sealed class Unit with _$Unit {
  const Unit._();

  const factory Unit({
    required String id,
    required UnitType type,
    required String name,
    String? leaderId,
    String? secondInCommandId,
    @Default([]) List<String> memberIds,
    String? parentUnitId,
    @Default([]) List<String> childUnitIds,
    String? chatChannelId,
    @Default([]) List<String> objectiveIds,
    @Default(10) int maxSize,
    @Default(null) DateTime? createdAt,
  }) = _Unit;

  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);

  /// Current member count
  int get memberCount => memberIds.length;

  /// Check if unit is at capacity
  bool get isAtCapacity => memberCount >= maxSize;

  /// Check if unit should split (exceeds max size)
  bool get shouldSplit => memberCount > maxSize;

  /// Check if unit is near split threshold
  bool get isNearSplit => memberCount >= (maxSize * 0.9).floor();

  /// Percentage filled (0.0 to 1.0)
  double get fillPercentage => (memberCount / maxSize).clamp(0.0, 1.0);

  /// Members needed before split
  int get membersUntilSplit => (maxSize + 1) - memberCount;

  /// Check if unit has a parent
  bool get hasParent => parentUnitId != null;

  /// Check if unit has children
  bool get hasChildren => childUnitIds.isNotEmpty;
}
