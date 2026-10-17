// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'graph_node.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
GraphNode _$GraphNodeFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'soldier':
          return SoldierNode.fromJson(
            json
          );
                case 'unit':
          return UnitNode.fromJson(
            json
          );
                case 'bounty':
          return BountyNode.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'GraphNode',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$GraphNode {

 String get id;
/// Create a copy of GraphNode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GraphNodeCopyWith<GraphNode> get copyWith => _$GraphNodeCopyWithImpl<GraphNode>(this as GraphNode, _$identity);

  /// Serializes this GraphNode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GraphNode&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'GraphNode(id: $id)';
}


}

/// @nodoc
abstract mixin class $GraphNodeCopyWith<$Res>  {
  factory $GraphNodeCopyWith(GraphNode value, $Res Function(GraphNode) _then) = _$GraphNodeCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$GraphNodeCopyWithImpl<$Res>
    implements $GraphNodeCopyWith<$Res> {
  _$GraphNodeCopyWithImpl(this._self, this._then);

  final GraphNode _self;
  final $Res Function(GraphNode) _then;

/// Create a copy of GraphNode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GraphNode].
extension GraphNodePatterns on GraphNode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SoldierNode value)?  soldier,TResult Function( UnitNode value)?  unit,TResult Function( BountyNode value)?  bounty,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SoldierNode() when soldier != null:
return soldier(_that);case UnitNode() when unit != null:
return unit(_that);case BountyNode() when bounty != null:
return bounty(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SoldierNode value)  soldier,required TResult Function( UnitNode value)  unit,required TResult Function( BountyNode value)  bounty,}){
final _that = this;
switch (_that) {
case SoldierNode():
return soldier(_that);case UnitNode():
return unit(_that);case BountyNode():
return bounty(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SoldierNode value)?  soldier,TResult? Function( UnitNode value)?  unit,TResult? Function( BountyNode value)?  bounty,}){
final _that = this;
switch (_that) {
case SoldierNode() when soldier != null:
return soldier(_that);case UnitNode() when unit != null:
return unit(_that);case BountyNode() when bounty != null:
return bounty(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  Rank rank,  String callsign,  bool isCurrentUser)?  soldier,TResult Function( String id,  UnitType type,  String name,  int memberCount,  bool isUserUnit)?  unit,TResult Function( String id,  String title,  int reward)?  bounty,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SoldierNode() when soldier != null:
return soldier(_that.id,_that.rank,_that.callsign,_that.isCurrentUser);case UnitNode() when unit != null:
return unit(_that.id,_that.type,_that.name,_that.memberCount,_that.isUserUnit);case BountyNode() when bounty != null:
return bounty(_that.id,_that.title,_that.reward);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  Rank rank,  String callsign,  bool isCurrentUser)  soldier,required TResult Function( String id,  UnitType type,  String name,  int memberCount,  bool isUserUnit)  unit,required TResult Function( String id,  String title,  int reward)  bounty,}) {final _that = this;
switch (_that) {
case SoldierNode():
return soldier(_that.id,_that.rank,_that.callsign,_that.isCurrentUser);case UnitNode():
return unit(_that.id,_that.type,_that.name,_that.memberCount,_that.isUserUnit);case BountyNode():
return bounty(_that.id,_that.title,_that.reward);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  Rank rank,  String callsign,  bool isCurrentUser)?  soldier,TResult? Function( String id,  UnitType type,  String name,  int memberCount,  bool isUserUnit)?  unit,TResult? Function( String id,  String title,  int reward)?  bounty,}) {final _that = this;
switch (_that) {
case SoldierNode() when soldier != null:
return soldier(_that.id,_that.rank,_that.callsign,_that.isCurrentUser);case UnitNode() when unit != null:
return unit(_that.id,_that.type,_that.name,_that.memberCount,_that.isUserUnit);case BountyNode() when bounty != null:
return bounty(_that.id,_that.title,_that.reward);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class SoldierNode extends GraphNode {
  const SoldierNode({required this.id, required this.rank, required this.callsign, this.isCurrentUser = false, final  String? $type}): $type = $type ?? 'soldier',super._();
  factory SoldierNode.fromJson(Map<String, dynamic> json) => _$SoldierNodeFromJson(json);

@override final  String id;
 final  Rank rank;
 final  String callsign;
@JsonKey() final  bool isCurrentUser;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of GraphNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SoldierNodeCopyWith<SoldierNode> get copyWith => _$SoldierNodeCopyWithImpl<SoldierNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SoldierNodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SoldierNode&&(identical(other.id, id) || other.id == id)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.callsign, callsign) || other.callsign == callsign)&&(identical(other.isCurrentUser, isCurrentUser) || other.isCurrentUser == isCurrentUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,rank,callsign,isCurrentUser);

@override
String toString() {
  return 'GraphNode.soldier(id: $id, rank: $rank, callsign: $callsign, isCurrentUser: $isCurrentUser)';
}


}

/// @nodoc
abstract mixin class $SoldierNodeCopyWith<$Res> implements $GraphNodeCopyWith<$Res> {
  factory $SoldierNodeCopyWith(SoldierNode value, $Res Function(SoldierNode) _then) = _$SoldierNodeCopyWithImpl;
@override @useResult
$Res call({
 String id, Rank rank, String callsign, bool isCurrentUser
});




}
/// @nodoc
class _$SoldierNodeCopyWithImpl<$Res>
    implements $SoldierNodeCopyWith<$Res> {
  _$SoldierNodeCopyWithImpl(this._self, this._then);

  final SoldierNode _self;
  final $Res Function(SoldierNode) _then;

/// Create a copy of GraphNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? rank = null,Object? callsign = null,Object? isCurrentUser = null,}) {
  return _then(SoldierNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as Rank,callsign: null == callsign ? _self.callsign : callsign // ignore: cast_nullable_to_non_nullable
as String,isCurrentUser: null == isCurrentUser ? _self.isCurrentUser : isCurrentUser // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class UnitNode extends GraphNode {
  const UnitNode({required this.id, required this.type, required this.name, required this.memberCount, this.isUserUnit = false, final  String? $type}): $type = $type ?? 'unit',super._();
  factory UnitNode.fromJson(Map<String, dynamic> json) => _$UnitNodeFromJson(json);

@override final  String id;
 final  UnitType type;
 final  String name;
 final  int memberCount;
@JsonKey() final  bool isUserUnit;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of GraphNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnitNodeCopyWith<UnitNode> get copyWith => _$UnitNodeCopyWithImpl<UnitNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnitNodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnitNode&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.isUserUnit, isUserUnit) || other.isUserUnit == isUserUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,memberCount,isUserUnit);

@override
String toString() {
  return 'GraphNode.unit(id: $id, type: $type, name: $name, memberCount: $memberCount, isUserUnit: $isUserUnit)';
}


}

/// @nodoc
abstract mixin class $UnitNodeCopyWith<$Res> implements $GraphNodeCopyWith<$Res> {
  factory $UnitNodeCopyWith(UnitNode value, $Res Function(UnitNode) _then) = _$UnitNodeCopyWithImpl;
@override @useResult
$Res call({
 String id, UnitType type, String name, int memberCount, bool isUserUnit
});




}
/// @nodoc
class _$UnitNodeCopyWithImpl<$Res>
    implements $UnitNodeCopyWith<$Res> {
  _$UnitNodeCopyWithImpl(this._self, this._then);

  final UnitNode _self;
  final $Res Function(UnitNode) _then;

/// Create a copy of GraphNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? memberCount = null,Object? isUserUnit = null,}) {
  return _then(UnitNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as UnitType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,isUserUnit: null == isUserUnit ? _self.isUserUnit : isUserUnit // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class BountyNode extends GraphNode {
  const BountyNode({required this.id, required this.title, required this.reward, final  String? $type}): $type = $type ?? 'bounty',super._();
  factory BountyNode.fromJson(Map<String, dynamic> json) => _$BountyNodeFromJson(json);

@override final  String id;
 final  String title;
 final  int reward;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of GraphNode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BountyNodeCopyWith<BountyNode> get copyWith => _$BountyNodeCopyWithImpl<BountyNode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BountyNodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BountyNode&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.reward, reward) || other.reward == reward));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,reward);

@override
String toString() {
  return 'GraphNode.bounty(id: $id, title: $title, reward: $reward)';
}


}

/// @nodoc
abstract mixin class $BountyNodeCopyWith<$Res> implements $GraphNodeCopyWith<$Res> {
  factory $BountyNodeCopyWith(BountyNode value, $Res Function(BountyNode) _then) = _$BountyNodeCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, int reward
});




}
/// @nodoc
class _$BountyNodeCopyWithImpl<$Res>
    implements $BountyNodeCopyWith<$Res> {
  _$BountyNodeCopyWithImpl(this._self, this._then);

  final BountyNode _self;
  final $Res Function(BountyNode) _then;

/// Create a copy of GraphNode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? reward = null,}) {
  return _then(BountyNode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,reward: null == reward ? _self.reward : reward // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
