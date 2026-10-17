// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SquadApplication _$SquadApplicationFromJson(Map<String, dynamic> json) =>
    _SquadApplication(
      id: json['id'] as String,
      walletAddress: json['walletAddress'] as String,
      squadId: json['squadId'] as String,
      message: json['message'] as String?,
      status:
          $enumDecodeNullable(_$ApplicationStatusEnumMap, json['status']) ??
          ApplicationStatus.pending,
      reviewedById: json['reviewedById'] as String?,
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SquadApplicationToJson(_SquadApplication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'walletAddress': instance.walletAddress,
      'squadId': instance.squadId,
      'message': instance.message,
      'status': _$ApplicationStatusEnumMap[instance.status]!,
      'reviewedById': instance.reviewedById,
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ApplicationStatusEnumMap = {
  ApplicationStatus.pending: 'pending',
  ApplicationStatus.accepted: 'accepted',
  ApplicationStatus.rejected: 'rejected',
};
