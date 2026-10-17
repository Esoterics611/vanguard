// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graph_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SoldierNode _$SoldierNodeFromJson(Map<String, dynamic> json) => SoldierNode(
  id: json['id'] as String,
  rank: $enumDecode(_$RankEnumMap, json['rank']),
  callsign: json['callsign'] as String,
  isCurrentUser: json['isCurrentUser'] as bool? ?? false,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$SoldierNodeToJson(SoldierNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rank': _$RankEnumMap[instance.rank]!,
      'callsign': instance.callsign,
      'isCurrentUser': instance.isCurrentUser,
      'runtimeType': instance.$type,
    };

const _$RankEnumMap = {
  Rank.guest: 'guest',
  Rank.pvt: 'pvt',
  Rank.pv2: 'pv2',
  Rank.pfc: 'pfc',
  Rank.cpl: 'cpl',
  Rank.sgt: 'sgt',
  Rank.ssg: 'ssg',
  Rank.sfc: 'sfc',
  Rank.firstSgt: 'firstSgt',
  Rank.secondLt: 'secondLt',
  Rank.firstLt: 'firstLt',
  Rank.cpt: 'cpt',
};

UnitNode _$UnitNodeFromJson(Map<String, dynamic> json) => UnitNode(
  id: json['id'] as String,
  type: $enumDecode(_$UnitTypeEnumMap, json['type']),
  name: json['name'] as String,
  memberCount: (json['memberCount'] as num).toInt(),
  isUserUnit: json['isUserUnit'] as bool? ?? false,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$UnitNodeToJson(UnitNode instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$UnitTypeEnumMap[instance.type]!,
  'name': instance.name,
  'memberCount': instance.memberCount,
  'isUserUnit': instance.isUserUnit,
  'runtimeType': instance.$type,
};

const _$UnitTypeEnumMap = {
  UnitType.squad: 'squad',
  UnitType.section: 'section',
  UnitType.platoon: 'platoon',
  UnitType.company: 'company',
};

BountyNode _$BountyNodeFromJson(Map<String, dynamic> json) => BountyNode(
  id: json['id'] as String,
  title: json['title'] as String,
  reward: (json['reward'] as num).toInt(),
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$BountyNodeToJson(BountyNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'reward': instance.reward,
      'runtimeType': instance.$type,
    };
