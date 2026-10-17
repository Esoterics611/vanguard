import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/army/army_models.dart';

/// Service for interacting with the Army backend (Firebase)
class ArmyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _initialized = false;

  // Singleton pattern
  static final ArmyService _instance = ArmyService._internal();
  factory ArmyService() => _instance;
  ArmyService._internal();

  /// Initialize the service
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ============ AUTH OPERATIONS ============

  /// Quick start - anonymous sign in + create soldier
  Future<({String soldierId, String callsign, bool isNew})> quickStart() async {
    // Sign in anonymously if not signed in
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }

    final callable = _functions.httpsCallable('quickStart');
    final result = await callable.call<Map<String, dynamic>>({});
    final data = result.data;

    return (
      soldierId: data['soldierId'] as String,
      callsign: data['callsign'] as String,
      isNew: data['isNew'] as bool,
    );
  }

  /// Connect with wallet - anonymous auth + link wallet address
  Future<({String soldierId, String callsign, bool isNew})> connectWithWallet({
    required String walletAddress,
  }) async {
    // Sign in anonymously if not signed in
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }

    final callable = _functions.httpsCallable('connectWallet');
    final result = await callable.call<Map<String, dynamic>>({
      'walletAddress': walletAddress,
    });
    final data = result.data;

    return (
      soldierId: data['soldierId'] as String,
      callsign: data['callsign'] as String,
      isNew: data['isNew'] as bool,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ============ SOLDIER OPERATIONS ============

  /// Get current soldier profile
  Future<Soldier?> getCurrentSoldier() async {
    final uid = currentUserId;
    if (uid == null) return null;
    return getSoldierById(uid);
  }

  /// Get soldier by ID
  Future<Soldier?> getSoldierById(String id) async {
    final doc = await _firestore.collection('soldiers').doc(id).get();
    if (!doc.exists) return null;
    return _soldierFromFirestore(doc);
  }

  /// Stream current soldier
  Stream<Soldier?> streamCurrentSoldier() {
    final uid = currentUserId;
    if (uid == null) return Stream.value(null);

    return _firestore
        .collection('soldiers')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? _soldierFromFirestore(doc) : null);
  }

  /// Enlist a new soldier with wallet
  Future<({String soldierId, String callsign})> enlist({
    required String walletAddress,
    required String squadId,
  }) async {
    final callable = _functions.httpsCallable('enlistSoldier');
    final result = await callable.call<Map<String, dynamic>>({
      'walletAddress': walletAddress,
      'squadId': squadId,
    });
    final data = result.data;

    return (
      soldierId: data['soldierId'] as String,
      callsign: data['callsign'] as String,
    );
  }

  // ============ UNIT OPERATIONS ============

  /// Get all units
  Future<List<Unit>> getUnits({UnitType? type, String? parentId}) async {
    Query<Map<String, dynamic>> query = _firestore.collection('units');

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }
    if (parentId != null) {
      query = query.where('parentUnitId', isEqualTo: parentId);
    }

    final snapshot = await query.get();
    return snapshot.docs.map(_unitFromFirestore).toList();
  }

  /// Get unit by ID
  Future<Unit?> getUnit(String unitId) async {
    final doc = await _firestore.collection('units').doc(unitId).get();
    if (!doc.exists) return null;
    return _unitFromFirestore(doc);
  }

  /// Stream a unit
  Stream<Unit?> streamUnit(String unitId) {
    return _firestore
        .collection('units')
        .doc(unitId)
        .snapshots()
        .map((doc) => doc.exists ? _unitFromFirestore(doc) : null);
  }

  /// Get the Army network graph for visualization
  Future<({List<GraphNode> nodes, List<GraphEdge> edges})> getArmyGraph(
    String? viewerSoldierId,
  ) async {
    final units = await getUnits();
    Soldier? soldier;
    if (viewerSoldierId != null) {
      soldier = await getSoldierById(viewerSoldierId);
    }

    final nodes = <GraphNode>[];
    final edges = <GraphEdge>[];

    for (final unit in units) {
      final isUserUnit = soldier != null &&
          (unit.id == soldier.squadId ||
              unit.memberIds.contains(soldier.id));

      nodes.add(GraphNode.unit(
        id: unit.id,
        type: unit.type,
        name: unit.name,
        memberCount: unit.memberCount,
        isUserUnit: isUserUnit,
      ));

      if (unit.parentUnitId != null) {
        edges.add(GraphEdge(
          fromId: unit.parentUnitId!,
          toId: unit.id,
          type: EdgeType.childUnit,
        ));
      }
    }

    return (nodes: nodes, edges: edges);
  }

  // ============ PROMOTION OPERATIONS ============

  /// Check if promotion is allowed
  Future<({bool allowed, String reason})> canPromote({
    required String targetId,
    required Rank newRank,
  }) async {
    final callable = _functions.httpsCallable('canPromote');
    final result = await callable.call<Map<String, dynamic>>({
      'targetId': targetId,
      'newRank': newRank.name,
    });
    final data = result.data;

    return (
      allowed: data['allowed'] as bool,
      reason: data['reason'] as String,
    );
  }

  /// Promote a soldier
  Future<void> promoteSoldier({
    required String targetId,
    required Rank newRank,
    String? reason,
  }) async {
    final callable = _functions.httpsCallable('promoteSoldier');
    await callable.call<Map<String, dynamic>>({
      'targetId': targetId,
      'newRank': newRank.name,
      'reason': reason,
    });
  }

  // ============ BOUNTY OPERATIONS ============

  /// Create a new bounty (CPT only)
  Future<String> createBounty({
    required String title,
    required String description,
    required int totalAmount,
    required int deadlineDays,
    List<String> skillTags = const [],
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    final deadline = DateTime.now().add(Duration(days: deadlineDays));
    final docRef = await _firestore.collection('bounties').add({
      'title': title,
      'description': description,
      'creatorId': uid,
      'totalAmount': totalAmount,
      'remainingAmount': totalAmount,
      'deadline': Timestamp.fromDate(deadline),
      'status': 'active',
      'skillTags': skillTags,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Get all bounties
  Future<List<Bounty>> getBounties({BountyStatus? status}) async {
    Query<Map<String, dynamic>> query = _firestore.collection('bounties');

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    final snapshot = await query.get();
    return snapshot.docs.map(_bountyFromFirestore).toList();
  }

  /// Stream bounties
  Stream<List<Bounty>> streamBounties({BountyStatus? status}) {
    Query<Map<String, dynamic>> query = _firestore.collection('bounties');

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs.map(_bountyFromFirestore).toList(),
        );
  }

  // ============ TASK OPERATIONS ============

  /// Get tasks for current soldier
  Future<List<Task>> getMyTasks() async {
    final uid = currentUserId;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('tasks')
        .where('assigneeId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map(_taskFromFirestore).toList();
  }

  /// Stream tasks for current soldier
  Stream<List<Task>> streamMyTasks() {
    final uid = currentUserId;
    if (uid == null) return Stream.value([]);

    return _firestore
        .collection('tasks')
        .where('assigneeId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_taskFromFirestore).toList());
  }

  /// Get task by ID
  Future<Task?> getTask(String taskId) async {
    final doc = await _firestore.collection('tasks').doc(taskId).get();
    if (!doc.exists) return null;
    return _taskFromFirestore(doc);
  }

  /// Submit task completion
  Future<void> submitTask({
    required String taskId,
    required String submissionHash,
  }) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'status': 'submitted',
      'submissionIpfsHash': submissionHash,
      'submittedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Create a new task
  Future<String> createTask({
    required String title,
    required String description,
    required String objectiveId,
    required int rewardVgrd,
    required TaskPriority priority,
    required int deadlineDays,
    String? assigneeId,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    final deadline = DateTime.now().add(Duration(days: deadlineDays));
    final docRef = await _firestore.collection('tasks').add({
      'title': title,
      'description': description,
      'objectiveId': objectiveId,
      'assigneeId': assigneeId,
      'status': assigneeId != null ? 'assigned' : 'created',
      'priority': priority.name,
      'rewardVgrd': rewardVgrd,
      'deadline': Timestamp.fromDate(deadline),
      'createdById': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Add task to objective's task list
    await _firestore.collection('objectives').doc(objectiveId).update({
      'taskIds': FieldValue.arrayUnion([docRef.id]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Assign a task to a soldier
  Future<void> assignTask({
    required String taskId,
    required String assigneeId,
  }) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'assigneeId': assigneeId,
      'status': 'assigned',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Start working on a task
  Future<void> startTask({required String taskId}) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'status': 'inProgress',
      'startedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get tasks for a specific objective
  Future<List<Task>> getTasksForObjective(String objectiveId) async {
    final snapshot = await _firestore
        .collection('tasks')
        .where('objectiveId', isEqualTo: objectiveId)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map(_taskFromFirestore).toList();
  }

  // ============ OBJECTIVE OPERATIONS ============

  /// Create a new objective
  Future<String> createObjective({
    required String title,
    required String description,
    required String bountyId,
    required String unitId,
    required int allocatedVgrd,
    required int deadlineDays,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    final deadline = DateTime.now().add(Duration(days: deadlineDays));
    final docRef = await _firestore.collection('objectives').add({
      'title': title,
      'description': description,
      'bountyId': bountyId,
      'unitId': unitId,
      'allocatedVgrd': allocatedVgrd,
      'taskIds': [],
      'status': 'active',
      'deadline': Timestamp.fromDate(deadline),
      'createdById': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Add objective to bounty's objective list
    await _firestore.collection('bounties').doc(bountyId).update({
      'objectiveIds': FieldValue.arrayUnion([docRef.id]),
      'remainingAmount': FieldValue.increment(-allocatedVgrd),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Get objectives for a bounty
  Future<List<Objective>> getObjectivesForBounty(String bountyId) async {
    final snapshot = await _firestore
        .collection('objectives')
        .where('bountyId', isEqualTo: bountyId)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map(_objectiveFromFirestore).toList();
  }

  /// Get a single objective
  Future<Objective?> getObjective(String objectiveId) async {
    final doc = await _firestore.collection('objectives').doc(objectiveId).get();
    if (!doc.exists) return null;
    return _objectiveFromFirestore(doc);
  }

  Objective _objectiveFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Objective(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled',
      description: data['description'] as String? ?? '',
      unitId: data['unitId'] as String? ?? '',
      bountyId: data['bountyId'] as String? ?? '',
      status: ObjectiveStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ObjectiveStatus.active,
      ),
      taskIds: List<String>.from(data['taskIds'] ?? []),
      allocatedVgrd: data['allocatedVgrd'] as int? ?? 0,
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 30)),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Get leaderboard
  Future<List<Soldier>> getLeaderboard({int limit = 20}) async {
    final snapshot = await _firestore
        .collection('soldiers')
        .orderBy('vgrdEarned', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map(_soldierFromFirestore).toList();
  }

  // ============ SQUAD OPERATIONS ============

  /// Apply to join a squad
  Future<void> applyToSquad({
    required String squadId,
    String? message,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    await _firestore.collection('squadApplications').add({
      'applicantId': uid,
      'squadId': squadId,
      'message': message,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Create a new squad with the current user as leader (initial onboarding)
  Future<String> createSquadWithLeader({
    required String name,
    String? description,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    // Create the squad
    final squadRef = await _firestore.collection('units').add({
      'type': 'squad',
      'name': name,
      'description': description,
      'leaderId': uid,
      'memberIds': [uid],
      'childUnitIds': [],
      'maxSize': 10,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Create a chat channel for the squad
    final channelRef = await _firestore.collection('chatChannels').add({
      'unitId': squadRef.id,
      'type': 'squad',
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update squad with chat channel ID
    await squadRef.update({'chatChannelId': channelRef.id});

    // Update soldier with squad assignment
    await _firestore.collection('soldiers').doc(uid).update({
      'squadId': squadRef.id,
      'rank': 'sgt', // Squad leaders start as SGT
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return squadRef.id;
  }

  /// Create a new squad (for SSG+ who are splitting)
  Future<String> createSquad({
    required String name,
    required String parentUnitId,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    final docRef = await _firestore.collection('units').add({
      'type': 'squad',
      'name': name,
      'leaderId': uid,
      'parentUnitId': parentUnitId,
      'memberIds': [uid],
      'maxSize': 10,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Get squad members
  Future<List<Soldier>> getSquadMembers(String squadId) async {
    final snapshot = await _firestore
        .collection('soldiers')
        .where('squadId', isEqualTo: squadId)
        .get();

    return snapshot.docs.map(_soldierFromFirestore).toList();
  }

  // ============ CHAT OPERATIONS ============

  /// Get chat channels for current soldier
  Future<List<ChatChannel>> getChatChannels() async {
    final soldier = await getCurrentSoldier();
    if (soldier == null) return [];

    // Get channels for soldier's squad and parent units
    final channels = <ChatChannel>[];

    // Get squad channel
    if (soldier.squadId != null) {
      final squadUnit = await getUnit(soldier.squadId!);
      if (squadUnit?.chatChannelId != null) {
        final doc = await _firestore
            .collection('chatChannels')
            .doc(squadUnit!.chatChannelId)
            .get();
        if (doc.exists) {
          channels.add(_chatChannelFromFirestore(doc));
        }
      }
    }

    return channels;
  }

  /// Stream messages for a channel
  Stream<List<ChatMessage>> streamMessages({
    required String channelId,
    int limit = 50,
  }) {
    return _firestore
        .collection('chatChannels')
        .doc(channelId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(_chatMessageFromFirestore).toList());
  }

  /// Send a message
  Future<void> sendMessage({
    required String channelId,
    required String content,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('Not authenticated');

    await _firestore
        .collection('chatChannels')
        .doc(channelId)
        .collection('messages')
        .add({
      'senderId': uid,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ============ STATS OPERATIONS ============

  /// Get army-wide statistics
  Future<Map<String, dynamic>> getArmyStats() async {
    final soldiersSnapshot = await _firestore.collection('soldiers').get();
    final unitsSnapshot = await _firestore.collection('units').get();

    final soldiers = soldiersSnapshot.docs;
    final units = unitsSnapshot.docs;

    final companies = units.where((u) => u.data()['type'] == 'company').length;
    final platoons = units.where((u) => u.data()['type'] == 'platoon').length;
    final sections = units.where((u) => u.data()['type'] == 'section').length;
    final squads = units.where((u) => u.data()['type'] == 'squad').length;

    int totalVgrd = 0;
    int totalTasks = 0;
    for (final doc in soldiers) {
      totalVgrd += (doc.data()['vgrdEarned'] as int?) ?? 0;
      totalTasks += (doc.data()['tasksCompleted'] as int?) ?? 0;
    }

    return {
      'totalSoldiers': soldiers.length,
      'totalCompanies': companies,
      'totalPlatoons': platoons,
      'totalSections': sections,
      'totalSquads': squads,
      'totalVgrdDistributed': totalVgrd,
      'totalTasksCompleted': totalTasks,
    };
  }

  // ============ FIRESTORE CONVERTERS ============

  Soldier _soldierFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Soldier(
      id: doc.id,
      walletAddress: data['walletAddress'] as String?,
      callsign: data['callsign'] as String? ?? 'UNKNOWN',
      rank: Rank.values.firstWhere(
        (r) => r.name == data['rank'],
        orElse: () => Rank.pvt,
      ),
      squadId: data['squadId'] as String?,
      tasksCompleted: data['tasksCompleted'] as int? ?? 0,
      xp: data['xp'] as int? ?? 0,
      vgrdEarned: data['vgrdEarned'] as int? ?? 0,
      votingPower: data['votingPower'] as int? ?? 1,
      enlistedAt: (data['enlistedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hasCompletedPLDC: data['hasCompletedPLDC'] as bool? ?? false,
      hasCompletedOBC: data['hasCompletedOBC'] as bool? ?? false,
    );
  }

  Unit _unitFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Unit(
      id: doc.id,
      type: UnitType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => UnitType.squad,
      ),
      name: data['name'] as String? ?? 'Unknown Unit',
      leaderId: data['leaderId'] as String?,
      parentUnitId: data['parentUnitId'] as String?,
      memberIds: List<String>.from(data['memberIds'] ?? []),
      childUnitIds: List<String>.from(data['childUnitIds'] ?? []),
      chatChannelId: data['chatChannelId'] as String?,
      maxSize: data['maxSize'] as int? ?? 10,
    );
  }

  Bounty _bountyFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Bounty(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled',
      description: data['description'] as String? ?? '',
      creatorId: data['creatorId'] as String? ?? '',
      totalAmount: data['totalAmount'] as int? ?? 0,
      remainingAmount: data['remainingAmount'] as int? ?? 0,
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 30)),
      status: BountyStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => BountyStatus.draft,
      ),
      skillTags: List<String>.from(data['skillTags'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ChatChannel _chatChannelFromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatChannel(
      id: doc.id,
      unitId: data['unitId'] as String? ?? '',
      type: ChannelType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => ChannelType.squad,
      ),
      name: data['name'] as String? ?? '',
    );
  }

  ChatMessage _chatMessageFromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ChatMessage(
      id: doc.id,
      channelId: '', // Will be set by context
      senderId: data['senderId'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Task _taskFromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Task(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled Task',
      description: data['description'] as String? ?? '',
      objectiveId: data['objectiveId'] as String? ?? '',
      assigneeId: data['assigneeId'] as String?,
      status: TaskStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => TaskStatus.created,
      ),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      rewardVgrd: data['rewardVgrd'] as int? ?? data['reward'] as int? ?? 0,
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 7)),
      submissionIpfsHash: data['submissionIpfsHash'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
