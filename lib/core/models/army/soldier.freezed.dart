// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'soldier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Soldier {

 String get id; String? get walletAddress; String get callsign; Rank get rank; String? get squadId; String? get sectionId; String? get platoonId; String? get companyId; int get tasksCompleted; int get xp; int get vgrdEarned; int get votingPower; DateTime get enlistedAt; String? get invitedByWallet; List<String> get promotionHistory; bool get hasCompletedPLDC; bool get hasCompletedOBC;
/// Create a copy of Soldier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SoldierCopyWith<Soldier> get copyWith => _$SoldierCopyWithImpl<Soldier>(this as Soldier, _$identity);

  /// Serializes this Soldier to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Soldier&&(identical(other.id, id) || other.id == id)&&(identical(other.walletAddress, walletAddress) || other.walletAddress == walletAddress)&&(identical(other.callsign, callsign) || other.callsign == callsign)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.squadId, squadId) || other.squadId == squadId)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.platoonId, platoonId) || other.platoonId == platoonId)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.tasksCompleted, tasksCompleted) || other.tasksCompleted == tasksCompleted)&&(identical(other.xp, xp) || other.xp == xp)&&(identical(other.vgrdEarned, vgrdEarned) || other.vgrdEarned == vgrdEarned)&&(identical(other.votingPower, votingPower) || other.votingPower == votingPower)&&(identical(other.enlistedAt, enlistedAt) || other.enlistedAt == enlistedAt)&&(identical(other.invitedByWallet, invitedByWallet) || other.invitedByWallet == invitedByWallet)&&const DeepCollectionEquality().equals(other.promotionHistory, promotionHistory)&&(identical(other.hasCompletedPLDC, hasCompletedPLDC) || other.hasCompletedPLDC == hasCompletedPLDC)&&(identical(other.hasCompletedOBC, hasCompletedOBC) || other.hasCompletedOBC == hasCompletedOBC));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,walletAddress,callsign,rank,squadId,sectionId,platoonId,companyId,tasksCompleted,xp,vgrdEarned,votingPower,enlistedAt,invitedByWallet,const DeepCollectionEquality().hash(promotionHistory),hasCompletedPLDC,hasCompletedOBC);

@override
String toString() {
  return 'Soldier(id: $id, walletAddress: $walletAddress, callsign: $callsign, rank: $rank, squadId: $squadId, sectionId: $sectionId, platoonId: $platoonId, companyId: $companyId, tasksCompleted: $tasksCompleted, xp: $xp, vgrdEarned: $vgrdEarned, votingPower: $votingPower, enlistedAt: $enlistedAt, invitedByWallet: $invitedByWallet, promotionHistory: $promotionHistory, hasCompletedPLDC: $hasCompletedPLDC, hasCompletedOBC: $hasCompletedOBC)';
}


}

/// @nodoc
abstract mixin class $SoldierCopyWith<$Res>  {
  factory $SoldierCopyWith(Soldier value, $Res Function(Soldier) _then) = _$SoldierCopyWithImpl;
@useResult
$Res call({
 String id, String? walletAddress, String callsign, Rank rank, String? squadId, String? sectionId, String? platoonId, String? companyId, int tasksCompleted, int xp, int vgrdEarned, int votingPower, DateTime enlistedAt, String? invitedByWallet, List<String> promotionHistory, bool hasCompletedPLDC, bool hasCompletedOBC
});




}
/// @nodoc
class _$SoldierCopyWithImpl<$Res>
    implements $SoldierCopyWith<$Res> {
  _$SoldierCopyWithImpl(this._self, this._then);

  final Soldier _self;
  final $Res Function(Soldier) _then;

/// Create a copy of Soldier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? walletAddress = freezed,Object? callsign = null,Object? rank = null,Object? squadId = freezed,Object? sectionId = freezed,Object? platoonId = freezed,Object? companyId = freezed,Object? tasksCompleted = null,Object? xp = null,Object? vgrdEarned = null,Object? votingPower = null,Object? enlistedAt = null,Object? invitedByWallet = freezed,Object? promotionHistory = null,Object? hasCompletedPLDC = null,Object? hasCompletedOBC = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,walletAddress: freezed == walletAddress ? _self.walletAddress : walletAddress // ignore: cast_nullable_to_non_nullable
as String?,callsign: null == callsign ? _self.callsign : callsign // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as Rank,squadId: freezed == squadId ? _self.squadId : squadId // ignore: cast_nullable_to_non_nullable
as String?,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String?,platoonId: freezed == platoonId ? _self.platoonId : platoonId // ignore: cast_nullable_to_non_nullable
as String?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,tasksCompleted: null == tasksCompleted ? _self.tasksCompleted : tasksCompleted // ignore: cast_nullable_to_non_nullable
as int,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,vgrdEarned: null == vgrdEarned ? _self.vgrdEarned : vgrdEarned // ignore: cast_nullable_to_non_nullable
as int,votingPower: null == votingPower ? _self.votingPower : votingPower // ignore: cast_nullable_to_non_nullable
as int,enlistedAt: null == enlistedAt ? _self.enlistedAt : enlistedAt // ignore: cast_nullable_to_non_nullable
as DateTime,invitedByWallet: freezed == invitedByWallet ? _self.invitedByWallet : invitedByWallet // ignore: cast_nullable_to_non_nullable
as String?,promotionHistory: null == promotionHistory ? _self.promotionHistory : promotionHistory // ignore: cast_nullable_to_non_nullable
as List<String>,hasCompletedPLDC: null == hasCompletedPLDC ? _self.hasCompletedPLDC : hasCompletedPLDC // ignore: cast_nullable_to_non_nullable
as bool,hasCompletedOBC: null == hasCompletedOBC ? _self.hasCompletedOBC : hasCompletedOBC // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Soldier].
extension SoldierPatterns on Soldier {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Soldier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Soldier() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Soldier value)  $default,){
final _that = this;
switch (_that) {
case _Soldier():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Soldier value)?  $default,){
final _that = this;
switch (_that) {
case _Soldier() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? walletAddress,  String callsign,  Rank rank,  String? squadId,  String? sectionId,  String? platoonId,  String? companyId,  int tasksCompleted,  int xp,  int vgrdEarned,  int votingPower,  DateTime enlistedAt,  String? invitedByWallet,  List<String> promotionHistory,  bool hasCompletedPLDC,  bool hasCompletedOBC)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Soldier() when $default != null:
return $default(_that.id,_that.walletAddress,_that.callsign,_that.rank,_that.squadId,_that.sectionId,_that.platoonId,_that.companyId,_that.tasksCompleted,_that.xp,_that.vgrdEarned,_that.votingPower,_that.enlistedAt,_that.invitedByWallet,_that.promotionHistory,_that.hasCompletedPLDC,_that.hasCompletedOBC);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? walletAddress,  String callsign,  Rank rank,  String? squadId,  String? sectionId,  String? platoonId,  String? companyId,  int tasksCompleted,  int xp,  int vgrdEarned,  int votingPower,  DateTime enlistedAt,  String? invitedByWallet,  List<String> promotionHistory,  bool hasCompletedPLDC,  bool hasCompletedOBC)  $default,) {final _that = this;
switch (_that) {
case _Soldier():
return $default(_that.id,_that.walletAddress,_that.callsign,_that.rank,_that.squadId,_that.sectionId,_that.platoonId,_that.companyId,_that.tasksCompleted,_that.xp,_that.vgrdEarned,_that.votingPower,_that.enlistedAt,_that.invitedByWallet,_that.promotionHistory,_that.hasCompletedPLDC,_that.hasCompletedOBC);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? walletAddress,  String callsign,  Rank rank,  String? squadId,  String? sectionId,  String? platoonId,  String? companyId,  int tasksCompleted,  int xp,  int vgrdEarned,  int votingPower,  DateTime enlistedAt,  String? invitedByWallet,  List<String> promotionHistory,  bool hasCompletedPLDC,  bool hasCompletedOBC)?  $default,) {final _that = this;
switch (_that) {
case _Soldier() when $default != null:
return $default(_that.id,_that.walletAddress,_that.callsign,_that.rank,_that.squadId,_that.sectionId,_that.platoonId,_that.companyId,_that.tasksCompleted,_that.xp,_that.vgrdEarned,_that.votingPower,_that.enlistedAt,_that.invitedByWallet,_that.promotionHistory,_that.hasCompletedPLDC,_that.hasCompletedOBC);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Soldier extends Soldier {
  const _Soldier({required this.id, this.walletAddress, required this.callsign, required this.rank, this.squadId, this.sectionId, this.platoonId, this.companyId, this.tasksCompleted = 0, this.xp = 0, this.vgrdEarned = 0, this.votingPower = 0, required this.enlistedAt, this.invitedByWallet, final  List<String> promotionHistory = const [], this.hasCompletedPLDC = false, this.hasCompletedOBC = false}): _promotionHistory = promotionHistory,super._();
  factory _Soldier.fromJson(Map<String, dynamic> json) => _$SoldierFromJson(json);

@override final  String id;
@override final  String? walletAddress;
@override final  String callsign;
@override final  Rank rank;
@override final  String? squadId;
@override final  String? sectionId;
@override final  String? platoonId;
@override final  String? companyId;
@override@JsonKey() final  int tasksCompleted;
@override@JsonKey() final  int xp;
@override@JsonKey() final  int vgrdEarned;
@override@JsonKey() final  int votingPower;
@override final  DateTime enlistedAt;
@override final  String? invitedByWallet;
 final  List<String> _promotionHistory;
@override@JsonKey() List<String> get promotionHistory {
  if (_promotionHistory is EqualUnmodifiableListView) return _promotionHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_promotionHistory);
}

@override@JsonKey() final  bool hasCompletedPLDC;
@override@JsonKey() final  bool hasCompletedOBC;

/// Create a copy of Soldier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SoldierCopyWith<_Soldier> get copyWith => __$SoldierCopyWithImpl<_Soldier>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SoldierToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Soldier&&(identical(other.id, id) || other.id == id)&&(identical(other.walletAddress, walletAddress) || other.walletAddress == walletAddress)&&(identical(other.callsign, callsign) || other.callsign == callsign)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.squadId, squadId) || other.squadId == squadId)&&(identical(other.sectionId, sectionId) || other.sectionId == sectionId)&&(identical(other.platoonId, platoonId) || other.platoonId == platoonId)&&(identical(other.companyId, companyId) || other.companyId == companyId)&&(identical(other.tasksCompleted, tasksCompleted) || other.tasksCompleted == tasksCompleted)&&(identical(other.xp, xp) || other.xp == xp)&&(identical(other.vgrdEarned, vgrdEarned) || other.vgrdEarned == vgrdEarned)&&(identical(other.votingPower, votingPower) || other.votingPower == votingPower)&&(identical(other.enlistedAt, enlistedAt) || other.enlistedAt == enlistedAt)&&(identical(other.invitedByWallet, invitedByWallet) || other.invitedByWallet == invitedByWallet)&&const DeepCollectionEquality().equals(other._promotionHistory, _promotionHistory)&&(identical(other.hasCompletedPLDC, hasCompletedPLDC) || other.hasCompletedPLDC == hasCompletedPLDC)&&(identical(other.hasCompletedOBC, hasCompletedOBC) || other.hasCompletedOBC == hasCompletedOBC));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,walletAddress,callsign,rank,squadId,sectionId,platoonId,companyId,tasksCompleted,xp,vgrdEarned,votingPower,enlistedAt,invitedByWallet,const DeepCollectionEquality().hash(_promotionHistory),hasCompletedPLDC,hasCompletedOBC);

@override
String toString() {
  return 'Soldier(id: $id, walletAddress: $walletAddress, callsign: $callsign, rank: $rank, squadId: $squadId, sectionId: $sectionId, platoonId: $platoonId, companyId: $companyId, tasksCompleted: $tasksCompleted, xp: $xp, vgrdEarned: $vgrdEarned, votingPower: $votingPower, enlistedAt: $enlistedAt, invitedByWallet: $invitedByWallet, promotionHistory: $promotionHistory, hasCompletedPLDC: $hasCompletedPLDC, hasCompletedOBC: $hasCompletedOBC)';
}


}

/// @nodoc
abstract mixin class _$SoldierCopyWith<$Res> implements $SoldierCopyWith<$Res> {
  factory _$SoldierCopyWith(_Soldier value, $Res Function(_Soldier) _then) = __$SoldierCopyWithImpl;
@override @useResult
$Res call({
 String id, String? walletAddress, String callsign, Rank rank, String? squadId, String? sectionId, String? platoonId, String? companyId, int tasksCompleted, int xp, int vgrdEarned, int votingPower, DateTime enlistedAt, String? invitedByWallet, List<String> promotionHistory, bool hasCompletedPLDC, bool hasCompletedOBC
});




}
/// @nodoc
class __$SoldierCopyWithImpl<$Res>
    implements _$SoldierCopyWith<$Res> {
  __$SoldierCopyWithImpl(this._self, this._then);

  final _Soldier _self;
  final $Res Function(_Soldier) _then;

/// Create a copy of Soldier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? walletAddress = freezed,Object? callsign = null,Object? rank = null,Object? squadId = freezed,Object? sectionId = freezed,Object? platoonId = freezed,Object? companyId = freezed,Object? tasksCompleted = null,Object? xp = null,Object? vgrdEarned = null,Object? votingPower = null,Object? enlistedAt = null,Object? invitedByWallet = freezed,Object? promotionHistory = null,Object? hasCompletedPLDC = null,Object? hasCompletedOBC = null,}) {
  return _then(_Soldier(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,walletAddress: freezed == walletAddress ? _self.walletAddress : walletAddress // ignore: cast_nullable_to_non_nullable
as String?,callsign: null == callsign ? _self.callsign : callsign // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as Rank,squadId: freezed == squadId ? _self.squadId : squadId // ignore: cast_nullable_to_non_nullable
as String?,sectionId: freezed == sectionId ? _self.sectionId : sectionId // ignore: cast_nullable_to_non_nullable
as String?,platoonId: freezed == platoonId ? _self.platoonId : platoonId // ignore: cast_nullable_to_non_nullable
as String?,companyId: freezed == companyId ? _self.companyId : companyId // ignore: cast_nullable_to_non_nullable
as String?,tasksCompleted: null == tasksCompleted ? _self.tasksCompleted : tasksCompleted // ignore: cast_nullable_to_non_nullable
as int,xp: null == xp ? _self.xp : xp // ignore: cast_nullable_to_non_nullable
as int,vgrdEarned: null == vgrdEarned ? _self.vgrdEarned : vgrdEarned // ignore: cast_nullable_to_non_nullable
as int,votingPower: null == votingPower ? _self.votingPower : votingPower // ignore: cast_nullable_to_non_nullable
as int,enlistedAt: null == enlistedAt ? _self.enlistedAt : enlistedAt // ignore: cast_nullable_to_non_nullable
as DateTime,invitedByWallet: freezed == invitedByWallet ? _self.invitedByWallet : invitedByWallet // ignore: cast_nullable_to_non_nullable
as String?,promotionHistory: null == promotionHistory ? _self._promotionHistory : promotionHistory // ignore: cast_nullable_to_non_nullable
as List<String>,hasCompletedPLDC: null == hasCompletedPLDC ? _self.hasCompletedPLDC : hasCompletedPLDC // ignore: cast_nullable_to_non_nullable
as bool,hasCompletedOBC: null == hasCompletedOBC ? _self.hasCompletedOBC : hasCompletedOBC // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
