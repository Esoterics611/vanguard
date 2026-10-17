import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_channel.freezed.dart';
part 'chat_channel.g.dart';

/// Type of chat channel
enum ChannelType {
  squad,
  sectionAnnounce,
  platoonAnnounce,
  companyBroadcast,
  directMessage,
}

/// Represents a chat channel in the comms system
@freezed
sealed class ChatChannel with _$ChatChannel {
  const ChatChannel._();

  const factory ChatChannel({
    required String id,
    required String unitId,
    required ChannelType type,
    required String name,
    @Default(null) DateTime? createdAt,
    @Default(0) int unreadCount,
    String? lastMessagePreview,
    DateTime? lastMessageAt,
  }) = _ChatChannel;

  factory ChatChannel.fromJson(Map<String, dynamic> json) =>
      _$ChatChannelFromJson(json);

  /// Check if this is a squad chat
  bool get isSquadChat => type == ChannelType.squad;

  /// Check if this is an announcement channel
  bool get isAnnouncement =>
      type == ChannelType.sectionAnnounce ||
      type == ChannelType.platoonAnnounce ||
      type == ChannelType.companyBroadcast;

  /// Check if this is a DM
  bool get isDirectMessage => type == ChannelType.directMessage;

  /// Check if there are unread messages
  bool get hasUnread => unreadCount > 0;

  /// Get the icon for this channel type
  String get typeIcon {
    switch (type) {
      case ChannelType.squad:
        return '#';
      case ChannelType.sectionAnnounce:
      case ChannelType.platoonAnnounce:
      case ChannelType.companyBroadcast:
        return '\ud83d\udce2'; // 📢
      case ChannelType.directMessage:
        return '\ud83d\udd35'; // 🔵
    }
  }
}
