import 'package:freezed_annotation/freezed_annotation.dart';

part 'graph_edge.freezed.dart';
part 'graph_edge.g.dart';

/// Type of edge/relationship in the graph
enum EdgeType {
  memberOf,
  leads,
  secondInCommand,
  parentUnit,
  childUnit,
  assignedTo,
  contributesTo,
  fulfills,
  canView,
  canPromote,
  appliedTo,
  invitedBy,
}

/// Represents an edge (relationship) in the Army network graph
@freezed
sealed class GraphEdge with _$GraphEdge {
  const GraphEdge._();

  const factory GraphEdge({
    required String fromId,
    required String toId,
    required EdgeType type,
    Map<String, dynamic>? metadata,
  }) = _GraphEdge;

  factory GraphEdge.fromJson(Map<String, dynamic> json) =>
      _$GraphEdgeFromJson(json);

  /// Check if this is a hierarchy edge
  bool get isHierarchyEdge =>
      type == EdgeType.parentUnit || type == EdgeType.childUnit;

  /// Check if this is a membership edge
  bool get isMembershipEdge =>
      type == EdgeType.memberOf ||
      type == EdgeType.leads ||
      type == EdgeType.secondInCommand;

  /// Check if this is a work edge
  bool get isWorkEdge =>
      type == EdgeType.assignedTo ||
      type == EdgeType.contributesTo ||
      type == EdgeType.fulfills;

  /// Get display label for the edge
  String get displayLabel {
    switch (type) {
      case EdgeType.memberOf:
        return 'Member';
      case EdgeType.leads:
        return 'Leads';
      case EdgeType.secondInCommand:
        return '2IC';
      case EdgeType.parentUnit:
        return 'Parent';
      case EdgeType.childUnit:
        return 'Child';
      case EdgeType.assignedTo:
        return 'Assigned';
      case EdgeType.contributesTo:
        return 'Contributes';
      case EdgeType.fulfills:
        return 'Fulfills';
      case EdgeType.canView:
        return 'Can View';
      case EdgeType.canPromote:
        return 'Can Promote';
      case EdgeType.appliedTo:
        return 'Applied';
      case EdgeType.invitedBy:
        return 'Invited By';
    }
  }
}
