// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String,
  channelId: json['channelId'] as String,
  senderId: json['senderId'] as String,
  senderCallsign: json['senderCallsign'] as String? ?? '',
  senderRankAbbrev: json['senderRankAbbrev'] as String? ?? '',
  content: json['content'] as String,
  type:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
      MessageType.text,
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'senderId': instance.senderId,
      'senderCallsign': instance.senderCallsign,
      'senderRankAbbrev': instance.senderRankAbbrev,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.system: 'system',
  MessageType.taskCreated: 'taskCreated',
  MessageType.taskCompleted: 'taskCompleted',
  MessageType.promotionReceived: 'promotionReceived',
  MessageType.memberJoined: 'memberJoined',
  MessageType.memberLeft: 'memberLeft',
  MessageType.unitSplit: 'unitSplit',
};
