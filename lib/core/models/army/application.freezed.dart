// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'application.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SquadApplication {

 String get id; String get walletAddress; String get squadId; String? get message; ApplicationStatus get status; String? get reviewedById; DateTime? get reviewedAt; DateTime get createdAt;
/// Create a copy of SquadApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SquadApplicationCopyWith<SquadApplication> get copyWith => _$SquadApplicationCopyWithImpl<SquadApplication>(this as SquadApplication, _$identity);

  /// Serializes this SquadApplication to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SquadApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.walletAddress, walletAddress) || other.walletAddress == walletAddress)&&(identical(other.squadId, squadId) || other.squadId == squadId)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewedById, reviewedById) || other.reviewedById == reviewedById)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,walletAddress,squadId,message,status,reviewedById,reviewedAt,createdAt);

@override
String toString() {
  return 'SquadApplication(id: $id, walletAddress: $walletAddress, squadId: $squadId, message: $message, status: $status, reviewedById: $reviewedById, reviewedAt: $reviewedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SquadApplicationCopyWith<$Res>  {
  factory $SquadApplicationCopyWith(SquadApplication value, $Res Function(SquadApplication) _then) = _$SquadApplicationCopyWithImpl;
@useResult
$Res call({
 String id, String walletAddress, String squadId, String? message, ApplicationStatus status, String? reviewedById, DateTime? reviewedAt, DateTime createdAt
});




}
/// @nodoc
class _$SquadApplicationCopyWithImpl<$Res>
    implements $SquadApplicationCopyWith<$Res> {
  _$SquadApplicationCopyWithImpl(this._self, this._then);

  final SquadApplication _self;
  final $Res Function(SquadApplication) _then;

/// Create a copy of SquadApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? walletAddress = null,Object? squadId = null,Object? message = freezed,Object? status = null,Object? reviewedById = freezed,Object? reviewedAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,walletAddress: null == walletAddress ? _self.walletAddress : walletAddress // ignore: cast_nullable_to_non_nullable
as String,squadId: null == squadId ? _self.squadId : squadId // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ApplicationStatus,reviewedById: freezed == reviewedById ? _self.reviewedById : reviewedById // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SquadApplication].
extension SquadApplicationPatterns on SquadApplication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SquadApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SquadApplication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SquadApplication value)  $default,){
final _that = this;
switch (_that) {
case _SquadApplication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SquadApplication value)?  $default,){
final _that = this;
switch (_that) {
case _SquadApplication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String walletAddress,  String squadId,  String? message,  ApplicationStatus status,  String? reviewedById,  DateTime? reviewedAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SquadApplication() when $default != null:
return $default(_that.id,_that.walletAddress,_that.squadId,_that.message,_that.status,_that.reviewedById,_that.reviewedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String walletAddress,  String squadId,  String? message,  ApplicationStatus status,  String? reviewedById,  DateTime? reviewedAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _SquadApplication():
return $default(_that.id,_that.walletAddress,_that.squadId,_that.message,_that.status,_that.reviewedById,_that.reviewedAt,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String walletAddress,  String squadId,  String? message,  ApplicationStatus status,  String? reviewedById,  DateTime? reviewedAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _SquadApplication() when $default != null:
return $default(_that.id,_that.walletAddress,_that.squadId,_that.message,_that.status,_that.reviewedById,_that.reviewedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SquadApplication extends SquadApplication {
  const _SquadApplication({required this.id, required this.walletAddress, required this.squadId, this.message, this.status = ApplicationStatus.pending, this.reviewedById, this.reviewedAt, required this.createdAt}): super._();
  factory _SquadApplication.fromJson(Map<String, dynamic> json) => _$SquadApplicationFromJson(json);

@override final  String id;
@override final  String walletAddress;
@override final  String squadId;
@override final  String? message;
@override@JsonKey() final  ApplicationStatus status;
@override final  String? reviewedById;
@override final  DateTime? reviewedAt;
@override final  DateTime createdAt;

/// Create a copy of SquadApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SquadApplicationCopyWith<_SquadApplication> get copyWith => __$SquadApplicationCopyWithImpl<_SquadApplication>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SquadApplicationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SquadApplication&&(identical(other.id, id) || other.id == id)&&(identical(other.walletAddress, walletAddress) || other.walletAddress == walletAddress)&&(identical(other.squadId, squadId) || other.squadId == squadId)&&(identical(other.message, message) || other.message == message)&&(identical(other.status, status) || other.status == status)&&(identical(other.reviewedById, reviewedById) || other.reviewedById == reviewedById)&&(identical(other.reviewedAt, reviewedAt) || other.reviewedAt == reviewedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,walletAddress,squadId,message,status,reviewedById,reviewedAt,createdAt);

@override
String toString() {
  return 'SquadApplication(id: $id, walletAddress: $walletAddress, squadId: $squadId, message: $message, status: $status, reviewedById: $reviewedById, reviewedAt: $reviewedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SquadApplicationCopyWith<$Res> implements $SquadApplicationCopyWith<$Res> {
  factory _$SquadApplicationCopyWith(_SquadApplication value, $Res Function(_SquadApplication) _then) = __$SquadApplicationCopyWithImpl;
@override @useResult
$Res call({
 String id, String walletAddress, String squadId, String? message, ApplicationStatus status, String? reviewedById, DateTime? reviewedAt, DateTime createdAt
});




}
/// @nodoc
class __$SquadApplicationCopyWithImpl<$Res>
    implements _$SquadApplicationCopyWith<$Res> {
  __$SquadApplicationCopyWithImpl(this._self, this._then);

  final _SquadApplication _self;
  final $Res Function(_SquadApplication) _then;

/// Create a copy of SquadApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? walletAddress = null,Object? squadId = null,Object? message = freezed,Object? status = null,Object? reviewedById = freezed,Object? reviewedAt = freezed,Object? createdAt = null,}) {
  return _then(_SquadApplication(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,walletAddress: null == walletAddress ? _self.walletAddress : walletAddress // ignore: cast_nullable_to_non_nullable
as String,squadId: null == squadId ? _self.squadId : squadId // ignore: cast_nullable_to_non_nullable
as String,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ApplicationStatus,reviewedById: freezed == reviewedById ? _self.reviewedById : reviewedById // ignore: cast_nullable_to_non_nullable
as String?,reviewedAt: freezed == reviewedAt ? _self.reviewedAt : reviewedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
