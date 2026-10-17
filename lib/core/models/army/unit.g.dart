// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Unit _$UnitFromJson(Map<String, dynamic> json) => _Unit(
  id: json['id'] as String,
  type: $enumDecode(_$UnitTypeEnumMap, json['type']),
  name: json['name'] as String,
  leaderId: json['leaderId'] as String?,
  secondInCommandId: json['secondInCommandId'] as String?,
  memberIds:
      (json['memberIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  parentUnitId: json['parentUnitId'] as String?,
  childUnitIds:
      (json['childUnitIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  chatChannelId: json['chatChannelId'] as String?,
  objectiveIds:
      (json['objectiveIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  maxSize: (json['maxSize'] as num?)?.toInt() ?? 10,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UnitToJson(_Unit instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$UnitTypeEnumMap[instance.type]!,
  'name': instance.name,
  'leaderId': instance.leaderId,
  'secondInCommandId': instance.secondInCommandId,
  'memberIds': instance.memberIds,
  'parentUnitId': instance.parentUnitId,
  'childUnitIds': instance.childUnitIds,
  'chatChannelId': instance.chatChannelId,
  'objectiveIds': instance.objectiveIds,
  'maxSize': instance.maxSize,
  'createdAt': instance.createdAt?.toIso8601String(),
};

const _$UnitTypeEnumMap = {
  UnitType.squad: 'squad',
  UnitType.section: 'section',
  UnitType.platoon: 'platoon',
  UnitType.company: 'company',
};
