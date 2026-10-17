// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'objective.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Objective {

 String get id; String get title; String get description; String get unitId; String get bountyId; ObjectiveStatus get status; List<String> get taskIds; int get allocatedVgrd; DateTime get deadline; DateTime get createdAt; String? get createdById;
/// Create a copy of Objective
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ObjectiveCopyWith<Objective> get copyWith => _$ObjectiveCopyWithImpl<Objective>(this as Objective, _$identity);

  /// Serializes this Objective to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Objective&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.bountyId, bountyId) || other.bountyId == bountyId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.taskIds, taskIds)&&(identical(other.allocatedVgrd, allocatedVgrd) || other.allocatedVgrd == allocatedVgrd)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdById, createdById) || other.createdById == createdById));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,unitId,bountyId,status,const DeepCollectionEquality().hash(taskIds),allocatedVgrd,deadline,createdAt,createdById);

@override
String toString() {
  return 'Objective(id: $id, title: $title, description: $description, unitId: $unitId, bountyId: $bountyId, status: $status, taskIds: $taskIds, allocatedVgrd: $allocatedVgrd, deadline: $deadline, createdAt: $createdAt, createdById: $createdById)';
}


}

/// @nodoc
abstract mixin class $ObjectiveCopyWith<$Res>  {
  factory $ObjectiveCopyWith(Objective value, $Res Function(Objective) _then) = _$ObjectiveCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String unitId, String bountyId, ObjectiveStatus status, List<String> taskIds, int allocatedVgrd, DateTime deadline, DateTime createdAt, String? createdById
});




}
/// @nodoc
class _$ObjectiveCopyWithImpl<$Res>
    implements $ObjectiveCopyWith<$Res> {
  _$ObjectiveCopyWithImpl(this._self, this._then);

  final Objective _self;
  final $Res Function(Objective) _then;

/// Create a copy of Objective
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? unitId = null,Object? bountyId = null,Object? status = null,Object? taskIds = null,Object? allocatedVgrd = null,Object? deadline = null,Object? createdAt = null,Object? createdById = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,bountyId: null == bountyId ? _self.bountyId : bountyId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ObjectiveStatus,taskIds: null == taskIds ? _self.taskIds : taskIds // ignore: cast_nullable_to_non_nullable
as List<String>,allocatedVgrd: null == allocatedVgrd ? _self.allocatedVgrd : allocatedVgrd // ignore: cast_nullable_to_non_nullable
as int,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdById: freezed == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Objective].
extension ObjectivePatterns on Objective {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Objective value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Objective() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Objective value)  $default,){
final _that = this;
switch (_that) {
case _Objective():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Objective value)?  $default,){
final _that = this;
switch (_that) {
case _Objective() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String unitId,  String bountyId,  ObjectiveStatus status,  List<String> taskIds,  int allocatedVgrd,  DateTime deadline,  DateTime createdAt,  String? createdById)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Objective() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.unitId,_that.bountyId,_that.status,_that.taskIds,_that.allocatedVgrd,_that.deadline,_that.createdAt,_that.createdById);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String unitId,  String bountyId,  ObjectiveStatus status,  List<String> taskIds,  int allocatedVgrd,  DateTime deadline,  DateTime createdAt,  String? createdById)  $default,) {final _that = this;
switch (_that) {
case _Objective():
return $default(_that.id,_that.title,_that.description,_that.unitId,_that.bountyId,_that.status,_that.taskIds,_that.allocatedVgrd,_that.deadline,_that.createdAt,_that.createdById);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String unitId,  String bountyId,  ObjectiveStatus status,  List<String> taskIds,  int allocatedVgrd,  DateTime deadline,  DateTime createdAt,  String? createdById)?  $default,) {final _that = this;
switch (_that) {
case _Objective() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.unitId,_that.bountyId,_that.status,_that.taskIds,_that.allocatedVgrd,_that.deadline,_that.createdAt,_that.createdById);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Objective extends Objective {
  const _Objective({required this.id, required this.title, required this.description, required this.unitId, required this.bountyId, this.status = ObjectiveStatus.active, final  List<String> taskIds = const [], required this.allocatedVgrd, required this.deadline, required this.createdAt, this.createdById}): _taskIds = taskIds,super._();
  factory _Objective.fromJson(Map<String, dynamic> json) => _$ObjectiveFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String unitId;
@override final  String bountyId;
@override@JsonKey() final  ObjectiveStatus status;
 final  List<String> _taskIds;
@override@JsonKey() List<String> get taskIds {
  if (_taskIds is EqualUnmodifiableListView) return _taskIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_taskIds);
}

@override final  int allocatedVgrd;
@override final  DateTime deadline;
@override final  DateTime createdAt;
@override final  String? createdById;

/// Create a copy of Objective
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ObjectiveCopyWith<_Objective> get copyWith => __$ObjectiveCopyWithImpl<_Objective>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ObjectiveToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Objective&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.bountyId, bountyId) || other.bountyId == bountyId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._taskIds, _taskIds)&&(identical(other.allocatedVgrd, allocatedVgrd) || other.allocatedVgrd == allocatedVgrd)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdById, createdById) || other.createdById == createdById));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,unitId,bountyId,status,const DeepCollectionEquality().hash(_taskIds),allocatedVgrd,deadline,createdAt,createdById);

@override
String toString() {
  return 'Objective(id: $id, title: $title, description: $description, unitId: $unitId, bountyId: $bountyId, status: $status, taskIds: $taskIds, allocatedVgrd: $allocatedVgrd, deadline: $deadline, createdAt: $createdAt, createdById: $createdById)';
}


}

/// @nodoc
abstract mixin class _$ObjectiveCopyWith<$Res> implements $ObjectiveCopyWith<$Res> {
  factory _$ObjectiveCopyWith(_Objective value, $Res Function(_Objective) _then) = __$ObjectiveCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String unitId, String bountyId, ObjectiveStatus status, List<String> taskIds, int allocatedVgrd, DateTime deadline, DateTime createdAt, String? createdById
});




}
/// @nodoc
class __$ObjectiveCopyWithImpl<$Res>
    implements _$ObjectiveCopyWith<$Res> {
  __$ObjectiveCopyWithImpl(this._self, this._then);

  final _Objective _self;
  final $Res Function(_Objective) _then;

/// Create a copy of Objective
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? unitId = null,Object? bountyId = null,Object? status = null,Object? taskIds = null,Object? allocatedVgrd = null,Object? deadline = null,Object? createdAt = null,Object? createdById = freezed,}) {
  return _then(_Objective(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,bountyId: null == bountyId ? _self.bountyId : bountyId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ObjectiveStatus,taskIds: null == taskIds ? _self._taskIds : taskIds // ignore: cast_nullable_to_non_nullable
as List<String>,allocatedVgrd: null == allocatedVgrd ? _self.allocatedVgrd : allocatedVgrd // ignore: cast_nullable_to_non_nullable
as int,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdById: freezed == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
