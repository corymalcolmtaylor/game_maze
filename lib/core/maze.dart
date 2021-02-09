import 'dart:math' as Math;
import 'package:flutter/material.dart';

import 'next.dart';
import 'pixie.dart';
import 'room.dart';
import 'utils.dart';

import 'package:json_annotation/json_annotation.dart';

part 'maze.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class Maze {
  final int maxRow;
  int _maxCol;

  //final _playerMoves = 3;
  int randomid = 0;
  bool _gameIsOver = false;
  var numberOfRooms = 0;

  String _eogEmoji = '';
  var firstedge = '';
  String _gameOverMessage = '';

  final GameDifficulty difficulty;
  Ilk _whosTurnIsIt = Ilk.player;

  Map<String, Room> myLabyrinth = Map();
  List<String> myStack = [];
  List<String> specialCells = [];
  var lambs = <Pixie>[];

  var minotaur = Pixie(Ilk.minotaur);
  var player = Pixie(Ilk.player);

  factory Maze.fromJson(Map<String, dynamic> json) => _$MazeFromJson(json);
  Map<String, dynamic> toJson() => _$MazeToJson(this);

  factory Maze.initial() {
    Maze mz = Maze(8, GameDifficulty.normal);
    mz.initMaze();
    return mz;
  }

  // create and initialize the labyrinth
  //s squares named b_x_y eg b_1_3 for square A3 on a chess board
  // each square starts as its own set and has its own number; eg 1-64
  Maze(this.maxRow, this.difficulty) {
    initMaze();
    carveLabyrinth();
  } // END FUNCTION ***********************

  initMaze() {
    _maxCol = maxRow;
    lambs.clear();
    myLabyrinth.clear();
    _gameIsOver = false;
    setGameOverMessage('');
    _whosTurnIsIt = Ilk.player;
    Room.badGuyHasMovedThisManyTimes = 0;
    for (var yloop = 1; yloop < maxRow + 1; yloop++) {
      for (var xloop = 1; xloop < _maxCol + 1; xloop++) {
        myLabyrinth['b_${xloop}_$yloop'] = Room();

        myLabyrinth['b_${xloop}_$yloop'].x = xloop;
        myLabyrinth['b_${xloop}_$yloop'].y = yloop;
      }
    }
  }

  //int newRandomId() {
  //  return DateTime.now().millisecondsSinceEpoch${} + 1;
  //}

  Maze copyThisMaze() {
    var mz = Maze(maxRow, difficulty)
      ..myLabyrinth = Utils.deepCopyRoomMap(myLabyrinth)
      .._gameOverMessage = _gameOverMessage
      .._gameIsOver = _gameIsOver
      .._maxCol = _maxCol
      ..numberOfRooms = numberOfRooms
      ..firstedge = firstedge
      ..player = player
      ..minotaur = minotaur
      ..lambs = lambs.toList()
      ..randomid = randomid + 1;

    print('copyThisMaze randomid ${mz.randomid}');
    return mz;
  }

  int getPlayerMoves() {
    return 3;
  }

  void setEogEmoji(String eogEmoji) {
    _eogEmoji = eogEmoji;
  }

  String getEogEmoji() {
    return '$_eogEmoji';
  }

  bool gameIsOver() {
    return _gameIsOver == true;
  }

  void setGameIsOver(bool gameIsOver) {
    _gameIsOver = gameIsOver;
  }

  String getGameOverMessage() {
    return '$_gameOverMessage';
  }

  setGameOverMessage(String gameOverMessage) {
    _gameOverMessage = gameOverMessage;
  }

  Ilk getWhosTurnIsIt() {
    return _whosTurnIsIt;
  }

  void setWhosTurnItIs(Ilk whosTurnIsIt) {
    _whosTurnIsIt = whosTurnIsIt;
  }

  bool isEasy() {
    return difficulty == GameDifficulty.normal;
  }

  bool isHard() {
    return difficulty == GameDifficulty.hard;
  }

  bool isTough() {
    return difficulty == GameDifficulty.tough;
  }

  int getMaxRow() {
    return maxRow;
  }

  int getMaxCol() {
    return _maxCol;
  }

  void clearLocationsOfLambsInThisCondition({Condition condition}) {
    lambs.forEach((lamb) {
      if (lamb.condition == condition) {
        lamb.location = '';
        lamb.lastLocation = '';
      }
    });
  }

  void movePlayer(Directions direction) {}

  void preparePlayerForATurn() {
    player.setMovesLeft(getPlayerMoves());
    player.delayComputerMove = true;
    _whosTurnIsIt = Ilk.player;
  }

  bool bossGoHandleAnyLambAtYourLocation({Pixie boss}) {
    if (boss.ilk == Ilk.lamb) return false;
    var handled = false;
    //if minotaur on player location then gameover
    if (minotaur.location == player.location) {
      boss.setMovesLeft(0);
      player.condition = Condition.dead;
      return endGame();
    }
    lambs.forEach((el) {
      if (el.condition != Condition.alive) {
        return handled;
      }
      if (el.location == boss.location) {
        if (boss.ilk == Ilk.minotaur) {
          if (difficulty == GameDifficulty.tough &&
              player.savedLambs > maxRow / 2) {
            return handled;
          } else {
            boss.setMovesLeft(0);
            el.condition = Condition.dead;
            player.lostLambs++;
            print('lost lamb ${el.emoji}');
            handled = true;
          }
        } else if (boss.ilk == Ilk.player) {
          boss.setMovesLeft(0);
          el.condition = Condition.freed;
          player.savedLambs++;
          print('saved lamb ${el.emoji}');
          handled = true;
        } else {
          print(
              'lost lamb difficulty=$difficulty, ${el.emoji}, ${el.location}');
          print('*****');
          handled = false;
        }
      }
    });

    return handled;
  }

  bool thisLocationIsOccupiedByALamb({String location}) {
    var seen = false;
    lambs.forEach((el) {
      if (el.location == location) {
        seen = true;
      }
    });
    return seen;
  }

  bool movePixieToXY(Pixie pixie, int x, int y) {
    //print('movePixieToXY b_${x}_$y');
    final newloc = 'b_${x}_$y';
    if (pixie.ilk == Ilk.lamb && minotaur.location == newloc) {
      return false;
    }
    /* do not let lambs walk on each other */
    if (pixie.ilk == Ilk.lamb &&
        thisLocationIsOccupiedByALamb(location: newloc)) {
      return false;
    }

    if ((pixie.ilk == Ilk.lamb || pixie.ilk == Ilk.minotaur) &&
        pixie.lastLocation == newloc) {
      pixie.lastLocation = '';
      return false;
    }
    pixie.lastLocation = 'b_${pixie.x}_${pixie.y}';
    pixie.lastX = pixie.x;
    pixie.lastY = pixie.y;
    pixie.x = x;
    pixie.y = y;
    pixie.location = newloc;
    pixie.setMovesLeft(pixie.getMovesLeft() - 1);

    return true;
  }

  String whatLocationIsFoundByMovingInThisDirectionFromThisPixiesLocation(
      {Pixie pixie, Directions direction}) {
    switch (direction) {
      case Directions.down:
        return 'b_${pixie.x}_${pixie.y + 1}';
      case Directions.up:
        return 'b_${pixie.x}_${pixie.y - 1}';
      case Directions.right:
        return 'b_${pixie.x + 1}_${pixie.y}';
      case Directions.left:
        return 'b_${pixie.x - 1}_${pixie.y}';
    }
    return pixie.location;
  }

  bool aPixieCanMoveDirectionFromLocation(
      {String location, Directions direction}) {
    switch (direction) {
      case Directions.down:
        {
          //is south wall up?
          if (!myLabyrinth[location].upWallIsUp) {
            return true;
          } else {
            return false;
          }
        }
        break;
      case Directions.up:
        {
          //is north wall up?
          if (!myLabyrinth[location].downWallIsUp) {
            return true;
          } else {
            return false;
          }
        }
        break;
      case Directions.right:
        {
          if (!myLabyrinth[location].rightWallIsUp) {
            return true;
          } else {
            return false;
          }
        }
        break;
      case Directions.left:
        {
          if (!myLabyrinth[location].leftWallIsUp) {
            return true;
          } else {
            return false;
          }
        }
    }
    return true;
  }

  bool moveThisPixieInThisDirection(Pixie pixie, Directions direction) {
    //print('moveThisPixieInThisDirection ${pixie.location}');
    switch (direction) {
      case Directions.down:
        {
          //is south wall up?
          if (!myLabyrinth[pixie.location].upWallIsUp) {
            return movePixieToXY(pixie, pixie.x, pixie.y + 1);
          } else {
            return false;
          }
        }
        break;
      case Directions.up:
        {
          //is north wall up?
          if (!myLabyrinth[pixie.location].downWallIsUp) {
            return movePixieToXY(pixie, pixie.x, pixie.y - 1);
          } else {
            return false;
          }
        }
        break;
      case Directions.right:
        {
          if (!myLabyrinth[pixie.location].rightWallIsUp) {
            return movePixieToXY(pixie, pixie.x + 1, pixie.y);
          } else {
            return false;
          }
        }
        break;
      case Directions.left:
        {
          if (!myLabyrinth[pixie.location].leftWallIsUp) {
            return movePixieToXY(pixie, pixie.x - 1, pixie.y);
          } else {
            return false;
          }
        }
    }
    return true;
  }

  bool moveThisSpriteInThisDirection(Pixie sprite, Directions direction) {
    if (moveThisPixieInThisDirection(sprite, direction)) {
      if (sprite.ilk != Ilk.minotaur) {
        bossGoHandleAnyLambAtYourLocation(boss: player);
      } else {
        bossGoHandleAnyLambAtYourLocation(boss: sprite);
      }

      sprite.direction = direction;
      return true;
    } else {
      if (sprite.ilk == Ilk.player) {
        //must have hit a wall
        player.delayComputerMove = false;
      }
    }

    return false;
  }

  bool attemptToMoveThisPixieToAnAdjacentRoom(
      {Pixie pix, Directions direction}) {
    bool moved = false;
    int numberOfMoveTries = 0;
    if (direction == null) {
      direction = randomDirection(location: pix.location);
    }

    while (numberOfMoveTries < 8) {
      moved = moveThisSpriteInThisDirection(pix, direction);

      if (moved) return moved;
      if (pix.ilk == Ilk.lamb) {
        direction = nextDirection(direction);
      } else {
        return false;
      }
      numberOfMoveTries++;
    }
    return moved;
  }

  bool tryToMovePlayerToXY(Pixie pix, int x, int y) {
    if (x == (pix.x + 1) && y == pix.y) {
      return moveThisSpriteInThisDirection(pix, Directions.right);
    } else if (x == (pix.x - 1) && y == pix.y) {
      return moveThisSpriteInThisDirection(pix, Directions.left);
    } else if (x == (pix.x) && y == (pix.y + 1)) {
      return moveThisSpriteInThisDirection(pix, Directions.down);
    } else if (x == (pix.x) && y == (pix.y - 1)) {
      return moveThisSpriteInThisDirection(pix, Directions.up);
    }

    return false;
  }

  Directions directionFromBossToPixieIs({Pixie boss, Pixie pixie}) {
    if (boss == null || pixie == null) return null;
    if (pixie.y == boss.y && pixie.x < boss.x) {
      return Directions.left;
    }
    if (pixie.y == boss.y && pixie.x > boss.x) {
      return Directions.right;
    }
    if (pixie.x == boss.x && pixie.y < boss.y) {
      return Directions.up;
    }
    if (pixie.x == boss.x && pixie.y > boss.y) {
      return Directions.down;
    }
    return null;
  }

  bool thereExistsADirectPathFromBossToPixie(
      {Map boss, Map pixie, Directions direction}) {
    switch (direction) {
      case Directions.up:
        if (boss['y'] == pixie['y']) return true;
        if (!myLabyrinth['b_${boss['x']}_${boss['y']}'].downWallIsUp) {
          boss['y'] = boss['y'] - 1;
          return thereExistsADirectPathFromBossToPixie(
              boss: boss, pixie: pixie, direction: direction);
        } else {
          return false;
        }
        break;
      case Directions.down:
        if (boss['y'] == pixie['y']) return true;
        if (!myLabyrinth['b_${boss['x']}_${boss['y']}'].upWallIsUp) {
          boss['y'] = boss['y'] + 1;
          return thereExistsADirectPathFromBossToPixie(
              boss: boss, pixie: pixie, direction: direction);
        }
        break;
      case Directions.left:
        if (boss['x'] == pixie['x']) return true;
        if (!myLabyrinth['b_${boss['x']}_${boss['y']}'].leftWallIsUp) {
          boss['x'] = boss['x'] - 1;
          return thereExistsADirectPathFromBossToPixie(
              boss: boss, pixie: pixie, direction: direction);
        }
        break;
      case Directions.right:
        if (boss['x'] == pixie['x']) return true;
        if (!myLabyrinth['b_${boss['x']}_${boss['y']}'].rightWallIsUp) {
          boss['x'] = boss['x'] + 1;
          return thereExistsADirectPathFromBossToPixie(
              boss: boss, pixie: pixie, direction: direction);
        }
        break;
      default:
        break;
    }
    return false;
  }

  bool noWallsFromBossToPixie({Pixie boss, Pixie pixie, Directions direction}) {
    if (direction == null) {
      direction = directionFromBossToPixieIs(boss: boss, pixie: pixie);
    }

    return thereExistsADirectPathFromBossToPixie(
        boss: {'x': boss.x, 'y': boss.y},
        pixie: {'x': pixie.x, 'y': pixie.y},
        direction: direction);
  }

  Directions whichDirectionTheBossCanLookToSeeThePixie(
      {Pixie boss, Pixie pixie}) {
    if (boss == null || pixie == null) return null;
    Directions direction = directionFromBossToPixieIs(boss: boss, pixie: pixie);

    if (direction == null) return null;

    if (noWallsFromBossToPixie(
        boss: boss, pixie: pixie, direction: direction)) {
      return direction;
    }
    return null;
  }

  bool canThisBossSeeThisPixie({Pixie boss, Pixie pixie}) {
    if (boss.x == pixie.x && boss.y == pixie.y) return true;
    if (boss.ilk == Ilk.player && difficulty == GameDifficulty.normal) {
      return true;
    }
    if (whichDirectionTheBossCanLookToSeeThePixie(boss: boss, pixie: pixie) !=
        null) {
      return true;
    }
    if (thisPixieIsJustAroundTheCornerFromThisBoss(
        boss: player, pixie: pixie)) {
      return true;
    }
    return false;
  }

  bool thisPixieIsJustAroundTheCornerFromThisBoss({Pixie boss, Pixie pixie}) {
    if (boss.x == pixie.x - 1 && boss.y == pixie.y + 1) {
      if (!myLabyrinth['b_${boss.x}_${boss.y}'].rightWallIsUp &&
          !myLabyrinth['b_${pixie.x}_${pixie.y}'].upWallIsUp) {
        return true;
      }
      if (!myLabyrinth['b_${boss.x}_${boss.y}'].downWallIsUp &&
          !myLabyrinth['b_${pixie.x}_${pixie.y}'].leftWallIsUp) {
        return true;
      }
    }
    if (boss.x == pixie.x - 1 && boss.y == pixie.y - 1) {
      if (!myLabyrinth['b_${boss.x}_${boss.y}'].rightWallIsUp &&
          !myLabyrinth['b_${pixie.x}_${pixie.y}'].downWallIsUp) {
        return true;
      }
      if (!myLabyrinth['b_${boss.x}_${boss.y}'].upWallIsUp &&
          !myLabyrinth['b_${pixie.x}_${pixie.y}'].leftWallIsUp) {
        return true;
      }
    }
    //boss is to the right of pixie
    if (boss.x == pixie.x + 1 && boss.y == pixie.y + 1) {
      if (!myLabyrinth['b_${boss.x}_${boss.y}'].leftWallIsUp &&
          !myLabyrinth['b_${pixie.x}_${pixie.y}'].upWallIsUp) {
        return true;
      }
      if (!myLabyrinth['b_${boss.x}_${boss.y}'].downWallIsUp &&
          !myLabyrinth['b_${pixie.x}_${pixie.y}'].rightWallIsUp) {
        return true;
      }
    }
    if (boss.x == pixie.x + 1 && boss.y == pixie.y - 1) {
      if (!myLabyrinth['b_${boss.x}_${boss.y}'].leftWallIsUp &&
          !myLabyrinth['b_${pixie.x}_${pixie.y}'].downWallIsUp) {
        return true;
      }
      if (!myLabyrinth['b_${boss.x}_${boss.y}'].upWallIsUp &&
          !myLabyrinth['b_${pixie.x}_${pixie.y}'].rightWallIsUp) {
        return true;
      }
    }

    return false;
  }

  void setPixiesVisibility() {
    lambs.forEach((el) {
      if (el.condition == Condition.alive) {
        if (canThisBossSeeThisPixie(boss: player, pixie: el)) {
          el.isVisible = true;
        } else {
          el.isVisible = false;
        }
      }
    });
    if (canThisBossSeeThisPixie(boss: player, pixie: minotaur)) {
      minotaur.isVisible = true;
    } else {
      minotaur.isVisible = false;
    }
  }

  ///
  /// if the boss can see another pixie  return the direction to that pixie,
  /// else return direction passed in
  ///
  Directions changeDirectionFromBossToNearestLamb(
      {Pixie boss, Directions direction}) {
    Pixie temp;

    var seenPixies = <Pixie>[];

    // check for seeing player first
    var playerDirection = whichDirectionTheBossCanLookToSeeThePixie(
        boss: minotaur, pixie: player);
    if (playerDirection != null) {
      return playerDirection;
    }
    if (difficulty == GameDifficulty.tough && player.savedLambs > maxRow / 2) {
      return direction;
    }

    var xlesslambs = lambs.where((lamb) {
      return (lamb.y == boss.y &&
          lamb.x < boss.x &&
          lamb.condition == Condition.alive);
    });
    if (xlesslambs.isNotEmpty) {
      temp = xlesslambs.reduce((curr, next) => curr.x > next.x ? curr : next);

      if (temp != null &&
          whichDirectionTheBossCanLookToSeeThePixie(
                  boss: minotaur, pixie: temp) !=
              null) {
        seenPixies.add(temp);
      }
    }

    temp = null;
    var xmorelambs = lambs.where((lamb) {
      return (lamb.y == boss.y &&
          lamb.x > boss.x &&
          lamb.condition == Condition.alive);
    });
    if (xmorelambs.isNotEmpty) {
      temp = xmorelambs.reduce((curr, next) => curr.x < next.x ? curr : next);

      if (temp != null &&
          whichDirectionTheBossCanLookToSeeThePixie(
                  boss: minotaur, pixie: temp) !=
              null) {
        seenPixies.add(temp);
      }
    }
    temp = null;
    var ylesslambs = lambs.where((lamb) {
      return (lamb.x == boss.x &&
          lamb.y < boss.y &&
          lamb.condition == Condition.alive);
    });
    if (ylesslambs.isNotEmpty) {
      temp = ylesslambs.reduce((curr, next) => curr.y > next.y ? curr : next);

      if (temp != null &&
          whichDirectionTheBossCanLookToSeeThePixie(
                  boss: minotaur, pixie: temp) !=
              null) {
        seenPixies.add(temp);
      }
    }
    temp = null;
    var ymorelambs = lambs.where((lamb) {
      return (lamb.x == boss.x &&
          lamb.y > boss.y &&
          lamb.condition == Condition.alive);
    });
    if (ymorelambs.isNotEmpty) {
      temp = ymorelambs.reduce((curr, next) => curr.y < next.y ? curr : next);

      if (temp != null &&
          whichDirectionTheBossCanLookToSeeThePixie(
                  boss: minotaur, pixie: temp) !=
              null) {
        seenPixies.add(temp);
      }
    }
    if (seenPixies.isNotEmpty) {
      direction = whichDirectionTheBossCanLookToSeeThePixie(
          boss: minotaur, pixie: seenPixies.first);
    }
    //  no lamb seen just return

    return direction;
  }

  bool roomIsADeadEnd({String room}) {
    var walls = 0;
    if (myLabyrinth[room].downWallIsUp) walls++;
    if (myLabyrinth[room].upWallIsUp) walls++;
    if (myLabyrinth[room].leftWallIsUp) walls++;
    if (myLabyrinth[room].rightWallIsUp) walls++;
    return walls > 2;
  }

  bool roomIsAnIntersection({String room}) {
    if ((!myLabyrinth[room].leftWallIsUp || !myLabyrinth[room].rightWallIsUp) &&
        (!myLabyrinth[room].downWallIsUp || !myLabyrinth[room].upWallIsUp)) {
      return true;
    }

    return false;
  }

  bool thereIsADeadEndFromLocationInDirection(
      {Map location, Directions direction}) {
    if (!aPixieCanMoveDirectionFromLocation(
        location: 'b_${location['x']}_${location['y']}',
        direction: direction)) {
      return true;
    }

    switch (direction) {
      case Directions.up:
        location['y'] = location['y'] - 1;
        break;
      case Directions.down:
        location['y'] = location['y'] + 1;
        break;
      case Directions.left:
        location['x'] = location['x'] - 1;
        break;
      case Directions.right:
        location['x'] = location['x'] + 1;
        break;
      default:
        break;
    }
    if (roomIsAnIntersection(room: 'b_${location['x']}_${location['y']}')) {
      return false;
    }
    if (roomIsADeadEnd(room: 'b_${location['x']}_${location['y']}')) {
      return true;
    }
    return thereIsADeadEndFromLocationInDirection(
        location: {'x': location['x'], 'y': location['y']},
        direction: direction);
  }

  bool pixieSeesADeadEnd({Map pixie, Directions direction}) {
    switch (direction) {
      case Directions.up:
        var y = pixie['y']; // - 1;
        if (y == 0) return false;
        if (roomIsADeadEnd(room: 'b_${pixie['x']}_$y')) {
          return true;
        }
        break;
      case Directions.down:
        var y = pixie['y']; // + 1;
        if (y == getMaxCol() + 1) return false;
        if (roomIsADeadEnd(room: 'b_${pixie['x']}_$y')) {
          return true;
        }
        break;
      case Directions.left:
        var x = pixie['x']; // - 1;
        if (x == 0) return false;
        if (roomIsADeadEnd(room: 'b_${x}_${pixie['y']}')) {
          return true;
        }
        break;
      case Directions.right:
        var x = pixie['x']; // + 1;
        if (x == getMaxRow() + 1) return false;
        if (roomIsADeadEnd(room: 'b_${x}_${pixie['y']}')) {
          return true;
        }
        break;
    }
    return false;
  }

  bool bossJustCameFromThatDirection({Pixie boss, Directions direction}) {
    switch (direction) {
      case Directions.up:
        return boss.lastLocation == 'b_${boss.x}_${boss.y - 1}';
        break;
      case Directions.down:
        return boss.lastLocation == 'b_${boss.x}_${boss.y + 1}';
        break;
      case Directions.left:
        return boss.lastLocation == 'b_${boss.x - 1}_${boss.y}';
        break;
      case Directions.right:
        return boss.lastLocation == 'b_${boss.x + 1}_${boss.y}';
        break;
      default:
        break;
    }
    return false;
  }

  int markMinotaursPath({String location}) {
    print('markMinotaursPath $location');
    myLabyrinth[location].minotaursPath = ++Room.badGuyHasMovedThisManyTimes;
    return myLabyrinth[location].minotaursPath;
  }

  bool moveMinotaur() {
    bool minotaurHasNotMovedAtLeastOnceThisTurn() {
      return minotaur.getMovesLeft() == getMaxRow();
    }

    bool minotaurHasMovedAtLeastOnceThisTurn() {
      return minotaur.getMovesLeft() < getMaxRow();
    }
    // the minotaur moves in one direction until it eats a pixie,
    // runs into a wall or stops at an intersection.
    // First it charges the nearest pixie it sees (it cannot see around corners
    // or through walls)
    // unless the maze is in in Tough mode in which case the goblin
    // will ignore the pixies if the player has freed more pixies than it
    // has captured.
    // If no pixie is targeted it moves at random until it reaches a wall
    // or an intersection (there is a 50% chance it stops at an intersection
    // unless it can now see a lamb when it will stop)

    if (_gameIsOver) {
      return false;
    }
    bool bossCannotSeeALamb = true;
    Directions direction;

    direction = changeDirectionFromBossToNearestLamb(
        boss: minotaur, direction: direction);
    if (direction != null) {
      bossCannotSeeALamb = false;
    } else {
      direction = randomDirection(location: minotaur.location);
    }

    minotaur.setMovesLeft(getMaxRow());
    int tries = 0;
    bool triedFirst = false;
    while (minotaur.getMovesLeft() > 0) {
      if (tries++ > 100) {
        break;
      }
      if (bossCannotSeeALamb) {
        if (minotaurHasNotMovedAtLeastOnceThisTurn()) {
          if (triedFirst) {
            direction = nextDirection(direction);
          } else {
            triedFirst = true;
          }
          if (bossJustCameFromThatDirection(
              boss: minotaur, direction: direction)) {
            minotaur.lastLocation = '';

            continue; //try another direction
          }

          if (thereIsADeadEndFromLocationInDirection(
              location: {'x': minotaur.x, 'y': minotaur.y},
              direction: direction)) {
            continue; //try another direction
          }
        }
      }

      if (bossCannotSeeALamb &&
          thereIsADeadEndFromLocationInDirection(
              location: {'x': minotaur.x, 'y': minotaur.y},
              direction: direction)) {
        minotaur.setMovesLeft(0);
        continue; //try another direction
      }

      if (attemptToMoveThisPixieToAnAdjacentRoom(
          pix: minotaur, direction: direction)) {
        markMinotaursPath(location: minotaur.location);
        // 50% chance to stop on any intersection
        if (bossCannotSeeALamb && minotaurHasMovedAtLeastOnceThisTurn()) {
          if (roomIsAnIntersection(room: minotaur.location)) {
            if (Utils.rand.nextInt(2) == 0) {
              minotaur.setMovesLeft(0);
              continue;
            }
            //check to see if a lamb can be seen from here
            if (direction !=
                changeDirectionFromBossToNearestLamb(
                    boss: minotaur, direction: direction)) {
              minotaur.setMovesLeft(0);

              ///remember the dir the lamb was seen and use it on next turn
              ///to chase the lamb -- or not, that might make to game too hard
              continue;
            }
          }
        }
      } else {
        // if the minotaur moved and then failed to move then it has hit a wall so then end its turn
        if (minotaurHasMovedAtLeastOnceThisTurn()) {
          minotaur.setMovesLeft(0);
        }
      }
    }
    _whosTurnIsIt = Ilk.lamb;
    return minotaurHasMovedAtLeastOnceThisTurn();
  }

  Directions randomDirection({String location}) {
    //find the dir of the accessible rooms with the lowest minotaurPath
    var index = Utils.rand.nextInt(Directions.values.length);
    var finalDir = Directions.values[index]; //just a default direction

    if (location != minotaur.location) {
      // non-minotaurs do not need to check MinotaurPath
      return finalDir;
    }
    var least = Room.badGuyHasMovedThisManyTimes;

    var dirs = <Directions>[];
    Directions.values.forEach((dir) {
      dirs.add(Directions.values[index]);
      index = (index + 1) % Directions.values.length;
    });

    dirs.forEach((dirx) {
      if (aPixieCanMoveDirectionFromLocation(
          direction: dirx, location: location)) {
        var newLoaction =
            whatLocationIsFoundByMovingInThisDirectionFromThisPixiesLocation(
                direction: dirx, pixie: minotaur);

        if (myLabyrinth[newLoaction].minotaursPath < least) {
          least = myLabyrinth[newLoaction].minotaursPath;
          finalDir = dirx;
        }
      }
    });

    return finalDir;
  }

  Directions nextDirection(Directions direction) {
    return Directions.values[(direction.index + 1) % Directions.values.length];
  }

  bool moveLambs() {
    if (gameIsOver()) return gameIsOver();
    lambs.forEach((lamb) {
      if (lamb.condition == Condition.alive) {
        attemptToMoveThisPixieToAnAdjacentRoom(pix: lamb);
        lamb.setMovesLeft(1);
      } else if (lamb.condition == Condition.freed) {
        lamb.setMovesLeft(0);
      } else {
        lamb.setMovesLeft(0);
      }
    });
    var anyLeftAlive = lambs.any((lamb) => lamb.condition == Condition.alive);
    setWhosTurnItIs(Ilk.player);
    if (!anyLeftAlive) {
      return endGame();
    }
    return gameIsOver();
  }

  bool endGame() {
    setGameIsOver(true);

    return gameIsOver();
  }

  Next aNext(x, y) {
    var aNext = Next();

    if ((x - 1) > 0) {
      if (myLabyrinth['b_${x - 1}_$y'].visited == false) {
        aNext.one = 'b_${x - 1}_$y';
        aNext.total = aNext.total + 1;
      }
    }
    if ((x + 1) <= _maxCol) {
      if (myLabyrinth['b_${x + 1}_$y'].visited == false) {
        aNext.two = 'b_${x + 1}_$y';
        aNext.total++;
      }
    }
    if ((y - 1) > 0) {
      if (myLabyrinth['b_${x}_${y - 1}'].visited == false) {
        aNext.three = 'b_${x}_${y - 1}';
        aNext.total++;
      }
    }
    if ((y + 1) <= maxRow) {
      if (myLabyrinth['b_${x}_${y + 1}'].visited == false) {
        aNext.four = 'b_${x}_${y + 1}';
        aNext.total++;
      }
    }
    return aNext;
  }

  // return a string giving the room to carve to; b_x_y
  // but does not do the carving
  String makePassage(x, y) {
    Next aNext = Next();

    var dir = '';
    if ((x - 1) > 0 && (myLabyrinth['b_${x}_$y']?.leftWallIsUp != null)) {
      aNext.one = (myLabyrinth['b_${x}_$y'].setid -
              myLabyrinth['b_${(x - 1)}_$y'].setid)
          .abs()
          .toString();
    }
    if (int.tryParse(aNext.one) > int.tryParse(aNext.max)) {
      aNext.max = aNext.one;
      dir = 'b_${(x - 1)}_$y';
    }
    if ((x + 1) <= _maxCol &&
        (myLabyrinth['b_${x}_$y']?.rightWallIsUp != null)) {
      aNext.two = (myLabyrinth['b_${x}_$y'].setid -
              myLabyrinth['b_${(x + 1)}_$y'].setid)
          .abs()
          .toString();
    }
    if (int.tryParse(aNext.two) > int.tryParse(aNext.max)) {
      aNext.max = aNext.two;
      dir = 'b_${(x + 1)}_$y';
    }
    if ((y - 1) > 0 && myLabyrinth['b_${x}_$y']?.downWallIsUp != null) {
      aNext.three = (myLabyrinth['b_${x}_$y'].setid -
              myLabyrinth['b_${x}_${(y - 1)}'].setid)
          .abs()
          .toString();
    }
    if (int.tryParse(aNext.three) > int.tryParse(aNext.max)) {
      aNext.max = aNext.three;
      dir = 'b_${x}_${(y - 1)}';
    }
    if ((y + 1) <= maxRow && (myLabyrinth['b_${x}_$y']?.upWallIsUp != null)) {
      aNext.four = (myLabyrinth['b_${x}_$y'].setid -
              myLabyrinth['b_${x}_${(y + 1)}'].setid)
          .abs()
          .toString();
    }
    //return a string giving the room to join to from room x,y
    if (int.tryParse(aNext.four) > int.tryParse(aNext.max)) {
      aNext.max = aNext.four;
      dir = 'b_${x}_${(y + 1)}';
    }
    return dir;
  }

  String getNext(Next next) {
    //returns a string with the name of the next room
    var num = Math.Random.secure().nextInt(4) + 1;
    var total = 0;
    while (total < 4) {
      if (num == 1) {
        if (next.one != '0') {
          return next.one;
        } else {
          num++;
          total++;
        }
      }
      if (num == 2) {
        if (next.two != '0') {
          return next.two;
        } else {
          num++;
          total++;
        }
      }
      if (num == 3) {
        if (next.three != '0') {
          return next.three;
        } else {
          num++;
          total++;
        }
      }
      if (num == 4) {
        if (next.four != '0') {
          return next.four;
        } else {
          num = 1;
          total++;
        }
      }
    }
    throw Exception('NO next found');
  }

  joinRooms(String room1, String room2) {
    if (myLabyrinth[room1].x == myLabyrinth[room2].x - 1) {
      myLabyrinth[room1].rightWallIsUp = false;
      myLabyrinth[room2].leftWallIsUp = false;
      myLabyrinth[room2].visited = true;
    }
    if (myLabyrinth[room1].x == myLabyrinth[room2].x + 1) {
      myLabyrinth[room1].leftWallIsUp = false;
      myLabyrinth[room2].rightWallIsUp = false;
      myLabyrinth[room2].visited = true;
    }
    if (myLabyrinth[room1].y == myLabyrinth[room2].y + 1) {
      myLabyrinth[room1].downWallIsUp = false;
      myLabyrinth[room2].upWallIsUp = false;
      myLabyrinth[room2].visited = true;
    }
    if (myLabyrinth[room1].y == myLabyrinth[room2].y - 1) {
      myLabyrinth[room1].upWallIsUp = false;
      myLabyrinth[room2].downWallIsUp = false;
      myLabyrinth[room2].visited = true;
    }
  }

  //carve the labyrinth
  void carveLabyrinth() {
    // NOW USE DFS algo
    // from mazeworks.com,  DSF Depth First Search algorithm for making mazes
    //  create a CellStack (LIFO) to hold a list of cell locations
    //  use Global myStack
    //  set TotalCells = number of cells in grid
    //  use Global myLabyrinth.numberOfRooms;
    //  initial cell
    //  choose a cell at random and call it CurrentCell
    //  for MAXROW<12 choose x/y = 4 or 5 for initial cell, ie 4 possible cells,
    //  for larger labyrinths choose size/2-1 to size/2+1, ie 16 possible cells

    numberOfRooms = maxRow * _maxCol;
    myStack.clear();
    specialCells.clear();

    var half = (maxRow / 2).floor();
    var x = 0;
    var y = 0;
    var inc = 2;
    if (maxRow > 10) {
      half = half - 1;
      inc = inc + 2;
    }
    x = half + Math.Random.secure().nextInt(inc);
    y = half + Math.Random.secure().nextInt(inc);

    var currentCell = 'b_${x}_$y';

    var visitedCells = 0;
    var myNext;
    var next;
    var notfoundfirstedge = true;

    myLabyrinth[currentCell].x = x;
    myLabyrinth[currentCell].y = y;

    myLabyrinth[currentCell].visited = true;
    myLabyrinth[currentCell].setid = ++visitedCells;
    specialCells.add(currentCell);

    while (visitedCells < numberOfRooms) {
      //find all neighbors of CurrentCell with all walls intact
      x = myLabyrinth[currentCell].x;
      y = myLabyrinth[currentCell].y;
      if (notfoundfirstedge &&
          (x == 1 || x == _maxCol || y == 1 || y == maxRow)) {
        specialCells.add(currentCell);

        notfoundfirstedge = false;
        firstedge = currentCell;
      }
      myNext = aNext(x, y);
      if (myNext.total > 0) {
        //choose one at random
        next = getNext(myNext);
        //knock down the wall between it and CurrentCell
        joinRooms(currentCell, next);
        //push CurrentCell location on the CellStack
        myStack.add(currentCell);
        //make the new cell CurrentCell
        currentCell = next;
        myLabyrinth[currentCell].setid = ++visitedCells;
      } else {
        //every dead end is a special square
        specialCells.add(currentCell);
        //pop the most recent cell entry off the CellStack
        //and make it CurrentCell
        currentCell = myStack.removeLast();
      }
    } // end while
    // get last cell visited -- it is myNext
    // specialcells.add(next);
    // get the number of walls to knock down, based on MAXROWS
    makeloops();

    //place minotaur, player and youths
    placeMinotaur();
    placePlayer();
    placeLambs();
  } // END FUNCTION ***********************

  Pixie placePixie({bool mustBeNearCenter}) {
    var x = 0;
    var y = 0;
    var rand = Math.Random.secure();
    if (mustBeNearCenter == true) {
      var inc = 2;
      var half = (maxRow / 2).floor();
      if (maxRow > 10) {
        half = half - 1;
        inc = inc + 2;
      }
      x = half + rand.nextInt(inc);
      y = half + rand.nextInt(inc);
    } else {
      x = 1 + rand.nextInt(maxRow - 1);
      y = 1 + rand.nextInt(_maxCol - 1);
    }
    var p = Pixie(Ilk.lamb);
    p.location = 'b_${x}_$y';
    p.lastLocation = 'b_${x}_$y';
    p.x = x;
    p.y = y;
    p.lastX = x;
    p.lastY = y;
    return p;
  }

  void placeMinotaur() {
    var loc = placePixie(mustBeNearCenter: true);
    while (player.location == loc.location) {
      loc = placePixie(mustBeNearCenter: true);
    }
    loc.ilk = Ilk.minotaur;
    minotaur = loc;
    minotaur.emoji = '👺';
    minotaur.preferredColor = Colors.red[800].value;
    minotaur.setMovesLeft(getMaxRow());
  }

  void placePlayer() {
    var loc = placePixie(mustBeNearCenter: false);
    while (minotaur.location == loc.location) {
      loc = placePixie(mustBeNearCenter: false);
    }
    loc.ilk = Ilk.player;
    player = loc;
    player.emoji = '👧';
    player.preferredColor = Colors.orange[800].value;
    player.setMovesLeft(getPlayerMoves());
    player.lostLambs = 0;
    player.savedLambs = 0;
  }

  bool closeToMinotaur(Pixie pix) {
    if ((minotaur.x - pix.x).abs() < 2 || (minotaur.y - pix.y).abs() < 2) {
      return true;
    }
    return false;
  }

  bool hasLamb(String loc) {
    var hasLamb = false;
    lambs.forEach((lamb) {
      if (lamb.location == loc) {
        hasLamb = true;
      }
    });
    return hasLamb;
  }

  void setLambEmoji(Pixie lamb, int i) {
    switch (i) {
      case 0:
        lamb.emoji = '🐝';
        break;
      case 1:
        lamb.emoji = '🐇';
        break;
      case 2:
        lamb.emoji = '🐁';
        break;
      case 3:
        lamb.emoji = '🐖';
        break;
      case 4:
        lamb.emoji = '🐀';
        break;
      case 5:
        lamb.emoji = '🐞';
        break;
      case 6:
        lamb.emoji = '🐧';
        break;
      case 7:
        lamb.emoji = '🐐';
        break;
      case 8:
        lamb.emoji = '🐈';
        break;
      case 9:
        lamb.emoji = '🐎'; //
        break;
      case 10:
        lamb.emoji = '🐒';
        break;
      case 11:
        lamb.emoji = '🐑'; //
        break;
      case 12:
        lamb.emoji = '🐓';
        break;
      case 13:
        lamb.emoji = '🐘'; //
        break;
      default:
        lamb.emoji = '🦛';
        break;
    }
  }

  void placeLambs() {
    lambs.clear();
    for (int i = 0; i < maxRow; i++) {
      var lamb = placePixie(mustBeNearCenter: false);

      while (closeToMinotaur(lamb) ||
          minotaur.location == lamb.location ||
          player.location == lamb.location ||
          hasLamb(lamb.location)) {
        lamb = placePixie(mustBeNearCenter: false);
      }
      lamb.ilk = Ilk.lamb;
      setLambEmoji(lamb, i);

      lambs.add(lamb);
    }
  }

  void makeloops() {
    var numloops = (maxRow / 4).floor();
    //for each special room
    //check that there is an orthogonally adjacent square with a setid 9 apart
    //from the special squares setid
    //then knock down the wall between the special square
    //and the square with the greatest difference in setid values
    //from the special squares setid
    //then make the special square as used
    //if there is no appropriate square then move to the next special square
    //if you run out of candidate special squares
    //then loop again using any unused special squares without checking for
    //minimum setid differences
    var indx = 0;

    if (knockextrawall(myLabyrinth[specialCells[indx++]], true)) {
      numloops--;
    }
    if (knockextrawall(myLabyrinth[firstedge], true)) {
      numloops--;
    }
    var tmp = numloops;
    while (tmp > 0) {
      if (knockextrawall(myLabyrinth[specialCells[indx++]], true)) {
        numloops--;
      }
      tmp--;
    }
    indx = 1;
    var i = 0;
    while (numloops > 0 && i < specialCells.length) {
      if (knockextrawall(myLabyrinth[specialCells[indx++]], false)) {
        numloops--;
      }
      i++;
    }
  }

  knockextrawall(Room room, bool onlyIfLargeSetIdDifference) {
    var nextroom;
    if (room.spUsed == true) {
      return false;
    }
    if (onlyIfLargeSetIdDifference) {
      //knock down a wall if there is one with a large difference in setid
      //examine adjacent rooms for setid
      //find room2 - a non-joined room with the largest variance in setid
      nextroom = makePassage(room.x, room.y);
      if (nextroom.length > 1 &&
          (myLabyrinth[nextroom].setid - room.setid).abs() > 9) {
        joinRooms('b_${room.x}_${room.y}', nextroom);
        room.spUsed = true;
        return true;
      } else {
        return false;
      }
    } else {
      //knock down a wall regardless of setid variance
      nextroom = makePassage(room.x, room.y);
      if (nextroom.length > 1) {
        joinRooms('b_${room.x}_${room.y}', nextroom);
        room.spUsed = true;
        return true;
      }
      return false;
    }
  } //end func
}
