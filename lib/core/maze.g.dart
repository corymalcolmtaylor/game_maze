// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maze.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Maze _$MazeFromJson(Map json) {
  return Maze(
    json['maxRow'] as int,
    _$enumDecodeNullable(_$GameDifficultyEnumMap, json['difficulty']),
  )
    ..randomid = json['randomid'] as int
    ..numberOfRooms = json['numberOfRooms'] as int
    ..firstedge = json['firstedge'] as String
    ..myLabyrinth = (json['myLabyrinth'] as Map)?.map(
      (k, e) => MapEntry(
          k as String,
          e == null
              ? null
              : Room.fromJson((e as Map)?.map(
                  (k, e) => MapEntry(k as String, e),
                ))),
    )
    ..myStack = (json['myStack'] as List)?.map((e) => e as String)?.toList()
    ..specialCells =
        (json['specialCells'] as List)?.map((e) => e as String)?.toList()
    ..lambs = (json['lambs'] as List)
        ?.map((e) => e == null
            ? null
            : Pixie.fromJson((e as Map)?.map(
                (k, e) => MapEntry(k as String, e),
              )))
        ?.toList()
    ..minotaur = json['minotaur'] == null
        ? null
        : Pixie.fromJson((json['minotaur'] as Map)?.map(
            (k, e) => MapEntry(k as String, e),
          ))
    ..player = json['player'] == null
        ? null
        : Pixie.fromJson((json['player'] as Map)?.map(
            (k, e) => MapEntry(k as String, e),
          ));
}

Map<String, dynamic> _$MazeToJson(Maze instance) => <String, dynamic>{
      'maxRow': instance.maxRow,
      'randomid': instance.randomid,
      'numberOfRooms': instance.numberOfRooms,
      'firstedge': instance.firstedge,
      'difficulty': _$GameDifficultyEnumMap[instance.difficulty],
      'myLabyrinth':
          instance.myLabyrinth?.map((k, e) => MapEntry(k, e?.toJson())),
      'myStack': instance.myStack,
      'specialCells': instance.specialCells,
      'lambs': instance.lambs?.map((e) => e?.toJson())?.toList(),
      'minotaur': instance.minotaur?.toJson(),
      'player': instance.player?.toJson(),
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

const _$GameDifficultyEnumMap = {
  GameDifficulty.normal: 'normal',
  GameDifficulty.hard: 'hard',
  GameDifficulty.tough: 'tough',
};
