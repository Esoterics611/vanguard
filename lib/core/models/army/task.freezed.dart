// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Task {

 String get id; String get title; String get description; String get objectiveId; String? get assigneeId; TaskStatus get status; TaskPriority get priority; int get rewardVgrd; DateTime get deadline; String? get submissionIpfsHash; DateTime? get completedAt; DateTime get createdAt; String? get createdById;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.objectiveId, objectiveId) || other.objectiveId == objectiveId)&&(identical(other.assigneeId, assigneeId) || other.assigneeId == assigneeId)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.rewardVgrd, rewardVgrd) || other.rewardVgrd == rewardVgrd)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.submissionIpfsHash, submissionIpfsHash) || other.submissionIpfsHash == submissionIpfsHash)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdById, createdById) || other.createdById == createdById));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,objectiveId,assigneeId,status,priority,rewardVgrd,deadline,submissionIpfsHash,completedAt,createdAt,createdById);

@override
String toString() {
  return 'Task(id: $id, title: $title, description: $description, objectiveId: $objectiveId, assigneeId: $assigneeId, status: $status, priority: $priority, rewardVgrd: $rewardVgrd, deadline: $deadline, submissionIpfsHash: $submissionIpfsHash, completedAt: $completedAt, createdAt: $createdAt, createdById: $createdById)';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 String id, String title, String description, String objectiveId, String? assigneeId, TaskStatus status, TaskPriority priority, int rewardVgrd, DateTime deadline, String? submissionIpfsHash, DateTime? completedAt, DateTime createdAt, String? createdById
});




}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? description = null,Object? objectiveId = null,Object? assigneeId = freezed,Object? status = null,Object? priority = null,Object? rewardVgrd = null,Object? deadline = null,Object? submissionIpfsHash = freezed,Object? completedAt = freezed,Object? createdAt = null,Object? createdById = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,objectiveId: null == objectiveId ? _self.objectiveId : objectiveId // ignore: cast_nullable_to_non_nullable
as String,assigneeId: freezed == assigneeId ? _self.assigneeId : assigneeId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,rewardVgrd: null == rewardVgrd ? _self.rewardVgrd : rewardVgrd // ignore: cast_nullable_to_non_nullable
as int,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,submissionIpfsHash: freezed == submissionIpfsHash ? _self.submissionIpfsHash : submissionIpfsHash // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdById: freezed == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Task].
extension TaskPatterns on Task {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Task value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Task value)  $default,){
final _that = this;
switch (_that) {
case _Task():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Task value)?  $default,){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String objectiveId,  String? assigneeId,  TaskStatus status,  TaskPriority priority,  int rewardVgrd,  DateTime deadline,  String? submissionIpfsHash,  DateTime? completedAt,  DateTime createdAt,  String? createdById)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.objectiveId,_that.assigneeId,_that.status,_that.priority,_that.rewardVgrd,_that.deadline,_that.submissionIpfsHash,_that.completedAt,_that.createdAt,_that.createdById);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String description,  String objectiveId,  String? assigneeId,  TaskStatus status,  TaskPriority priority,  int rewardVgrd,  DateTime deadline,  String? submissionIpfsHash,  DateTime? completedAt,  DateTime createdAt,  String? createdById)  $default,) {final _that = this;
switch (_that) {
case _Task():
return $default(_that.id,_that.title,_that.description,_that.objectiveId,_that.assigneeId,_that.status,_that.priority,_that.rewardVgrd,_that.deadline,_that.submissionIpfsHash,_that.completedAt,_that.createdAt,_that.createdById);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String description,  String objectiveId,  String? assigneeId,  TaskStatus status,  TaskPriority priority,  int rewardVgrd,  DateTime deadline,  String? submissionIpfsHash,  DateTime? completedAt,  DateTime createdAt,  String? createdById)?  $default,) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.title,_that.description,_that.objectiveId,_that.assigneeId,_that.status,_that.priority,_that.rewardVgrd,_that.deadline,_that.submissionIpfsHash,_that.completedAt,_that.createdAt,_that.createdById);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Task extends Task {
  const _Task({required this.id, required this.title, required this.description, required this.objectiveId, this.assigneeId, this.status = TaskStatus.created, this.priority = TaskPriority.medium, required this.rewardVgrd, required this.deadline, this.submissionIpfsHash, this.completedAt, required this.createdAt, this.createdById}): super._();
  factory _Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

@override final  String id;
@override final  String title;
@override final  String description;
@override final  String objectiveId;
@override final  String? assigneeId;
@override@JsonKey() final  TaskStatus status;
@override@JsonKey() final  TaskPriority priority;
@override final  int rewardVgrd;
@override final  DateTime deadline;
@override final  String? submissionIpfsHash;
@override final  DateTime? completedAt;
@override final  DateTime createdAt;
@override final  String? createdById;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.objectiveId, objectiveId) || other.objectiveId == objectiveId)&&(identical(other.assigneeId, assigneeId) || other.assigneeId == assigneeId)&&(identical(other.status, status) || other.status == status)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.rewardVgrd, rewardVgrd) || other.rewardVgrd == rewardVgrd)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.submissionIpfsHash, submissionIpfsHash) || other.submissionIpfsHash == submissionIpfsHash)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.createdById, createdById) || other.createdById == createdById));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,description,objectiveId,assigneeId,status,priority,rewardVgrd,deadline,submissionIpfsHash,completedAt,createdAt,createdById);

@override
String toString() {
  return 'Task(id: $id, title: $title, description: $description, objectiveId: $objectiveId, assigneeId: $assigneeId, status: $status, priority: $priority, rewardVgrd: $rewardVgrd, deadline: $deadline, submissionIpfsHash: $submissionIpfsHash, completedAt: $completedAt, createdAt: $createdAt, createdById: $createdById)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String description, String objectiveId, String? assigneeId, TaskStatus status, TaskPriority priority, int rewardVgrd, DateTime deadline, String? submissionIpfsHash, DateTime? completedAt, DateTime createdAt, String? createdById
});




}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? description = null,Object? objectiveId = null,Object? assigneeId = freezed,Object? status = null,Object? priority = null,Object? rewardVgrd = null,Object? deadline = null,Object? submissionIpfsHash = freezed,Object? completedAt = freezed,Object? createdAt = null,Object? createdById = freezed,}) {
  return _then(_Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,objectiveId: null == objectiveId ? _self.objectiveId : objectiveId // ignore: cast_nullable_to_non_nullable
as String,assigneeId: freezed == assigneeId ? _self.assigneeId : assigneeId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TaskStatus,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as TaskPriority,rewardVgrd: null == rewardVgrd ? _self.rewardVgrd : rewardVgrd // ignore: cast_nullable_to_non_nullable
as int,deadline: null == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime,submissionIpfsHash: freezed == submissionIpfsHash ? _self.submissionIpfsHash : submissionIpfsHash // ignore: cast_nullable_to_non_nullable
as String?,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdById: freezed == createdById ? _self.createdById : createdById // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
