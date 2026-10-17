import 'package:freezed_annotation/freezed_annotation.dart';
import 'rank.dart';
import 'unit_type.dart';

part 'graph_node.freezed.dart';
part 'graph_node.g.dart';

/// Type of graph node
enum GraphNodeType {
  soldier,
  unit,
  bounty,
  objective,
  task,
}

/// Represents a node in the Army network graph
@freezed
sealed class GraphNode with _$GraphNode {
  const GraphNode._();

  const factory GraphNode.soldier({
    required String id,
    required Rank rank,
    required String callsign,
    @Default(false) bool isCurrentUser,
  }) = SoldierNode;

  const factory GraphNode.unit({
    required String id,
    required UnitType type,
    required String name,
    required int memberCount,
    @Default(false) bool isUserUnit,
  }) = UnitNode;

  const factory GraphNode.bounty({
    required String id,
    required String title,
    required int reward,
  }) = BountyNode;

  factory GraphNode.fromJson(Map<String, dynamic> json) =>
      _$GraphNodeFromJson(json);

  /// Get the node type
  GraphNodeType get nodeType {
    return map(
      soldier: (_) => GraphNodeType.soldier,
      unit: (_) => GraphNodeType.unit,
      bounty: (_) => GraphNodeType.bounty,
    );
  }

  /// Get display label for the node
  String get displayLabel {
    return map(
      soldier: (s) => s.callsign,
      unit: (u) => u.name,
      bounty: (b) => b.title,
    );
  }

  /// Get size multiplier for visualization
  double get sizeMultiplier {
    return map(
      soldier: (s) => 1.0 + (s.rank.index * 0.1),
      unit: (u) => 1.0 + (u.type.index * 0.3),
      bounty: (b) => 1.5,
    );
  }
}
