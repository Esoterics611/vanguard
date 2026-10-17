// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Unit {

 String get id; UnitType get type; String get name; String? get leaderId; String? get secondInCommandId; List<String> get memberIds; String? get parentUnitId; List<String> get childUnitIds; String? get chatChannelId; List<String> get objectiveIds; int get maxSize; DateTime? get createdAt;
/// Create a copy of Unit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnitCopyWith<Unit> get copyWith => _$UnitCopyWithImpl<Unit>(this as Unit, _$identity);

  /// Serializes this Unit to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Unit&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.leaderId, leaderId) || other.leaderId == leaderId)&&(identical(other.secondInCommandId, secondInCommandId) || other.secondInCommandId == secondInCommandId)&&const DeepCollectionEquality().equals(other.memberIds, memberIds)&&(identical(other.parentUnitId, parentUnitId) || other.parentUnitId == parentUnitId)&&const DeepCollectionEquality().equals(other.childUnitIds, childUnitIds)&&(identical(other.chatChannelId, chatChannelId) || other.chatChannelId == chatChannelId)&&const DeepCollectionEquality().equals(other.objectiveIds, objectiveIds)&&(identical(other.maxSize, maxSize) || other.maxSize == maxSize)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,leaderId,secondInCommandId,const DeepCollectionEquality().hash(memberIds),parentUnitId,const DeepCollectionEquality().hash(childUnitIds),chatChannelId,const DeepCollectionEquality().hash(objectiveIds),maxSize,createdAt);

@override
String toString() {
  return 'Unit(id: $id, type: $type, name: $name, leaderId: $leaderId, secondInCommandId: $secondInCommandId, memberIds: $memberIds, parentUnitId: $parentUnitId, childUnitIds: $childUnitIds, chatChannelId: $chatChannelId, objectiveIds: $objectiveIds, maxSize: $maxSize, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UnitCopyWith<$Res>  {
  factory $UnitCopyWith(Unit value, $Res Function(Unit) _then) = _$UnitCopyWithImpl;
@useResult
$Res call({
 String id, UnitType type, String name, String? leaderId, String? secondInCommandId, List<String> memberIds, String? parentUnitId, List<String> childUnitIds, String? chatChannelId, List<String> objectiveIds, int maxSize, DateTime? createdAt
});




}
/// @nodoc
class _$UnitCopyWithImpl<$Res>
    implements $UnitCopyWith<$Res> {
  _$UnitCopyWithImpl(this._self, this._then);

  final Unit _self;
  final $Res Function(Unit) _then;

/// Create a copy of Unit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? name = null,Object? leaderId = freezed,Object? secondInCommandId = freezed,Object? memberIds = null,Object? parentUnitId = freezed,Object? childUnitIds = null,Object? chatChannelId = freezed,Object? objectiveIds = null,Object? maxSize = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as UnitType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,leaderId: freezed == leaderId ? _self.leaderId : leaderId // ignore: cast_nullable_to_non_nullable
as String?,secondInCommandId: freezed == secondInCommandId ? _self.secondInCommandId : secondInCommandId // ignore: cast_nullable_to_non_nullable
as String?,memberIds: null == memberIds ? _self.memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,parentUnitId: freezed == parentUnitId ? _self.parentUnitId : parentUnitId // ignore: cast_nullable_to_non_nullable
as String?,childUnitIds: null == childUnitIds ? _self.childUnitIds : childUnitIds // ignore: cast_nullable_to_non_nullable
as List<String>,chatChannelId: freezed == chatChannelId ? _self.chatChannelId : chatChannelId // ignore: cast_nullable_to_non_nullable
as String?,objectiveIds: null == objectiveIds ? _self.objectiveIds : objectiveIds // ignore: cast_nullable_to_non_nullable
as List<String>,maxSize: null == maxSize ? _self.maxSize : maxSize // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Unit].
extension UnitPatterns on Unit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Unit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Unit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Unit value)  $default,){
final _that = this;
switch (_that) {
case _Unit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Unit value)?  $default,){
final _that = this;
switch (_that) {
case _Unit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  UnitType type,  String name,  String? leaderId,  String? secondInCommandId,  List<String> memberIds,  String? parentUnitId,  List<String> childUnitIds,  String? chatChannelId,  List<String> objectiveIds,  int maxSize,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Unit() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.leaderId,_that.secondInCommandId,_that.memberIds,_that.parentUnitId,_that.childUnitIds,_that.chatChannelId,_that.objectiveIds,_that.maxSize,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  UnitType type,  String name,  String? leaderId,  String? secondInCommandId,  List<String> memberIds,  String? parentUnitId,  List<String> childUnitIds,  String? chatChannelId,  List<String> objectiveIds,  int maxSize,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Unit():
return $default(_that.id,_that.type,_that.name,_that.leaderId,_that.secondInCommandId,_that.memberIds,_that.parentUnitId,_that.childUnitIds,_that.chatChannelId,_that.objectiveIds,_that.maxSize,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  UnitType type,  String name,  String? leaderId,  String? secondInCommandId,  List<String> memberIds,  String? parentUnitId,  List<String> childUnitIds,  String? chatChannelId,  List<String> objectiveIds,  int maxSize,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Unit() when $default != null:
return $default(_that.id,_that.type,_that.name,_that.leaderId,_that.secondInCommandId,_that.memberIds,_that.parentUnitId,_that.childUnitIds,_that.chatChannelId,_that.objectiveIds,_that.maxSize,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Unit extends Unit {
  const _Unit({required this.id, required this.type, required this.name, this.leaderId, this.secondInCommandId, final  List<String> memberIds = const [], this.parentUnitId, final  List<String> childUnitIds = const [], this.chatChannelId, final  List<String> objectiveIds = const [], this.maxSize = 10, this.createdAt = null}): _memberIds = memberIds,_childUnitIds = childUnitIds,_objectiveIds = objectiveIds,super._();
  factory _Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);

@override final  String id;
@override final  UnitType type;
@override final  String name;
@override final  String? leaderId;
@override final  String? secondInCommandId;
 final  List<String> _memberIds;
@override@JsonKey() List<String> get memberIds {
  if (_memberIds is EqualUnmodifiableListView) return _memberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberIds);
}

@override final  String? parentUnitId;
 final  List<String> _childUnitIds;
@override@JsonKey() List<String> get childUnitIds {
  if (_childUnitIds is EqualUnmodifiableListView) return _childUnitIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_childUnitIds);
}

@override final  String? chatChannelId;
 final  List<String> _objectiveIds;
@override@JsonKey() List<String> get objectiveIds {
  if (_objectiveIds is EqualUnmodifiableListView) return _objectiveIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_objectiveIds);
}

@override@JsonKey() final  int maxSize;
@override@JsonKey() final  DateTime? createdAt;

/// Create a copy of Unit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnitCopyWith<_Unit> get copyWith => __$UnitCopyWithImpl<_Unit>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unit&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.leaderId, leaderId) || other.leaderId == leaderId)&&(identical(other.secondInCommandId, secondInCommandId) || other.secondInCommandId == secondInCommandId)&&const DeepCollectionEquality().equals(other._memberIds, _memberIds)&&(identical(other.parentUnitId, parentUnitId) || other.parentUnitId == parentUnitId)&&const DeepCollectionEquality().equals(other._childUnitIds, _childUnitIds)&&(identical(other.chatChannelId, chatChannelId) || other.chatChannelId == chatChannelId)&&const DeepCollectionEquality().equals(other._objectiveIds, _objectiveIds)&&(identical(other.maxSize, maxSize) || other.maxSize == maxSize)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,name,leaderId,secondInCommandId,const DeepCollectionEquality().hash(_memberIds),parentUnitId,const DeepCollectionEquality().hash(_childUnitIds),chatChannelId,const DeepCollectionEquality().hash(_objectiveIds),maxSize,createdAt);

@override
String toString() {
  return 'Unit(id: $id, type: $type, name: $name, leaderId: $leaderId, secondInCommandId: $secondInCommandId, memberIds: $memberIds, parentUnitId: $parentUnitId, childUnitIds: $childUnitIds, chatChannelId: $chatChannelId, objectiveIds: $objectiveIds, maxSize: $maxSize, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UnitCopyWith<$Res> implements $UnitCopyWith<$Res> {
  factory _$UnitCopyWith(_Unit value, $Res Function(_Unit) _then) = __$UnitCopyWithImpl;
@override @useResult
$Res call({
 String id, UnitType type, String name, String? leaderId, String? secondInCommandId, List<String> memberIds, String? parentUnitId, List<String> childUnitIds, String? chatChannelId, List<String> objectiveIds, int maxSize, DateTime? createdAt
});




}
/// @nodoc
class __$UnitCopyWithImpl<$Res>
    implements _$UnitCopyWith<$Res> {
  __$UnitCopyWithImpl(this._self, this._then);

  final _Unit _self;
  final $Res Function(_Unit) _then;

/// Create a copy of Unit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? name = null,Object? leaderId = freezed,Object? secondInCommandId = freezed,Object? memberIds = null,Object? parentUnitId = freezed,Object? childUnitIds = null,Object? chatChannelId = freezed,Object? objectiveIds = null,Object? maxSize = null,Object? createdAt = freezed,}) {
  return _then(_Unit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as UnitType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,leaderId: freezed == leaderId ? _self.leaderId : leaderId // ignore: cast_nullable_to_non_nullable
as String?,secondInCommandId: freezed == secondInCommandId ? _self.secondInCommandId : secondInCommandId // ignore: cast_nullable_to_non_nullable
as String?,memberIds: null == memberIds ? _self._memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,parentUnitId: freezed == parentUnitId ? _self.parentUnitId : parentUnitId // ignore: cast_nullable_to_non_nullable
as String?,childUnitIds: null == childUnitIds ? _self._childUnitIds : childUnitIds // ignore: cast_nullable_to_non_nullable
as List<String>,chatChannelId: freezed == chatChannelId ? _self.chatChannelId : chatChannelId // ignore: cast_nullable_to_non_nullable
as String?,objectiveIds: null == objectiveIds ? _self._objectiveIds : objectiveIds // ignore: cast_nullable_to_non_nullable
as List<String>,maxSize: null == maxSize ? _self.maxSize : maxSize // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
