import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// Type of chat message
enum MessageType {
  text,
  system,
  taskCreated,
  taskCompleted,
  promotionReceived,
  memberJoined,
  memberLeft,
  unitSplit,
}

/// Represents a message in a chat channel
@freezed
sealed class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required String channelId,
    required String senderId,
    @Default('') String senderCallsign,
    @Default('') String senderRankAbbrev,
    required String content,
    @Default(MessageType.text) MessageType type,
    Map<String, dynamic>? metadata,
    @Default(null) DateTime? createdAt,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  /// Check if this is a system message
  bool get isSystemMessage => type != MessageType.text;

  /// Format the timestamp for display
  String get formattedTime {
    final now = DateTime.now();
    final msgTime = createdAt ?? DateTime.now();
    final diff = now.difference(msgTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${msgTime.hour.toString().padLeft(2, '0')}:${msgTime.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${msgTime.month}/${msgTime.day}';
    }
  }

  /// Get the display name for system messages
  String get systemMessageTitle {
    switch (type) {
      case MessageType.taskCreated:
        return 'Task Created';
      case MessageType.taskCompleted:
        return 'Task Completed';
      case MessageType.promotionReceived:
        return 'Promotion';
      case MessageType.memberJoined:
        return 'New Member';
      case MessageType.memberLeft:
        return 'Member Left';
      case MessageType.unitSplit:
        return 'Unit Split';
      case MessageType.system:
        return 'System';
      case MessageType.text:
        return '';
    }
  }
}
