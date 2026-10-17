// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'objective.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Objective _$ObjectiveFromJson(Map<String, dynamic> json) => _Objective(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  unitId: json['unitId'] as String,
  bountyId: json['bountyId'] as String,
  status:
      $enumDecodeNullable(_$ObjectiveStatusEnumMap, json['status']) ??
      ObjectiveStatus.active,
  taskIds:
      (json['taskIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  allocatedVgrd: (json['allocatedVgrd'] as num).toInt(),
  deadline: DateTime.parse(json['deadline'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  createdById: json['createdById'] as String?,
);

Map<String, dynamic> _$ObjectiveToJson(_Objective instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'unitId': instance.unitId,
      'bountyId': instance.bountyId,
      'status': _$ObjectiveStatusEnumMap[instance.status]!,
      'taskIds': instance.taskIds,
      'allocatedVgrd': instance.allocatedVgrd,
      'deadline': instance.deadline.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'createdById': instance.createdById,
    };

const _$ObjectiveStatusEnumMap = {
  ObjectiveStatus.active: 'active',
  ObjectiveStatus.inProgress: 'inProgress',
  ObjectiveStatus.completed: 'completed',
  ObjectiveStatus.cancelled: 'cancelled',
};
