// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatChannel _$ChatChannelFromJson(Map<String, dynamic> json) => _ChatChannel(
  id: json['id'] as String,
  unitId: json['unitId'] as String,
  type: $enumDecode(_$ChannelTypeEnumMap, json['type']),
  name: json['name'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  lastMessagePreview: json['lastMessagePreview'] as String?,
  lastMessageAt: json['lastMessageAt'] == null
      ? null
      : DateTime.parse(json['lastMessageAt'] as String),
);

Map<String, dynamic> _$ChatChannelToJson(_ChatChannel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unitId': instance.unitId,
      'type': _$ChannelTypeEnumMap[instance.type]!,
      'name': instance.name,
      'createdAt': instance.createdAt?.toIso8601String(),
      'unreadCount': instance.unreadCount,
      'lastMessagePreview': instance.lastMessagePreview,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
    };

const _$ChannelTypeEnumMap = {
  ChannelType.squad: 'squad',
  ChannelType.sectionAnnounce: 'sectionAnnounce',
  ChannelType.platoonAnnounce: 'platoonAnnounce',
  ChannelType.companyBroadcast: 'companyBroadcast',
  ChannelType.directMessage: 'directMessage',
};
