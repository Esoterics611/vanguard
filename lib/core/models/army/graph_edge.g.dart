// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graph_edge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GraphEdge _$GraphEdgeFromJson(Map<String, dynamic> json) => _GraphEdge(
  fromId: json['fromId'] as String,
  toId: json['toId'] as String,
  type: $enumDecode(_$EdgeTypeEnumMap, json['type']),
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$GraphEdgeToJson(_GraphEdge instance) =>
    <String, dynamic>{
      'fromId': instance.fromId,
      'toId': instance.toId,
      'type': _$EdgeTypeEnumMap[instance.type]!,
      'metadata': instance.metadata,
    };

const _$EdgeTypeEnumMap = {
  EdgeType.memberOf: 'memberOf',
  EdgeType.leads: 'leads',
  EdgeType.secondInCommand: 'secondInCommand',
  EdgeType.parentUnit: 'parentUnit',
  EdgeType.childUnit: 'childUnit',
  EdgeType.assignedTo: 'assignedTo',
  EdgeType.contributesTo: 'contributesTo',
  EdgeType.fulfills: 'fulfills',
  EdgeType.canView: 'canView',
  EdgeType.canPromote: 'canPromote',
  EdgeType.appliedTo: 'appliedTo',
  EdgeType.invitedBy: 'invitedBy',
};
