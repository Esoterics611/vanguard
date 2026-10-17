// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soldier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Soldier _$SoldierFromJson(Map<String, dynamic> json) => _Soldier(
  id: json['id'] as String,
  walletAddress: json['walletAddress'] as String?,
  callsign: json['callsign'] as String,
  rank: $enumDecode(_$RankEnumMap, json['rank']),
  squadId: json['squadId'] as String?,
  sectionId: json['sectionId'] as String?,
  platoonId: json['platoonId'] as String?,
  companyId: json['companyId'] as String?,
  tasksCompleted: (json['tasksCompleted'] as num?)?.toInt() ?? 0,
  xp: (json['xp'] as num?)?.toInt() ?? 0,
  vgrdEarned: (json['vgrdEarned'] as num?)?.toInt() ?? 0,
  votingPower: (json['votingPower'] as num?)?.toInt() ?? 0,
  enlistedAt: DateTime.parse(json['enlistedAt'] as String),
  invitedByWallet: json['invitedByWallet'] as String?,
  promotionHistory:
      (json['promotionHistory'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  hasCompletedPLDC: json['hasCompletedPLDC'] as bool? ?? false,
  hasCompletedOBC: json['hasCompletedOBC'] as bool? ?? false,
);

Map<String, dynamic> _$SoldierToJson(_Soldier instance) => <String, dynamic>{
  'id': instance.id,
  'walletAddress': instance.walletAddress,
  'callsign': instance.callsign,
  'rank': _$RankEnumMap[instance.rank]!,
  'squadId': instance.squadId,
  'sectionId': instance.sectionId,
  'platoonId': instance.platoonId,
  'companyId': instance.companyId,
  'tasksCompleted': instance.tasksCompleted,
  'xp': instance.xp,
  'vgrdEarned': instance.vgrdEarned,
  'votingPower': instance.votingPower,
  'enlistedAt': instance.enlistedAt.toIso8601String(),
  'invitedByWallet': instance.invitedByWallet,
  'promotionHistory': instance.promotionHistory,
  'hasCompletedPLDC': instance.hasCompletedPLDC,
  'hasCompletedOBC': instance.hasCompletedOBC,
};

const _$RankEnumMap = {
  Rank.guest: 'guest',
  Rank.pvt: 'pvt',
  Rank.pv2: 'pv2',
  Rank.pfc: 'pfc',
  Rank.cpl: 'cpl',
  Rank.sgt: 'sgt',
  Rank.ssg: 'ssg',
  Rank.sfc: 'sfc',
  Rank.firstSgt: 'firstSgt',
  Rank.secondLt: 'secondLt',
  Rank.firstLt: 'firstLt',
  Rank.cpt: 'cpt',
};
