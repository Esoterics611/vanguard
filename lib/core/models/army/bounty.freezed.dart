// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bounty.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bounty {

 String get id; String get title; String get description; String get creatorId; int get totalAmount; int get remainingAmount; DateTime get deadline; BountyStatus get status; List<String> get objectiveIds; List<String> get skillTags; DateTime? get createdAt; DateTime? get completedAt;
/// Create a copy of Bounty
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BountyCopyWith<Bounty> get copyWith => _$BountyCopyWithImpl<Bounty>(this as Bounty, _$identity);

  /// Serializes this Bounty to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bounty&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.remainingAmount, remainingAmount) || other.remainingAmount == remainingAmount)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.objectiveIds, objectiveIds)&&const DeepCollectionEquality().equals(other.skillTags, skillTags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,creatorId,totalAmount,remainingAmount,deadline,status,const DeepCollectionEquality().hash(objectiveIds),const DeepCollectionEquality().hash(skillTags),createdAt,completedAt);

@override
String toString() {
  return 'Bounty(id: $id, title: $title, description: $description, creatorId: $creatorId, totalAmount: $totalAmount, remainingAmount: $remainingAmount, deadline: $deadline, status: $status, objectiveIds: $objectiveIds, skillTags: $skillTags, createdAt: $createdAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $BountyCopyWith<$Res>  {
  factory $BountyCopyWith(Bounty value, $Res Function(Bounty) _then) = _$BountyCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String creatorId, int totalAmount, int remainingAmount, DateTime deadline, BountyStatus status, List<String> objectiveIds, List<String> skillTags, DateTime? createdAt, DateTime? completedAt
});




}
/// @nodoc
class _$BountyCopyWithImpl<$Res>
    implements $BountyCopyWith<$Res> {
  _$BountyCopyWithImpl(this._self, this._then);

  final Bounty _self;
  final $Res Function(Bounty) _then;

/// Create a copy of Bounty
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? creatorId = null,Object? totalAmount = null,Object? remainingAmount = null,Object? deadline = null,Object? status = null,Object? objectiveIds = null,Object? skillTags = null,Object? createdAt = freezed,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as int,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BountyStatus,objectiveIds: null == objectiveIds ? _self.objectiveIds : objectiveIds // ignore: cast_nullable_to_non_nullable
as List<String>,skillTags: null == skillTags ? _self.skillTags : skillTags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Bounty].
extension BountyPatterns on Bounty {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bounty value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bounty() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bounty value)  $default,){
final _that = this;
switch (_that) {
case _Bounty():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bounty value)?  $default,){
final _that = this;
switch (_that) {
case _Bounty() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String creatorId,  int totalAmount,  int remainingAmount,  DateTime deadline,  BountyStatus status,  List<String> objectiveIds,  List<String> skillTags,  DateTime? createdAt,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bounty() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.creatorId,_that.totalAmount,_that.remainingAmount,_that.deadline,_that.status,_that.objectiveIds,_that.skillTags,_that.createdAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String creatorId,  int totalAmount,  int remainingAmount,  DateTime deadline,  BountyStatus status,  List<String> objectiveIds,  List<String> skillTags,  DateTime? createdAt,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _Bounty():
return $default(_that.id,_that.title,_that.description,_that.creatorId,_that.totalAmount,_that.remainingAmount,_that.deadline,_that.status,_that.objectiveIds,_that.skillTags,_that.createdAt,_that.completedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String creatorId,  int totalAmount,  int remainingAmount,  DateTime deadline,  BountyStatus status,  List<String> objectiveIds,  List<String> skillTags,  DateTime? createdAt,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _Bounty() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.creatorId,_that.totalAmount,_that.remainingAmount,_that.deadline,_that.status,_that.objectiveIds,_that.skillTags,_that.createdAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bounty extends Bounty {
  const _Bounty({required this.id, required this.title, required this.description, required this.creatorId, required this.totalAmount, this.remainingAmount = 0, required this.deadline, this.status = BountyStatus.draft, final  List<String> objectiveIds = const [], final  List<String> skillTags = const [], this.createdAt = null, this.completedAt}): _objectiveIds = objectiveIds,_skillTags = skillTags,super._();
  factory _Bounty.fromJson(Map<String, dynamic> json) => _$BountyFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String creatorId;
@override final  int totalAmount;
@override@JsonKey() final  int remainingAmount;
@override final  DateTime deadline;
@override@JsonKey() final  BountyStatus status;
 final  List<String> _objectiveIds;
@override@JsonKey() List<String> get objectiveIds {
  if (_objectiveIds is EqualUnmodifiableListView) return _objectiveIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_objectiveIds);
}

 final  List<String> _skillTags;
@override@JsonKey() List<String> get skillTags {
  if (_skillTags is EqualUnmodifiableListView) return _skillTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skillTags);
}

@override@JsonKey() final  DateTime? createdAt;
@override final  DateTime? completedAt;

/// Create a copy of Bounty
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BountyCopyWith<_Bounty> get copyWith => __$BountyCopyWithImpl<_Bounty>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BountyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bounty&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.creatorId, creatorId) || other.creatorId == creatorId)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.remainingAmount, remainingAmount) || other.remainingAmount == remainingAmount)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._objectiveIds, _objectiveIds)&&const DeepCollectionEquality().equals(other._skillTags, _skillTags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,creatorId,totalAmount,remainingAmount,deadline,status,const DeepCollectionEquality().hash(_objectiveIds),const DeepCollectionEquality().hash(_skillTags),createdAt,completedAt);

@override
String toString() {
  return 'Bounty(id: $id, title: $title, description: $description, creatorId: $creatorId, totalAmount: $totalAmount, remainingAmount: $remainingAmount, deadline: $deadline, status: $status, objectiveIds: $objectiveIds, skillTags: $skillTags, createdAt: $createdAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$BountyCopyWith<$Res> implements $BountyCopyWith<$Res> {
  factory _$BountyCopyWith(_Bounty value, $Res Function(_Bounty) _then) = __$BountyCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String creatorId, int totalAmount, int remainingAmount, DateTime deadline, BountyStatus status, List<String> objectiveIds, List<String> skillTags, DateTime? createdAt, DateTime? completedAt
});




}
/// @nodoc
class __$BountyCopyWithImpl<$Res>
    implements _$BountyCopyWith<$Res> {
  __$BountyCopyWithImpl(this._self, this._then);

  final _Bounty _self;
  final $Res Function(_Bounty) _then;

/// Create a copy of Bounty
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? creatorId = null,Object? totalAmount = null,Object? remainingAmount = null,Object? deadline = null,Object? status = null,Object? objectiveIds = null,Object? skillTags = null,Object? createdAt = freezed,Object? completedAt = freezed,}) {
  return _then(_Bounty(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,creatorId: null == creatorId ? _self.creatorId : creatorId // ignore: cast_nullable_to_non_nullable
as String,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,remainingAmount: null == remainingAmount ? _self.remainingAmount : remainingAmount // ignore: cast_nullable_to_non_nullable
as int,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as BountyStatus,objectiveIds: null == objectiveIds ? _self._objectiveIds : objectiveIds // ignore: cast_nullable_to_non_nullable
as List<String>,skillTags: null == skillTags ? _self._skillTags : skillTags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
