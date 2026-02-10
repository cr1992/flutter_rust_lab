// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'simple.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DynamicValue {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DynamicValue);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DynamicValue()';
}


}

/// @nodoc
class $DynamicValueCopyWith<$Res>  {
$DynamicValueCopyWith(DynamicValue _, $Res Function(DynamicValue) __);
}


/// Adds pattern-matching-related methods to [DynamicValue].
extension DynamicValuePatterns on DynamicValue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DynamicValue_Null value)?  null_,TResult Function( DynamicValue_Bool value)?  bool,TResult Function( DynamicValue_Number value)?  number,TResult Function( DynamicValue_String value)?  string,TResult Function( DynamicValue_List value)?  list,TResult Function( DynamicValue_Map value)?  map,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DynamicValue_Null() when null_ != null:
return null_(_that);case DynamicValue_Bool() when bool != null:
return bool(_that);case DynamicValue_Number() when number != null:
return number(_that);case DynamicValue_String() when string != null:
return string(_that);case DynamicValue_List() when list != null:
return list(_that);case DynamicValue_Map() when map != null:
return map(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DynamicValue_Null value)  null_,required TResult Function( DynamicValue_Bool value)  bool,required TResult Function( DynamicValue_Number value)  number,required TResult Function( DynamicValue_String value)  string,required TResult Function( DynamicValue_List value)  list,required TResult Function( DynamicValue_Map value)  map,}){
final _that = this;
switch (_that) {
case DynamicValue_Null():
return null_(_that);case DynamicValue_Bool():
return bool(_that);case DynamicValue_Number():
return number(_that);case DynamicValue_String():
return string(_that);case DynamicValue_List():
return list(_that);case DynamicValue_Map():
return map(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DynamicValue_Null value)?  null_,TResult? Function( DynamicValue_Bool value)?  bool,TResult? Function( DynamicValue_Number value)?  number,TResult? Function( DynamicValue_String value)?  string,TResult? Function( DynamicValue_List value)?  list,TResult? Function( DynamicValue_Map value)?  map,}){
final _that = this;
switch (_that) {
case DynamicValue_Null() when null_ != null:
return null_(_that);case DynamicValue_Bool() when bool != null:
return bool(_that);case DynamicValue_Number() when number != null:
return number(_that);case DynamicValue_String() when string != null:
return string(_that);case DynamicValue_List() when list != null:
return list(_that);case DynamicValue_Map() when map != null:
return map(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  null_,TResult Function( bool field0)?  bool,TResult Function( double field0)?  number,TResult Function( String field0)?  string,TResult Function( List<DynamicValue> field0)?  list,TResult Function( List<(String, DynamicValue)> field0)?  map,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DynamicValue_Null() when null_ != null:
return null_();case DynamicValue_Bool() when bool != null:
return bool(_that.field0);case DynamicValue_Number() when number != null:
return number(_that.field0);case DynamicValue_String() when string != null:
return string(_that.field0);case DynamicValue_List() when list != null:
return list(_that.field0);case DynamicValue_Map() when map != null:
return map(_that.field0);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  null_,required TResult Function( bool field0)  bool,required TResult Function( double field0)  number,required TResult Function( String field0)  string,required TResult Function( List<DynamicValue> field0)  list,required TResult Function( List<(String, DynamicValue)> field0)  map,}) {final _that = this;
switch (_that) {
case DynamicValue_Null():
return null_();case DynamicValue_Bool():
return bool(_that.field0);case DynamicValue_Number():
return number(_that.field0);case DynamicValue_String():
return string(_that.field0);case DynamicValue_List():
return list(_that.field0);case DynamicValue_Map():
return map(_that.field0);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  null_,TResult? Function( bool field0)?  bool,TResult? Function( double field0)?  number,TResult? Function( String field0)?  string,TResult? Function( List<DynamicValue> field0)?  list,TResult? Function( List<(String, DynamicValue)> field0)?  map,}) {final _that = this;
switch (_that) {
case DynamicValue_Null() when null_ != null:
return null_();case DynamicValue_Bool() when bool != null:
return bool(_that.field0);case DynamicValue_Number() when number != null:
return number(_that.field0);case DynamicValue_String() when string != null:
return string(_that.field0);case DynamicValue_List() when list != null:
return list(_that.field0);case DynamicValue_Map() when map != null:
return map(_that.field0);case _:
  return null;

}
}

}

/// @nodoc


class DynamicValue_Null extends DynamicValue {
  const DynamicValue_Null(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DynamicValue_Null);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DynamicValue.null_()';
}


}




/// @nodoc


class DynamicValue_Bool extends DynamicValue {
  const DynamicValue_Bool(this.field0): super._();
  

 final  bool field0;

/// Create a copy of DynamicValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DynamicValue_BoolCopyWith<DynamicValue_Bool> get copyWith => _$DynamicValue_BoolCopyWithImpl<DynamicValue_Bool>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DynamicValue_Bool&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'DynamicValue.bool(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $DynamicValue_BoolCopyWith<$Res> implements $DynamicValueCopyWith<$Res> {
  factory $DynamicValue_BoolCopyWith(DynamicValue_Bool value, $Res Function(DynamicValue_Bool) _then) = _$DynamicValue_BoolCopyWithImpl;
@useResult
$Res call({
 bool field0
});




}
/// @nodoc
class _$DynamicValue_BoolCopyWithImpl<$Res>
    implements $DynamicValue_BoolCopyWith<$Res> {
  _$DynamicValue_BoolCopyWithImpl(this._self, this._then);

  final DynamicValue_Bool _self;
  final $Res Function(DynamicValue_Bool) _then;

/// Create a copy of DynamicValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(DynamicValue_Bool(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class DynamicValue_Number extends DynamicValue {
  const DynamicValue_Number(this.field0): super._();
  

 final  double field0;

/// Create a copy of DynamicValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DynamicValue_NumberCopyWith<DynamicValue_Number> get copyWith => _$DynamicValue_NumberCopyWithImpl<DynamicValue_Number>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DynamicValue_Number&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'DynamicValue.number(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $DynamicValue_NumberCopyWith<$Res> implements $DynamicValueCopyWith<$Res> {
  factory $DynamicValue_NumberCopyWith(DynamicValue_Number value, $Res Function(DynamicValue_Number) _then) = _$DynamicValue_NumberCopyWithImpl;
@useResult
$Res call({
 double field0
});




}
/// @nodoc
class _$DynamicValue_NumberCopyWithImpl<$Res>
    implements $DynamicValue_NumberCopyWith<$Res> {
  _$DynamicValue_NumberCopyWithImpl(this._self, this._then);

  final DynamicValue_Number _self;
  final $Res Function(DynamicValue_Number) _then;

/// Create a copy of DynamicValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(DynamicValue_Number(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc


class DynamicValue_String extends DynamicValue {
  const DynamicValue_String(this.field0): super._();
  

 final  String field0;

/// Create a copy of DynamicValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DynamicValue_StringCopyWith<DynamicValue_String> get copyWith => _$DynamicValue_StringCopyWithImpl<DynamicValue_String>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DynamicValue_String&&(identical(other.field0, field0) || other.field0 == field0));
}


@override
int get hashCode => Object.hash(runtimeType,field0);

@override
String toString() {
  return 'DynamicValue.string(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $DynamicValue_StringCopyWith<$Res> implements $DynamicValueCopyWith<$Res> {
  factory $DynamicValue_StringCopyWith(DynamicValue_String value, $Res Function(DynamicValue_String) _then) = _$DynamicValue_StringCopyWithImpl;
@useResult
$Res call({
 String field0
});




}
/// @nodoc
class _$DynamicValue_StringCopyWithImpl<$Res>
    implements $DynamicValue_StringCopyWith<$Res> {
  _$DynamicValue_StringCopyWithImpl(this._self, this._then);

  final DynamicValue_String _self;
  final $Res Function(DynamicValue_String) _then;

/// Create a copy of DynamicValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(DynamicValue_String(
null == field0 ? _self.field0 : field0 // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DynamicValue_List extends DynamicValue {
  const DynamicValue_List(final  List<DynamicValue> field0): _field0 = field0,super._();
  

 final  List<DynamicValue> _field0;
 List<DynamicValue> get field0 {
  if (_field0 is EqualUnmodifiableListView) return _field0;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_field0);
}


/// Create a copy of DynamicValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DynamicValue_ListCopyWith<DynamicValue_List> get copyWith => _$DynamicValue_ListCopyWithImpl<DynamicValue_List>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DynamicValue_List&&const DeepCollectionEquality().equals(other._field0, _field0));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_field0));

@override
String toString() {
  return 'DynamicValue.list(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $DynamicValue_ListCopyWith<$Res> implements $DynamicValueCopyWith<$Res> {
  factory $DynamicValue_ListCopyWith(DynamicValue_List value, $Res Function(DynamicValue_List) _then) = _$DynamicValue_ListCopyWithImpl;
@useResult
$Res call({
 List<DynamicValue> field0
});




}
/// @nodoc
class _$DynamicValue_ListCopyWithImpl<$Res>
    implements $DynamicValue_ListCopyWith<$Res> {
  _$DynamicValue_ListCopyWithImpl(this._self, this._then);

  final DynamicValue_List _self;
  final $Res Function(DynamicValue_List) _then;

/// Create a copy of DynamicValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(DynamicValue_List(
null == field0 ? _self._field0 : field0 // ignore: cast_nullable_to_non_nullable
as List<DynamicValue>,
  ));
}


}

/// @nodoc


class DynamicValue_Map extends DynamicValue {
  const DynamicValue_Map(final  List<(String, DynamicValue)> field0): _field0 = field0,super._();
  

 final  List<(String, DynamicValue)> _field0;
 List<(String, DynamicValue)> get field0 {
  if (_field0 is EqualUnmodifiableListView) return _field0;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_field0);
}


/// Create a copy of DynamicValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DynamicValue_MapCopyWith<DynamicValue_Map> get copyWith => _$DynamicValue_MapCopyWithImpl<DynamicValue_Map>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DynamicValue_Map&&const DeepCollectionEquality().equals(other._field0, _field0));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_field0));

@override
String toString() {
  return 'DynamicValue.map(field0: $field0)';
}


}

/// @nodoc
abstract mixin class $DynamicValue_MapCopyWith<$Res> implements $DynamicValueCopyWith<$Res> {
  factory $DynamicValue_MapCopyWith(DynamicValue_Map value, $Res Function(DynamicValue_Map) _then) = _$DynamicValue_MapCopyWithImpl;
@useResult
$Res call({
 List<(String, DynamicValue)> field0
});




}
/// @nodoc
class _$DynamicValue_MapCopyWithImpl<$Res>
    implements $DynamicValue_MapCopyWith<$Res> {
  _$DynamicValue_MapCopyWithImpl(this._self, this._then);

  final DynamicValue_Map _self;
  final $Res Function(DynamicValue_Map) _then;

/// Create a copy of DynamicValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field0 = null,}) {
  return _then(DynamicValue_Map(
null == field0 ? _self._field0 : field0 // ignore: cast_nullable_to_non_nullable
as List<(String, DynamicValue)>,
  ));
}


}

// dart format on
