import 'package:json_annotation/json_annotation.dart';

part 'room.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class Room {
  Room();
  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
  Map<String, dynamic> toJson() => _$RoomToJson(this);

  static var badGuyHasMovedThisManyTimes = 0;
  var x = 0;
  var y = 0;
  var setid = 0;
  var minotaursPath = 0;
  var leftWallIsUp = true;
  var rightWallIsUp = true;
  var upWallIsUp = true;
  var downWallIsUp = true;
  var visited = false;
  bool spUsed = false;
  var dir = '';
}
