// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map json) {
  return Room()
    ..x = json['x'] as int
    ..y = json['y'] as int
    ..setid = json['setid'] as int
    ..minotaursPath = json['minotaursPath'] as int
    ..leftWallIsUp = json['leftWallIsUp'] as bool
    ..rightWallIsUp = json['rightWallIsUp'] as bool
    ..upWallIsUp = json['upWallIsUp'] as bool
    ..downWallIsUp = json['downWallIsUp'] as bool
    ..visited = json['visited'] as bool
    ..spUsed = json['spUsed'] as bool
    ..dir = json['dir'] as String;
}

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'setid': instance.setid,
      'minotaursPath': instance.minotaursPath,
      'leftWallIsUp': instance.leftWallIsUp,
      'rightWallIsUp': instance.rightWallIsUp,
      'upWallIsUp': instance.upWallIsUp,
      'downWallIsUp': instance.downWallIsUp,
      'visited': instance.visited,
      'spUsed': instance.spUsed,
      'dir': instance.dir,
    };
