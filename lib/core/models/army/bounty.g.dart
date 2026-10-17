// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bounty.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bounty _$BountyFromJson(Map<String, dynamic> json) => _Bounty(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  creatorId: json['creatorId'] as String,
  totalAmount: (json['totalAmount'] as num).toInt(),
  remainingAmount: (json['remainingAmount'] as num?)?.toInt() ?? 0,
  deadline: DateTime.parse(json['deadline'] as String),
  status:
      $enumDecodeNullable(_$BountyStatusEnumMap, json['status']) ??
      BountyStatus.draft,
  objectiveIds:
      (json['objectiveIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  skillTags:
      (json['skillTags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$BountyToJson(_Bounty instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'creatorId': instance.creatorId,
  'totalAmount': instance.totalAmount,
  'remainingAmount': instance.remainingAmount,
  'deadline': instance.deadline.toIso8601String(),
  'status': _$BountyStatusEnumMap[instance.status]!,
  'objectiveIds': instance.objectiveIds,
  'skillTags': instance.skillTags,
  'createdAt': instance.createdAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
};

const _$BountyStatusEnumMap = {
  BountyStatus.draft: 'draft',
  BountyStatus.active: 'active',
  BountyStatus.inProgress: 'inProgress',
  BountyStatus.completed: 'completed',
  BountyStatus.cancelled: 'cancelled',
};
