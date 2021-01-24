// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'next.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Next _$NextFromJson(Map json) {
  return Next()
    ..one = json['one'] as String
    ..two = json['two'] as String
    ..three = json['three'] as String
    ..four = json['four'] as String
    ..total = json['total'] as int
    ..max = json['max'] as String;
}

Map<String, dynamic> _$NextToJson(Next instance) => <String, dynamic>{
      'one': instance.one,
      'two': instance.two,
      'three': instance.three,
      'four': instance.four,
      'total': instance.total,
      'max': instance.max,
    };
