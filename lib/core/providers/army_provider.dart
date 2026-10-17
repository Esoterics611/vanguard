import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/army/army_models.dart';
import '../services/army_service.dart';

/// Provider for ArmyService instance (pre-initialized)
final armyServiceProvider = Provider<ArmyService>((ref) {
  final service = ArmyService();
  return service;
});

/// Provider for current soldier ID (from Firebase Auth)
final currentSoldierIdProvider = Provider<String?>((ref) {
  final service = ref.read(armyServiceProvider);
  return service.currentUserId;
});

/// Provider for current soldier profile (stream)
final currentSoldierStreamProvider = StreamProvider<Soldier?>((ref) {
  final service = ref.read(armyServiceProvider);
  return service.streamCurrentSoldier();
});

/// Provider for current soldier profile (future)
final currentSoldierProvider = FutureProvider<Soldier?>((ref) async {
  final service = ref.read(armyServiceProvider);
  return service.getCurrentSoldier();
});

/// Provider for the user's current squad
final myUnitProvider = FutureProvider<Unit?>((ref) async {
  final soldier = await ref.watch(currentSoldierProvider.future);
  if (soldier == null || soldier.squadId == null) return null;

  final service = ref.read(armyServiceProvider);
  return service.getUnit(soldier.squadId!);
});

/// Provider for all units
final unitsProvider = FutureProvider.family<List<Unit>, UnitType?>((ref, type) async {
  final service = ref.read(armyServiceProvider);
  return service.getUnits(type: type);
});

/// Provider for Army network graph
final armyGraphProvider = FutureProvider<({List<GraphNode> nodes, List<GraphEdge> edges})>((ref) async {
  final soldierId = ref.watch(currentSoldierIdProvider);

  final service = ref.read(armyServiceProvider);
  return service.getArmyGraph(soldierId);
});

/// Provider for all bounties
final bountiesProvider = FutureProvider<List<Bounty>>((ref) async {
  final service = ref.read(armyServiceProvider);
  return service.getBounties();
});

/// Provider for bounties stream
final bountiesStreamProvider = StreamProvider<List<Bounty>>((ref) {
  final service = ref.read(armyServiceProvider);
  return service.streamBounties();
});

/// Provider for active bounties only
final activeBountiesProvider = FutureProvider<List<Bounty>>((ref) async {
  final bounties = await ref.watch(bountiesProvider.future);
  return bounties.where((b) => b.isActive).toList();
});

/// Provider for chat channels
final chatChannelsProvider = FutureProvider<List<ChatChannel>>((ref) async {
  final service = ref.read(armyServiceProvider);
  return service.getChatChannels();
});

/// Provider for messages stream in a specific channel
final channelMessagesStreamProvider = StreamProvider.family<List<ChatMessage>, String>((ref, channelId) {
  final service = ref.read(armyServiceProvider);
  return service.streamMessages(channelId: channelId);
});

/// Provider for selected chat channel
final selectedChannelProvider = StateProvider<String?>((ref) => null);

/// Provider for army statistics
final armyStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(armyServiceProvider);
  return service.getArmyStats();
});

/// Provider for current soldier's tasks
final myTasksProvider = FutureProvider<List<Task>>((ref) async {
  final service = ref.read(armyServiceProvider);
  return service.getMyTasks();
});

/// Provider for current soldier's tasks (stream)
final myTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final service = ref.read(armyServiceProvider);
  return service.streamMyTasks();
});

/// Provider for leaderboard
final leaderboardProvider = FutureProvider<List<Soldier>>((ref) async {
  final service = ref.read(armyServiceProvider);
  return service.getLeaderboard();
});

/// Notifier for authentication/enlistment
class AuthNotifier extends StateNotifier<AsyncValue<Soldier?>> {
  final ArmyService _service;
  final Ref _ref;

  AuthNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<void> quickStart() async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.quickStart();
      final soldier = await _service.getSoldierById(result.soldierId);
      state = AsyncValue.data(soldier);
      // Refresh providers
      _ref.invalidate(currentSoldierProvider);
      _ref.invalidate(currentSoldierStreamProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Connect with wallet - anonymous auth + link wallet address
  Future<void> connectWithWallet({required String walletAddress}) async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.connectWithWallet(walletAddress: walletAddress);
      final soldier = await _service.getSoldierById(result.soldierId);
      state = AsyncValue.data(soldier);
      // Refresh providers
      _ref.invalidate(currentSoldierProvider);
      _ref.invalidate(currentSoldierStreamProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> enlist({
    required String walletAddress,
    required String squadId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.enlist(
        walletAddress: walletAddress,
        squadId: squadId,
      );
      final soldier = await _service.getSoldierById(result.soldierId);
      state = AsyncValue.data(soldier);
      // Refresh providers
      _ref.invalidate(currentSoldierProvider);
      _ref.invalidate(currentSoldierStreamProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Sign out and clear state
  Future<void> signOut() async {
    await _service.signOut();
    state = const AsyncValue.data(null);
    _ref.invalidate(currentSoldierProvider);
    _ref.invalidate(currentSoldierStreamProvider);
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<Soldier?>>((ref) {
  final service = ref.read(armyServiceProvider);
  return AuthNotifier(service, ref);
});

/// Notifier for sending messages
class ChatNotifier extends StateNotifier<AsyncValue<void>> {
  final ArmyService _service;

  ChatNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> sendMessage({
    required String channelId,
    required String content,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.sendMessage(
        channelId: channelId,
        content: content,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, AsyncValue<void>>((ref) {
  final service = ref.read(armyServiceProvider);
  return ChatNotifier(service);
});

/// Notifier for promotions
class PromotionNotifier extends StateNotifier<AsyncValue<void>> {
  final ArmyService _service;

  PromotionNotifier(this._service) : super(const AsyncValue.data(null));

  Future<({bool allowed, String reason})> canPromote({
    required String targetId,
    required Rank newRank,
  }) async {
    return _service.canPromote(targetId: targetId, newRank: newRank);
  }

  Future<void> promote({
    required String targetId,
    required Rank newRank,
    String? reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.promoteSoldier(
        targetId: targetId,
        newRank: newRank,
        reason: reason,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final promotionNotifierProvider = StateNotifierProvider<PromotionNotifier, AsyncValue<void>>((ref) {
  final service = ref.read(armyServiceProvider);
  return PromotionNotifier(service);
});
