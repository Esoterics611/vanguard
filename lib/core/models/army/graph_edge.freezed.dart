// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'graph_edge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GraphEdge {

 String get fromId; String get toId; EdgeType get type; Map<String, dynamic>? get metadata;
/// Create a copy of GraphEdge
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GraphEdgeCopyWith<GraphEdge> get copyWith => _$GraphEdgeCopyWithImpl<GraphEdge>(this as GraphEdge, _$identity);

  /// Serializes this GraphEdge to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GraphEdge&&(identical(other.fromId, fromId) || other.fromId == fromId)&&(identical(other.toId, toId) || other.toId == toId)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromId,toId,type,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'GraphEdge(fromId: $fromId, toId: $toId, type: $type, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $GraphEdgeCopyWith<$Res>  {
  factory $GraphEdgeCopyWith(GraphEdge value, $Res Function(GraphEdge) _then) = _$GraphEdgeCopyWithImpl;
@useResult
$Res call({
 String fromId, String toId, EdgeType type, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$GraphEdgeCopyWithImpl<$Res>
    implements $GraphEdgeCopyWith<$Res> {
  _$GraphEdgeCopyWithImpl(this._self, this._then);

  final GraphEdge _self;
  final $Res Function(GraphEdge) _then;

/// Create a copy of GraphEdge
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fromId = null,Object? toId = null,Object? type = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
fromId: null == fromId ? _self.fromId : fromId // ignore: cast_nullable_to_non_nullable
as String,toId: null == toId ? _self.toId : toId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EdgeType,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [GraphEdge].
extension GraphEdgePatterns on GraphEdge {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GraphEdge value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GraphEdge() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GraphEdge value)  $default,){
final _that = this;
switch (_that) {
case _GraphEdge():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GraphEdge value)?  $default,){
final _that = this;
switch (_that) {
case _GraphEdge() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fromId,  String toId,  EdgeType type,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GraphEdge() when $default != null:
return $default(_that.fromId,_that.toId,_that.type,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fromId,  String toId,  EdgeType type,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _GraphEdge():
return $default(_that.fromId,_that.toId,_that.type,_that.metadata);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fromId,  String toId,  EdgeType type,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _GraphEdge() when $default != null:
return $default(_that.fromId,_that.toId,_that.type,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GraphEdge extends GraphEdge {
  const _GraphEdge({required this.fromId, required this.toId, required this.type, final  Map<String, dynamic>? metadata}): _metadata = metadata,super._();
  factory _GraphEdge.fromJson(Map<String, dynamic> json) => _$GraphEdgeFromJson(json);

@override final  String fromId;
@override final  String toId;
@override final  EdgeType type;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of GraphEdge
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GraphEdgeCopyWith<_GraphEdge> get copyWith => __$GraphEdgeCopyWithImpl<_GraphEdge>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GraphEdgeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GraphEdge&&(identical(other.fromId, fromId) || other.fromId == fromId)&&(identical(other.toId, toId) || other.toId == toId)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,fromId,toId,type,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'GraphEdge(fromId: $fromId, toId: $toId, type: $type, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$GraphEdgeCopyWith<$Res> implements $GraphEdgeCopyWith<$Res> {
  factory _$GraphEdgeCopyWith(_GraphEdge value, $Res Function(_GraphEdge) _then) = __$GraphEdgeCopyWithImpl;
@override @useResult
$Res call({
 String fromId, String toId, EdgeType type, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$GraphEdgeCopyWithImpl<$Res>
    implements _$GraphEdgeCopyWith<$Res> {
  __$GraphEdgeCopyWithImpl(this._self, this._then);

  final _GraphEdge _self;
  final $Res Function(_GraphEdge) _then;

/// Create a copy of GraphEdge
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fromId = null,Object? toId = null,Object? type = null,Object? metadata = freezed,}) {
  return _then(_GraphEdge(
fromId: null == fromId ? _self.fromId : fromId // ignore: cast_nullable_to_non_nullable
as String,toId: null == toId ? _self.toId : toId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as EdgeType,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
