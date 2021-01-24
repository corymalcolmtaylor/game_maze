// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pixie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pixie _$PixieFromJson(Map json) {
  return Pixie(
    _$enumDecodeNullable(_$IlkEnumMap, json['ilk']),
  )
    ..key = json['key'] as String
    ..location = json['location'] as String
    ..lastLocation = json['lastLocation'] as String
    ..emoji = json['emoji'] as String
    ..x = json['x'] as int
    ..y = json['y'] as int
    ..lastX = json['lastX'] as int
    ..lastY = json['lastY'] as int
    ..savedLambs = json['savedLambs'] as int
    ..lostLambs = json['lostLambs'] as int
    ..delayComputerMove = json['delayComputerMove'] as bool
    ..recentlyMoved = json['recentlyMoved'] as bool
    ..follow = json['follow'] as bool
    ..isVisible = json['isVisible'] as bool
    ..newDirection =
        _$enumDecodeNullable(_$DirectionsEnumMap, json['newDirection'])
    ..direction = _$enumDecodeNullable(_$DirectionsEnumMap, json['direction'])
    ..facing = _$enumDecodeNullable(_$DirectionsEnumMap, json['facing'])
    ..condition = _$enumDecodeNullable(_$ConditionEnumMap, json['condition'])
    ..preferredColor = json['preferredColor'] as int;
}

Map<String, dynamic> _$PixieToJson(Pixie instance) => <String, dynamic>{
      'key': instance.key,
      'location': instance.location,
      'lastLocation': instance.lastLocation,
      'emoji': instance.emoji,
      'x': instance.x,
      'y': instance.y,
      'lastX': instance.lastX,
      'lastY': instance.lastY,
      'savedLambs': instance.savedLambs,
      'lostLambs': instance.lostLambs,
      'delayComputerMove': instance.delayComputerMove,
      'recentlyMoved': instance.recentlyMoved,
      'follow': instance.follow,
      'isVisible': instance.isVisible,
      'newDirection': _$DirectionsEnumMap[instance.newDirection],
      'direction': _$DirectionsEnumMap[instance.direction],
      'facing': _$DirectionsEnumMap[instance.facing],
      'ilk': _$IlkEnumMap[instance.ilk],
      'condition': _$ConditionEnumMap[instance.condition],
      'preferredColor': instance.preferredColor,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$IlkEnumMap = {
  Ilk.player: 'player',
  Ilk.minotaur: 'minotaur',
  Ilk.lamb: 'lamb',
};

const _$DirectionsEnumMap = {
  Directions.up: 'up',
  Directions.down: 'down',
  Directions.right: 'right',
  Directions.left: 'left',
};

const _$ConditionEnumMap = {
  Condition.alive: 'alive',
  Condition.dead: 'dead',
  Condition.freed: 'freed',
};
