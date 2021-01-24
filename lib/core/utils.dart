import 'dart:math';
import '../generated/l10n.dart';
import 'room.dart';

enum GameActions { options, rules, about, maze }
enum GameDifficulty { normal, hard, tough }
enum Ilk { player, minotaur, lamb }
enum Directions { up, down, right, left }
enum Condition { alive, dead, freed }

class Utils {
  static const wallThickness = 1.0;
  static const borderWallThickness = 1.3;
  static var normal = S.current.normal;
  static var hard = S.current.hard;
  static var tough = S.current.tough;

  static const String rules = 'RULES';
  static const String info = 'INFO';
  static const String about = 'ABOUT';
  static const String logOut = 'LOGOUT';
  static const String settings = 'SETTINGS';
  static const String dish = 'DISH';

  static const animDurationMilliSeconds = 700;

  static var rand = Random(1);

  static Map<String, Room> deepCopyRoomMap(Map<String, Room> map) {
    var newMap = <String, Room>{};

    map.forEach((key, value) {
      var room = Room()
        ..x = value.x
        ..y = value.y
        ..setid = value.setid
        ..minotaursPath = value.minotaursPath
        ..leftWallIsUp = value.leftWallIsUp
        ..rightWallIsUp = value.rightWallIsUp
        ..upWallIsUp = value.upWallIsUp
        ..downWallIsUp = value.downWallIsUp
        ..visited = value.visited
        ..spUsed = value.spUsed
        ..dir = value.dir;

      newMap[key] = room;
    });

    return newMap;
  }
}
