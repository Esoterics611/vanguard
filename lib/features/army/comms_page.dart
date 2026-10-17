import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/army_provider.dart';
import '../../core/models/army/army_models.dart';
import '../../app/theme/cyber_colors.dart';
import '../../app/theme/cyber_text_styles.dart';
import 'widgets/army_widgets.dart';

/// Comms - Chat Network screen
class CommsPage extends ConsumerWidget {
  const CommsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(chatChannelsProvider);
    final selectedChannel = ref.watch(selectedChannelProvider);

    return Scaffold(
      backgroundColor: CyberColors.spaceBlack,
      body: SafeArea(
        child: Row(
          children: [
            // Channel sidebar
            Container(
              width: 260,
              decoration: BoxDecoration(
                color: CyberColors.deepSpace,
                border: Border(
                  right: BorderSide(color: CyberColors.borderSubtle),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'COMMS',
                          style: CyberTextStyles.headlineLarge,
                        ),
                      ],
                    ),
                  ),

                  // Channels list
                  Expanded(
                    child: channelsAsync.when(
                      data: (channels) => _ChannelList(
                        channels: channels,
                        selectedId: selectedChannel,
                        onSelect: (id) {
                          ref.read(selectedChannelProvider.notifier).state = id;
                        },
                      ),
                      loading: () => const Center(
                        child: CircularProgressIndicator(
                          color: CyberColors.electricCyan,
                        ),
                      ),
                      error: (e, _) => Center(
                        child: Text(
                          'Error: $e',
                          style: CyberTextStyles.bodySmall.copyWith(
                            color: CyberColors.combatRed,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chat area
            Expanded(
              child: selectedChannel != null
                  ? _ChatArea(channelId: selectedChannel)
                  : const _EmptyChatArea(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelList extends StatelessWidget {
  final List<ChatChannel> channels;
  final String? selectedId;
  final Function(String) onSelect;

  const _ChannelList({
    required this.channels,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final squadChannels =
        channels.where((c) => c.type == ChannelType.squad).toList();
    final announceChannels = channels.where((c) => c.isAnnouncement).toList();
    final dmChannels =
        channels.where((c) => c.type == ChannelType.directMessage).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        if (squadChannels.isNotEmpty) ...[
          _ChannelSection(
            title: 'YOUR UNIT',
            channels: squadChannels,
            selectedId: selectedId,
            onSelect: onSelect,
          ),
        ],
        if (announceChannels.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ChannelSection(
            title: 'ANNOUNCEMENTS',
            channels: announceChannels,
            selectedId: selectedId,
            onSelect: onSelect,
          ),
        ],
        if (dmChannels.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ChannelSection(
            title: 'DIRECT MESSAGES',
            channels: dmChannels,
            selectedId: selectedId,
            onSelect: onSelect,
          ),
        ],
      ],
    );
  }
}

class _ChannelSection extends StatelessWidget {
  final String title;
  final List<ChatChannel> channels;
  final String? selectedId;
  final Function(String) onSelect;

  const _ChannelSection({
    required this.title,
    required this.channels,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            title,
            style: CyberTextStyles.labelSmall.copyWith(
              letterSpacing: 1,
            ),
          ),
        ),
        ...channels.map(
          (channel) => _ChannelTile(
            channel: channel,
            isSelected: channel.id == selectedId,
            onTap: () => onSelect(channel.id),
          ),
        ),
      ],
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final ChatChannel channel;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChannelTile({
    required this.channel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? CyberColors.electricCyan.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              channel.typeIcon,
              style: TextStyle(
                color: isSelected
                    ? CyberColors.electricCyan
                    : CyberColors.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                channel.name,
                style: CyberTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? CyberColors.electricCyan
                      : CyberColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (channel.hasUnread)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CyberColors.combatRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${channel.unreadCount}',
                  style: CyberTextStyles.labelSmall.copyWith(
                    color: CyberColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatArea extends ConsumerWidget {
  final String channelId;

  const _ChatArea({required this.channelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(channelMessagesStreamProvider(channelId));
    final channelsAsync = ref.watch(chatChannelsProvider);

    final channel = channelsAsync.whenOrNull(
      data: (channels) => channels.firstWhere((c) => c.id == channelId),
    );

    return Column(
      children: [
        // Channel header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CyberColors.deepSpace,
            border: Border(
              bottom: BorderSide(color: CyberColors.borderSubtle),
            ),
          ),
          child: Row(
            children: [
              Text(
                channel?.typeIcon ?? '#',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                channel?.name ?? 'Channel',
                style: CyberTextStyles.headlineSmall,
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: messagesAsync.when(
            data: (messages) => ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return _MessageBubble(message: message);
              },
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: CyberColors.electricCyan,
              ),
            ),
            error: (e, _) => Center(
              child: Text(
                'Error: $e',
                style: CyberTextStyles.bodyMedium.copyWith(
                  color: CyberColors.combatRed,
                ),
              ),
            ),
          ),
        ),

        // Message input
        _MessageInput(channelId: channelId),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isSystemMessage) {
      return _SystemMessage(message: message);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CyberColors.darkPanel,
              border: Border.all(color: CyberColors.borderSubtle),
            ),
            child: const Icon(
              Icons.person,
              size: 20,
              color: CyberColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (message.senderRankAbbrev.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: CyberColors.ncoSilver.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          message.senderRankAbbrev,
                          style: CyberTextStyles.labelSmall.copyWith(
                            color: CyberColors.ncoSilver,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    CallsignText(
                      callsign: message.senderCallsign,
                      fontSize: 13,
                      showGlow: false,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      message.formattedTime,
                      style: CyberTextStyles.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message.content,
                  style: CyberTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemMessage extends StatelessWidget {
  final ChatMessage message;

  const _SystemMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CyberColors.electricCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CyberColors.electricCyan.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.bolt,
            size: 16,
            color: CyberColors.electricCyan,
          ),
          const SizedBox(width: 8),
          Text(
            message.systemMessageTitle,
            style: CyberTextStyles.labelMedium.copyWith(
              color: CyberColors.electricCyan,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message.content,
              style: CyberTextStyles.bodySmall,
            ),
          ),
          Text(
            message.formattedTime,
            style: CyberTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _MessageInput extends ConsumerStatefulWidget {
  final String channelId;

  const _MessageInput({required this.channelId});

  @override
  ConsumerState<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<_MessageInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberColors.deepSpace,
        border: Border(
          top: BorderSide(color: CyberColors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: CyberTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Type message...',
                filled: true,
                fillColor: CyberColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: CyberColors.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: CyberColors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: CyberColors.electricCyan),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: CyberColors.electricCyan,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send,
                color: CyberColors.spaceBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    ref.read(chatNotifierProvider.notifier).sendMessage(
          channelId: widget.channelId,
          content: content,
        );

    _controller.clear();
  }
}

class _EmptyChatArea extends StatelessWidget {
  const _EmptyChatArea();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: CyberColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a channel to start chatting',
            style: CyberTextStyles.bodyMedium.copyWith(
              color: CyberColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
