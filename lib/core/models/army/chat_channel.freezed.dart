// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_channel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatChannel {

 String get id; String get unitId; ChannelType get type; String get name; DateTime? get createdAt; int get unreadCount; String? get lastMessagePreview; DateTime? get lastMessageAt;
/// Create a copy of ChatChannel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatChannelCopyWith<ChatChannel> get copyWith => _$ChatChannelCopyWithImpl<ChatChannel>(this as ChatChannel, _$identity);

  /// Serializes this ChatChannel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatChannel&&(identical(other.id, id) || other.id == id)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.lastMessagePreview, lastMessagePreview) || other.lastMessagePreview == lastMessagePreview)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,unitId,type,name,createdAt,unreadCount,lastMessagePreview,lastMessageAt);

@override
String toString() {
  return 'ChatChannel(id: $id, unitId: $unitId, type: $type, name: $name, createdAt: $createdAt, unreadCount: $unreadCount, lastMessagePreview: $lastMessagePreview, lastMessageAt: $lastMessageAt)';
}


}

/// @nodoc
abstract mixin class $ChatChannelCopyWith<$Res>  {
  factory $ChatChannelCopyWith(ChatChannel value, $Res Function(ChatChannel) _then) = _$ChatChannelCopyWithImpl;
@useResult
$Res call({
 String id, String unitId, ChannelType type, String name, DateTime? createdAt, int unreadCount, String? lastMessagePreview, DateTime? lastMessageAt
});




}
/// @nodoc
class _$ChatChannelCopyWithImpl<$Res>
    implements $ChatChannelCopyWith<$Res> {
  _$ChatChannelCopyWithImpl(this._self, this._then);

  final ChatChannel _self;
  final $Res Function(ChatChannel) _then;

/// Create a copy of ChatChannel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? unitId = null,Object? type = null,Object? name = null,Object? createdAt = freezed,Object? unreadCount = null,Object? lastMessagePreview = freezed,Object? lastMessageAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChannelType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,lastMessagePreview: freezed == lastMessagePreview ? _self.lastMessagePreview : lastMessagePreview // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatChannel].
extension ChatChannelPatterns on ChatChannel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatChannel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatChannel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatChannel value)  $default,){
final _that = this;
switch (_that) {
case _ChatChannel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatChannel value)?  $default,){
final _that = this;
switch (_that) {
case _ChatChannel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String unitId,  ChannelType type,  String name,  DateTime? createdAt,  int unreadCount,  String? lastMessagePreview,  DateTime? lastMessageAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatChannel() when $default != null:
return $default(_that.id,_that.unitId,_that.type,_that.name,_that.createdAt,_that.unreadCount,_that.lastMessagePreview,_that.lastMessageAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String unitId,  ChannelType type,  String name,  DateTime? createdAt,  int unreadCount,  String? lastMessagePreview,  DateTime? lastMessageAt)  $default,) {final _that = this;
switch (_that) {
case _ChatChannel():
return $default(_that.id,_that.unitId,_that.type,_that.name,_that.createdAt,_that.unreadCount,_that.lastMessagePreview,_that.lastMessageAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String unitId,  ChannelType type,  String name,  DateTime? createdAt,  int unreadCount,  String? lastMessagePreview,  DateTime? lastMessageAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatChannel() when $default != null:
return $default(_that.id,_that.unitId,_that.type,_that.name,_that.createdAt,_that.unreadCount,_that.lastMessagePreview,_that.lastMessageAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatChannel extends ChatChannel {
  const _ChatChannel({required this.id, required this.unitId, required this.type, required this.name, this.createdAt = null, this.unreadCount = 0, this.lastMessagePreview, this.lastMessageAt}): super._();
  factory _ChatChannel.fromJson(Map<String, dynamic> json) => _$ChatChannelFromJson(json);

@override final  String id;
@override final  String unitId;
@override final  ChannelType type;
@override final  String name;
@override@JsonKey() final  DateTime? createdAt;
@override@JsonKey() final  int unreadCount;
@override final  String? lastMessagePreview;
@override final  DateTime? lastMessageAt;

/// Create a copy of ChatChannel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatChannelCopyWith<_ChatChannel> get copyWith => __$ChatChannelCopyWithImpl<_ChatChannel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatChannelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatChannel&&(identical(other.id, id) || other.id == id)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.lastMessagePreview, lastMessagePreview) || other.lastMessagePreview == lastMessagePreview)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,unitId,type,name,createdAt,unreadCount,lastMessagePreview,lastMessageAt);

@override
String toString() {
  return 'ChatChannel(id: $id, unitId: $unitId, type: $type, name: $name, createdAt: $createdAt, unreadCount: $unreadCount, lastMessagePreview: $lastMessagePreview, lastMessageAt: $lastMessageAt)';
}


}

/// @nodoc
abstract mixin class _$ChatChannelCopyWith<$Res> implements $ChatChannelCopyWith<$Res> {
  factory _$ChatChannelCopyWith(_ChatChannel value, $Res Function(_ChatChannel) _then) = __$ChatChannelCopyWithImpl;
@override @useResult
$Res call({
 String id, String unitId, ChannelType type, String name, DateTime? createdAt, int unreadCount, String? lastMessagePreview, DateTime? lastMessageAt
});




}
/// @nodoc
class __$ChatChannelCopyWithImpl<$Res>
    implements _$ChatChannelCopyWith<$Res> {
  __$ChatChannelCopyWithImpl(this._self, this._then);

  final _ChatChannel _self;
  final $Res Function(_ChatChannel) _then;

/// Create a copy of ChatChannel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? unitId = null,Object? type = null,Object? name = null,Object? createdAt = freezed,Object? unreadCount = null,Object? lastMessagePreview = freezed,Object? lastMessageAt = freezed,}) {
  return _then(_ChatChannel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ChannelType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,lastMessagePreview: freezed == lastMessagePreview ? _self.lastMessagePreview : lastMessagePreview // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
