// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Task _$TaskFromJson(Map<String, dynamic> json) => _Task(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  objectiveId: json['objectiveId'] as String,
  assigneeId: json['assigneeId'] as String?,
  status:
      $enumDecodeNullable(_$TaskStatusEnumMap, json['status']) ??
      TaskStatus.created,
  priority:
      $enumDecodeNullable(_$TaskPriorityEnumMap, json['priority']) ??
      TaskPriority.medium,
  rewardVgrd: (json['rewardVgrd'] as num).toInt(),
  deadline: DateTime.parse(json['deadline'] as String),
  submissionIpfsHash: json['submissionIpfsHash'] as String?,
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  createdById: json['createdById'] as String?,
);

Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'objectiveId': instance.objectiveId,
  'assigneeId': instance.assigneeId,
  'status': _$TaskStatusEnumMap[instance.status]!,
  'priority': _$TaskPriorityEnumMap[instance.priority]!,
  'rewardVgrd': instance.rewardVgrd,
  'deadline': instance.deadline.toIso8601String(),
  'submissionIpfsHash': instance.submissionIpfsHash,
  'completedAt': instance.completedAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'createdById': instance.createdById,
};

const _$TaskStatusEnumMap = {
  TaskStatus.created: 'created',
  TaskStatus.assigned: 'assigned',
  TaskStatus.inProgress: 'inProgress',
  TaskStatus.blocked: 'blocked',
  TaskStatus.submitted: 'submitted',
  TaskStatus.completed: 'completed',
  TaskStatus.failed: 'failed',
};

const _$TaskPriorityEnumMap = {
  TaskPriority.low: 'low',
  TaskPriority.medium: 'medium',
  TaskPriority.high: 'high',
  TaskPriority.critical: 'critical',
};
