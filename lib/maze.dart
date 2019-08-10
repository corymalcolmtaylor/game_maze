import 'dart:math' as Math;
import 'Utils.dart';

class Next {
  String one = '0';
  String two = '0';
  String three = '0';
  String four = '0';
  var total = 0;
  String max = '0';
}

class Room {
  var x = 0;
  var y = 0;
  var left = true;
  var right = true;
  var down = true;
  var up = true;
  var dir = '';
  var visited = false;
  var setid = 0;
  bool spUsed = false;
}

enum Ilk { player, minotaur, lamb }
enum Directions { up, down, right, left }
enum Condition { alive, dead, freed }

class Pixie {
  Pixie(this.ilk);
  var key = Utils.createCryptoRandomString();
  var location = '';
  var lastLocation = '';
  var movesLeft = 1;
  var x = 0;
  var y = 0;
  var lastX = 0;
  var lastY = 0;
  var recentlyMoved = false;
  var ilk = Ilk.player;
  var condition = Condition.alive;
  var savedLambs = 0;
  var lostLambs = 0;
  var emoji = '';
  Directions newDirection;
  var follow = false;
  Directions direction;
}

class Maze {
  int _maxRow;
  int _maxCol;
  bool gameIsOver = false;
  var rand = Math.Random.secure();

  int get maxRow {
    return _maxRow;
  }

  int get maxCol {
    return _maxCol;
  }

  set maxRow(int x) {
    _maxRow = x;
    _maxCol = x;
  }

  var numberOfRooms = 0;
  final playerMoves = 3;
  Map<String, Room> myLabyrinth = Map();
  //var myStack = [];
  List<String> myStack = [];
  //var specialcells =  <String>[];
  List<String> specialcells = [];
  var firstedge = '';
  var minotaur = Pixie(Ilk.minotaur);
  var player = Pixie(Ilk.player);
  var lambs = <Pixie>[];

  // create and initialize the labyrinth
  // squares named b_x_y eg b_1_3 for square A3 on a chess board
  // each square starts as its own set and has its own number; eg 1-64
  Maze(this._maxRow) {
    initMaze();
  } // END FUNCTION ***********************

  initMaze() {
    _maxCol = _maxRow;
    lambs.clear();
    myLabyrinth.clear();
    gameIsOver = false;
    for (var yloop = 1; yloop < _maxRow + 1; yloop++) {
      for (var xloop = 1; xloop < _maxCol + 1; xloop++) {
        myLabyrinth['b_${xloop}_$yloop'] = new Room();

        myLabyrinth['b_${xloop}_$yloop'].x = xloop;
        myLabyrinth['b_${xloop}_$yloop'].y = yloop;
      }
    }
  }

  bool bossGoHandleAnyLambsAtYourLocation({Pixie boss}) {
    if (boss.ilk == Ilk.lamb) return false;
    var handled = false;
    //if minotaur on player location then gameover
    if (minotaur.location == player.location) {
      boss.movesLeft = 0;
      return endGame();
    }
    lambs.forEach((el) {
      if (el.condition != Condition.alive) {
        return;
      }
      if (el.location == boss.location) {
        boss.movesLeft = 0;
        if (boss.ilk == Ilk.minotaur) {
          el.condition = Condition.dead;
          player.lostLambs++;
          print('killed a lamb');
        } else if (boss.ilk == Ilk.player) {
          el.condition = Condition.freed;
          player.savedLambs++;
          print('freed  a lamb');
        }
        handled = true;
      }
    });

    return handled;
  }

  bool seeLambInRoom(Room room) {
    var seen = false;
    lambs.forEach((el) {
      if (el.location == 'b_${room.x}_${room.y}') {
        seen = true;
      }
    });
    if (player.location == 'b_${room.x}_${room.y}') {
      seen = true;
    }
    return seen;
  }

  bool moveTo(Pixie pix, int x, int y) {
    final newloc = 'b_${x}_$y';
    if (pix.ilk == Ilk.lamb && minotaur.location == newloc) {
      return false;
    }

    if ((pix.ilk == Ilk.lamb || pix.ilk == Ilk.minotaur) &&
        pix.lastLocation == newloc) {
      pix.lastLocation = '';
      return false;
    }
    pix.lastLocation = 'b_${pix.x}_${pix.y}';
    pix.lastX = pix.x;
    pix.lastY = pix.y;
    pix.x = x;
    pix.y = y;
    pix.location = newloc;
    pix.movesLeft--;

    return true;
  }

  bool movePixie(Pixie pix, Directions dir) {
    switch (dir) {
      case Directions.down:
        {
          //is south wall up?
          if (!myLabyrinth[pix.location].down) {
            return moveTo(pix, pix.x, pix.y + 1);
          } else {
            return false;
          }
        }
        break;
      case Directions.up:
        {
          //is north wall up?
          if (!myLabyrinth[pix.location].up) {
            return moveTo(pix, pix.x, pix.y - 1);
          } else {
            return false;
          }
        }
        break;
      case Directions.right:
        {
          if (!myLabyrinth[pix.location].right) {
            return moveTo(pix, pix.x + 1, pix.y);
          } else {
            return false;
          }
        }
        break;
      case Directions.left:
        {
          if (!myLabyrinth[pix.location].left) {
            return moveTo(pix, pix.x - 1, pix.y);
          } else {
            return false;
          }
        }
    }
    return true;
  }

  bool moveSprite(Pixie pix, Directions direction) {
    if (movePixie(pix, direction)) {
      if (pix.ilk != Ilk.minotaur) {
        bossGoHandleAnyLambsAtYourLocation(boss: player);
      } else {
        print('pixie ${pix.emoji} moved ${direction} to ${pix.x} ${pix.y}');
        bossGoHandleAnyLambsAtYourLocation(boss: pix);
      }

      pix.direction = direction;
      return true;
    }
    //print('failed to move ${pix.emoji} ${direction}');
    return false;
  }

  bool attemptToMoveToAnAdjacentRoom({Pixie pix, Directions direction}) {
    bool moved = false;
    int numberOfMoveTries = 0;
    if (direction == null) {
      direction = randomDirection();
    }

    while (numberOfMoveTries < 8) {
      moved = moveSprite(pix, direction);

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
    print('try to move from  ${pix.x} ${pix.y} to $x $y');

    if (x == (pix.x + 1) && y == pix.y) {
      return moveSprite(pix, Directions.right);
    } else if (x == (pix.x - 1) && y == pix.y) {
      return moveSprite(pix, Directions.left);
    } else if (x == (pix.x) && y == (pix.y + 1)) {
      return moveSprite(pix, Directions.down);
    } else if (x == (pix.x) && y == (pix.y - 1)) {
      return moveSprite(pix, Directions.up);
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
    print('boss ${boss}');
    switch (direction) {
      case Directions.up:
        if (boss['y'] == pixie['y']) return true;
        if (!myLabyrinth['b_${boss['x']}_${boss['y']}'].up) {
          boss['y'] = boss['y'] - 1;
          return thereExistsADirectPathFromBossToPixie(
              boss: boss, pixie: pixie, direction: direction);
        } else {
          return false;
        }
        break;
      case Directions.down:
        if (boss['y'] == pixie['y']) return true;
        if (!myLabyrinth['b_${boss['x']}_${boss['y']}'].down) {
          boss['y'] = boss['y'] + 1;
          return thereExistsADirectPathFromBossToPixie(
              boss: boss, pixie: pixie, direction: direction);
        }
        break;
      case Directions.left:
        if (boss['x'] == pixie['x']) return true;
        if (!myLabyrinth['b_${boss['x']}_${boss['y']}'].left) {
          boss['x'] = boss['x'] - 1;
          return thereExistsADirectPathFromBossToPixie(
              boss: boss, pixie: pixie, direction: direction);
        }
        break;
      case Directions.right:
        if (boss['x'] == pixie['x']) return true;
        if (!myLabyrinth['b_${boss['x']}_${boss['y']}'].right) {
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
    print('noWallsFromBossToPixie 1');
    return thereExistsADirectPathFromBossToPixie(
        boss: {'x': boss.x, 'y': boss.y},
        pixie: {'x': pixie.x, 'y': pixie.y},
        direction: direction);
  }

  Directions whichDirectionTheBossCanLookToSeeThePixie(
      {Pixie boss, Pixie pixie}) {
    if (boss == null || pixie == null) return null;
    Directions direction = directionFromBossToPixieIs(boss: boss, pixie: pixie);
    print('whichDirectionTheBossCanLookToSeeThePixie 1  ${direction}');
    if (direction == null) return null;
    print('whichDirectionTheBossCanLookToSeeThePixie 1b');
    if (noWallsFromBossToPixie(
        boss: boss, pixie: pixie, direction: direction)) {
      print('whichDirectionTheBossCanLookToSeeThePixie 2  ${direction}');
      return direction;
    }
    return null;
  }

  ///
  /// if the boss can see another pixie  return the direction to that pixie,
  /// else return direction
  ///
  Directions changeDirectionFromBossToNearestLamb(
      {Pixie boss, Directions direction}) {
    Pixie temp;

    var seenPixies = <Pixie>[];

    // check for seeing player first
    var playerDirection = whichDirectionTheBossCanLookToSeeThePixie(
        boss: minotaur, pixie: player);
    if (playerDirection != null) {
      print('spotted player');
      return playerDirection;
    }

    var xlesslambs = lambs.where((lamb) {
      return (lamb.y == boss.y &&
          lamb.x < boss.x &&
          lamb.condition == Condition.alive);
    });
    if (xlesslambs.isNotEmpty) {
      temp = xlesslambs.reduce((curr, next) => curr.x > next.x ? curr : next);
      print('xlesslambs ${temp?.emoji ?? null}');
      if (temp != null &&
          whichDirectionTheBossCanLookToSeeThePixie(
                  boss: minotaur, pixie: temp) !=
              null) {
        print('add a pixie');
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
      print('xmorelambs ${temp?.emoji ?? null}');
      if (temp != null &&
          whichDirectionTheBossCanLookToSeeThePixie(
                  boss: minotaur, pixie: temp) !=
              null) {
        print('add a pixie');
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
      print('ylesslambs ${temp?.emoji ?? null}');
      if (temp != null &&
          whichDirectionTheBossCanLookToSeeThePixie(
                  boss: minotaur, pixie: temp) !=
              null) {
        print('add a pixie');
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
      print('ymorelambs ${temp?.emoji ?? null}');
      if (temp != null &&
          whichDirectionTheBossCanLookToSeeThePixie(
                  boss: minotaur, pixie: temp) !=
              null) {
        print('add a pixie');
        seenPixies.add(temp);
      }
    }
    if (seenPixies.isNotEmpty) {
      direction = whichDirectionTheBossCanLookToSeeThePixie(
          boss: minotaur, pixie: seenPixies.first);
      print('end change direction ${seenPixies.first ?? null}');
    }
    //  no lamb seen just return
    return direction;
  }

  bool roomIsADeadEnd({String room}) {
    var walls = 0;
    if (myLabyrinth[room].up) walls++;
    if (myLabyrinth[room].down) walls++;
    if (myLabyrinth[room].left) walls++;
    if (myLabyrinth[room].right) walls++;
    return walls > 2;
  }

  bool roomIsAnIntersection({String room}) {
    var walls = 0;
    if (myLabyrinth[room].up) walls++;
    if (myLabyrinth[room].down) walls++;
    if (myLabyrinth[room].left) walls++;
    if (myLabyrinth[room].right) walls++;
    return walls < 2;
  }

  bool pixieSeesADeadEnd({Pixie pixie, Directions direction}) {
    switch (direction) {
      case Directions.up:
        var y = pixie.y - 1;
        if (y == 0) return false;
        if (roomIsADeadEnd(room: 'b_${pixie.x}_${y}')) {
          return true;
        }
        break;
      case Directions.down:
        var y = pixie.y + 1;
        if (y == maxCol + 1) return false;
        if (roomIsADeadEnd(room: 'b_${pixie.x}_${y}')) {
          return true;
        }
        break;
      case Directions.left:
        var x = pixie.x - 1;
        if (x == 0) return false;
        if (roomIsADeadEnd(room: 'b_${x}_${pixie.y}')) {
          return true;
        }
        break;
      case Directions.right:
        var x = pixie.x + 1;
        if (x == maxRow + 1) return false;
        if (roomIsADeadEnd(room: 'b_${x}_${pixie.y}')) {
          return true;
        }
        break;
      default:
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

  bool moveMinotaur() {
    bool minotaurHasNotMovedAtLeastOnceThisTurn() {
      return minotaur.movesLeft == maxRow;
    }

    bool minotaurHasMovedAtLeastOnceThisTurn() {
      return minotaur.movesLeft < maxRow;
    }
    // the minotaur moves in one direction until it eats a lamb,
    // runs into a wall or stops at an intersection of halls
    // first it charges the nearest pixie it sees (it cannot see around corners or through walls)
    // if no pixie is targeted it moves at random until it reaches a wall or an intersection
    // (there is a 50% chance it stops at an intersection unless it can now see a lamb when it will stop)

    if (gameIsOver) {
      return false;
    }
    bool bossCannotSeeALamb = true;
    Directions direction;
    print('mino dir  ${direction}');
    direction = changeDirectionFromBossToNearestLamb(
        boss: minotaur, direction: direction);
    if (direction != null) {
      bossCannotSeeALamb = false;
      print('mino can see lamb and dir changed to  ${direction}');
    } else {
      print('mino cannot see lamb ');
    }

    minotaur.movesLeft = maxRow;
    while (minotaur.movesLeft > 0) {
      if (bossCannotSeeALamb) {
        if (minotaurHasNotMovedAtLeastOnceThisTurn()) {
          if (direction == null) {
            direction = randomDirection();
            print('mino got random dir');
          } else {
            direction = nextDirection(direction);
            print('mino got next  dir');
          }
        }
      }

      /** at the beginning of mino's turn: 
       * if mino can see a lamb charge it! endTurn(pix, newDirection, follow).
       * if there is a  "newDirection" set "dir" == newDirection
       * if !follow and "dir" leads to last square then randomly reset "dir" 
       * look in dir direction and if it sees a dead end randomly reset "dir"
       * MoveInDirection(pix, dir ){ //move one squre in direction "dir"
       * if mino is on an intersection !follow and can see a lamb in another direction 
       ** then stop and remember newDirection, set "follow" = true, endTurn(pix, newDirection, follow=true).
       * else if mino is on an intersection then 
       ** there is a 50% chance to -- change direction and remember a newDirection and endTurn(pix, newDirection, follow=false).
       * if hit a wall and can see a lamb endTurn(pix, newDirection, follow=true).
       * else if hit a wall and cannot see a lamb endTurn(pix, newDirection, follow=false).
       * else MoveInDirection(pix, dir )
       * 
       * }
      */
      if (bossJustCameFromThatDirection(boss: minotaur, direction: direction)) {
        minotaur.lastLocation = '';
        continue;
      }
      if (bossCannotSeeALamb &&
          pixieSeesADeadEnd(pixie: minotaur, direction: direction)) {
        print('sees a deadend ${direction}');
        if (minotaurHasMovedAtLeastOnceThisTurn()) {
          minotaur.movesLeft = 0;
        }
        continue;
      }
      //if not chasing a pixie, 50% chance to stop on any intersection
      if (bossCannotSeeALamb && minotaurHasMovedAtLeastOnceThisTurn()) {
        if (roomIsAnIntersection(room: 'b_${minotaur.x}_${minotaur.y}')) {
          if (rand.nextInt(2) == 0) {
            minotaur.movesLeft = 0;
            continue;
          }
        }
      }
      if (attemptToMoveToAnAdjacentRoom(pix: minotaur, direction: direction)) {
        print('mino moved to ${minotaur.x} ${minotaur.y}');
      } else {
        print('failed to move in ' + direction.toString());
        // if the minotaur moved and then failed to move then it has hit a wall so then end its turn
        if (minotaurHasMovedAtLeastOnceThisTurn()) {
          minotaur.movesLeft = 0;
        }
      }
    }

    return minotaurHasMovedAtLeastOnceThisTurn();
  }

  Directions randomDirection() {
    return Directions.values[rand.nextInt(Directions.values.length)];
  }

  Directions nextDirection(Directions direction) {
    return Directions.values[(direction.index + 1) % Directions.values.length];
  }

  bool moveLambs() {
    if (gameIsOver) return gameIsOver;
    lambs.forEach((lamb) {
      if (lamb.condition == Condition.alive) {
        attemptToMoveToAnAdjacentRoom(pix: lamb);
        lamb.movesLeft = 1;
      } else if (lamb.condition == Condition.freed) {
        lamb.movesLeft = 0;
      } else {
        lamb.movesLeft = 0;
      }
    });
    var anyLeftAlive = lambs.any((lamb) => lamb.condition == Condition.alive);
    if (!anyLeftAlive) {
      return endGame();
    }
    return gameIsOver;
  }

  bool endGame() {
    gameIsOver = true;

    print('end game');

    return gameIsOver;
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
    if ((y + 1) <= _maxRow) {
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
    if ((x - 1) > 0 && (myLabyrinth['b_${x}_$y']?.left != null)) {
      aNext.one = (myLabyrinth['b_${x}_$y'].setid -
              myLabyrinth['b_${(x - 1)}_$y'].setid)
          .abs()
          .toString();
    }
    if (int.tryParse(aNext.one) > int.tryParse(aNext.max)) {
      aNext.max = aNext.one;
      dir = 'b_${(x - 1)}_$y';
    }
    if ((x + 1) <= _maxCol && (myLabyrinth['b_${x}_$y']?.right != null)) {
      aNext.two = (myLabyrinth['b_${x}_$y'].setid -
              myLabyrinth['b_${(x + 1)}_$y'].setid)
          .abs()
          .toString();
    }
    if (int.tryParse(aNext.two) > int.tryParse(aNext.max)) {
      aNext.max = aNext.two;
      dir = 'b_${(x + 1)}_$y';
    }
    if ((y - 1) > 0 && myLabyrinth['b_${x}_$y']?.up != null) {
      aNext.three = (myLabyrinth['b_${x}_$y'].setid -
              myLabyrinth['b_${x}_${(y - 1)}'].setid)
          .abs()
          .toString();
    }
    if (int.tryParse(aNext.three) > int.tryParse(aNext.max)) {
      aNext.max = aNext.three;
      dir = 'b_${x}_${(y - 1)}';
    }
    if ((y + 1) <= _maxRow && (myLabyrinth['b_${x}_$y']?.down != null)) {
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
      myLabyrinth[room1].right = false;
      myLabyrinth[room2].left = false;
      myLabyrinth[room2].visited = true;
    }
    if (myLabyrinth[room1].x == myLabyrinth[room2].x + 1) {
      myLabyrinth[room1].left = false;
      myLabyrinth[room2].right = false;
      myLabyrinth[room2].visited = true;
    }
    if (myLabyrinth[room1].y == myLabyrinth[room2].y + 1) {
      myLabyrinth[room1].up = false;
      myLabyrinth[room2].down = false;
      myLabyrinth[room2].visited = true;
    }
    if (myLabyrinth[room1].y == myLabyrinth[room2].y - 1) {
      myLabyrinth[room1].down = false;
      myLabyrinth[room2].up = false;
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

    numberOfRooms = _maxRow * _maxCol;
    myStack.clear();
    specialcells.clear();

    var half = (_maxRow / 2).floor();
    var x = 0;
    var y = 0;
    var inc = 2;
    if (_maxRow > 10) {
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
    specialcells.add(currentCell);

    while (visitedCells < numberOfRooms) {
      //find all neighbors of CurrentCell with all walls intact
      x = myLabyrinth[currentCell].x;
      y = myLabyrinth[currentCell].y;
      if (notfoundfirstedge &&
          (x == 1 || x == _maxCol || y == 1 || y == _maxRow)) {
        specialcells.add(currentCell);

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
        specialcells.add(currentCell);
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
      var half = (_maxRow / 2).floor();
      if (_maxRow > 10) {
        half = half - 1;
        inc = inc + 2;
      }
      x = half + rand.nextInt(inc);
      y = half + rand.nextInt(inc);
    } else {
      x = 1 + rand.nextInt(_maxRow - 1);
      y = 1 + rand.nextInt(_maxCol - 1);
    }
    var p = Pixie(Ilk.lamb);
    p.location = 'b_${x}_$y';
    p.x = x;
    p.y = y;
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
    minotaur.movesLeft = maxRow;
  }

  void placePlayer() {
    var loc = placePixie(mustBeNearCenter: false);
    while (minotaur.location == loc.location) {
      loc = placePixie(mustBeNearCenter: false);
    }
    loc.ilk = Ilk.player;
    player = loc;
    player.emoji = '👧🏼';
    player.movesLeft = playerMoves;
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
        lamb.emoji = '🐷';
        break;
      case 4:
        lamb.emoji = '😸';
        break;
      case 5:
        lamb.emoji = '🦔';
        break;
      case 6:
        lamb.emoji = '🦆';
        break;
      case 7:
        lamb.emoji = '🐢';
        break;
      case 8:
        lamb.emoji = '🦋';
        break;
      case 9:
        lamb.emoji = '🐿';
        break;
      case 10:
        lamb.emoji = '🦜';
        break;
      case 11:
        lamb.emoji = '🦢';
        break;
      case 12:
        lamb.emoji = '🐓';
        break;
      case 13:
        lamb.emoji = '🦀';
        break;
      case 14:
        lamb.emoji = '🐌';
        break;
      case 15:
        lamb.emoji = '🦉';
        break;
      default:
        lamb.emoji = '🐛';
    }
  }

  void placeLambs() {
    lambs.clear();
    for (int i = 0; i < _maxRow; i++) {
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

  // makeloops : num loops = floor(MAXROW /4).floor + possible extra for treasure room
  void makeloops() {
    var numloops = (_maxRow / 4).floor();
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

    if (knockextrawall(myLabyrinth[specialcells[indx++]], true)) {
      numloops--;
    }
    if (knockextrawall(myLabyrinth[firstedge], true)) {
      numloops--;
    }
    var tmp = numloops;
    while (tmp > 0) {
      if (knockextrawall(myLabyrinth[specialcells[indx++]], true)) {
        numloops--;
      }
      tmp--;
    }
    indx = 1;
    var i = 0;
    while (numloops > 0 && i < specialcells.length) {
      if (knockextrawall(myLabyrinth[specialcells[indx++]], false)) {
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

/*
// create GLOBAL Constants  ***********************
var DEBUG = false;
var BLOCK = -99;//for use only in the functions click_On_Box and set_visible
var MAXHALL = 3;
var ROWCHANCE = 0.7;
var COLCHANCE = 0.34;
var MINDISTANCE = 3;// the minimum distance from any safe square to the treasure room     
var NUMLOOPS = 2;
var numLabs = 0;
var	VisitedCells = 1;
var BOX_SIZE = 40;
var MAXROW = 8;
var MAXCOL = 8;
var LABYRINTH_WIDTH = 0;
var FONTSIZE = '16px';
var BOOL = false;   //for use only in setSize to cause certain browsers to 
					//resize divs properly after one is hidden, in particular IE6 has a bug which
					//minimizes all divs after some are hidden
var GAMECOUNT = 0;
var BUTTON_WIDTH = '12px';
var BUTTON_HEIGHT = '12px';
var BEGAN_TURN = false;
var firstedge = null;
var numknocks = 0;
//var theStyle = mystyle; //  mystyle is inherited from index.html
//for use in animation functions only
var newx, newy, tnewx, tnewy, MYOLDBOX, OFLOATER, ONEWBOX, xplus, yplus;
var theStyle = 'Neverwinter';

function repaint(){

 
  setSize();
  draw_labyrinth();
  repaint_labyrinth();
  attachHandlers();
//	BUTTON_WIDTH = '12px';//(myWidth / MAXCOL);
//	BUTTON_HEIGHT = '12px';//(BUTTON_WIDTH/2) + 'px';
}// END FUNCTION ***********************

function setSize(){
	//LABYRINTH_SIZE = 8;
	//depends on size of squares and thier number
	var theframe = document.getElementById("myframe");
	var theboard = document.getElementById("board");
	var myWidth  = null;
	var myHeight = null;
	myarray = document.getElementById('Square_Size');
	BOX_SIZE = parseInt(myarray.options[myarray.selectedIndex].getAttribute("value"));
 	var Labyrinth_Size = document.getElementById('Labyrinth_Size');
	LABYRINTH_WIDTH = parseInt(Labyrinth_Size.options[Labyrinth_Size.selectedIndex].getAttribute("value"));
	MAXROW = LABYRINTH_WIDTH;
	MAXCOL = LABYRINTH_WIDTH;
	FONTSIZE = (BOX_SIZE-5) + 'px';
	//var new_LABYRINTH_WIDTH = LABYRINTH_WIDTH;
	LABYRINTH_WIDTH = BOX_SIZE * MAXROW + ((MAXROW - 1) * 5);
	theboard.style.fontSize = FONTSIZE;//Math.floor((myWidth * 0.9) * (BOX_SIZE/120)) + 'px';
 

//	BUTTON_WIDTH = '12px';//(myWidth / MAXCOL);
//	BUTTON_HEIGHT = '12px';//(BUTTON_WIDTH/2) + 'px';
}// END FUNCTION ***********************

var myBlocks = new Array();
myBlocks["messageboard"] = false;// for use only in the function set_visible
myBlocks["dragonmessageboard"] = false;// for use only in the function set_visible
myBlocks["playinstructions"] = false;// for use only in the function set_visible
myBlocks["messages"] = false;// for use only in the function set_visible
myBlocks["Welcome"] = false;// for use only in the function set_visible
myBlocks["mybar"] = true;// for use only in the function set_visible
myBlocks["new"] = false;// for use only in the function set_visible
myBlocks["end"] = false;
myBlocks["min"] = false;
myBlocks["bDragonIcon"] = false;
myBlocks["bTreasureIcon"] = false;
myBlocks["bShowTitle"] = true;
myBlocks["bShowRules"] = false;
myBlocks["bShowAbout"] = false;
myBlocks["bShowLabyrinth"] = false;
myBlocks["bShowDragon"] = false;
myBlocks["bShowTreasure"] = false;
myBlocks["About"] = false;

// create GLOBAL variables ***********************
var LastSet = 0; 
var NumPlayers = 1; // number of players, default is 1
var DragonVis = false;//should the Dragon be visible?
var GameOver = true; //is game still on or over

var MoveType = 0; //0 = choose home square, 1= move to, 2 = place treasure icon, 3 = place Dragon icon
var tempMoveType = 0;
var OnTurn = 0;// index of player on turn
var Players = new Array();
var TheTreasure = new Treasure();

var myColors = new Array();
myColors[0] = 'gold';
myColors[1] = 'goldenrod';
myColors[2] = 'cyan';
myColors[3] = 'darkcyan';
myColors[4] = 'maroon';
myColors[5] = 'maroon';



//handle incrementing the turn
function incTurn(){
	//alert(OnTurn + '= OnTurn calls incturn');
	var indx;
	indx = 0;
  if (OnTurn == NumPlayers) {
    OnTurn = 0;
  }else{
    OnTurn++;
  }
	while (OnTurn < NumPlayers){
			if (Players[OnTurn].alive == true){
      	//alert(OnTurn + '= is now OnTurn');
				var thesp = document.getElementById("onmovesp");
				thesp.innerHTML = Players[OnTurn].myName;
				thesp = document.getElementById("movesleftsp");
				thesp.innerHTML = (Players[OnTurn].maxmoves - Players[OnTurn].moves);
				return;
			}
			OnTurn++;
		}
	//OnTurn = NumPlayers;	
}// END FUNCTION ***********************


//these Icons are used only to mark the boxes when 
//the player marks them not the respective object locations
var Icons = new Array();
Icons[0] = new Icon();
Icons[0].myName = 'T';
Icons[1] = new Icon();
Icons[1].myName = 'M';

// FUNCTIONS ***********************

//set game over
function game_Over(){
	GameOver = true;
	TheTreasure.onPlayer = NumPlayers;
	postMessage('GAME OVER!!', 'pmessageboard', true);
	postMessage('GAME OVER!!', 'bmessageboard', true);
	//postMessageBoard('Game Over!! hit the New Game button to start again.', 'messageboard');
}// END FUNCTION ***********************


function isGameOver(){
  var i = 0;
  while ( i < Players.length -1){
    if (Players[i].alive == true) return false;
    i++;
  }
  return true;
}
// END FUNCVTION isGameOver ******************************



//create the treasure object
function Treasure(){
	this.myName = 'Treasure';
	this.x = 0;
	this.y = 0;
	this.lastx = 0;
	this.lasty = 0;
	this.homex = 0;
	this.homey = 0;	
	this.onPlayer = NumPlayers;//if 0 or 1 then that player as the treasure, if 2 then home
	this.alive = false;
	
	Treasure.prototype.tRefresh = function(){
		this.myName = 'Treasure';
		this.x = 0;
		this.y = 0;
		this.lastx = 0;
		this.lasty = 0;
		this.homex = 0;
		this.homey = 0;	
		this.onPlayer = NumPlayers;//if 0 or 1 then that player as the treasure, if 2 then home
		this.alive = false;
	};// END FUNCTION ***********************
		
	Treasure.prototype.setHome = function(x, y){
		this.x = x;
		this.y = y;
		this.lastx = x;
		this.lasty = y;
		this.homex = x;
		this.homey = y;	
	};// END FUNCTION ***********************
}// END FUNCTION ***********************
	

// create an icon object
function Icon(){
	this.myName = null; //'treasure', 'Dragon';
	//this.currentDiv = null; // div upon which the player puts the icon
	this.x = 0;
	this.y = 0;
	this.lastx = 0;
	this.lasty = 0;

	Icon.prototype.setHome = function(x, y){
		this.x = x;
		this.y = y;
		this.lastx = x;
		this.lasty = y;
	};// END FUNCTION ***********************
	
	Icon.prototype.placeIcon = function(x, y){
		this.lastx = this.x;
		this.lasty = this.y;
		this.x = x;
		this.y = y;
		this.paint();
	};// END FUNCTION ***********************
	
	Icon.prototype.remIcon = function(str){
		this.lastx = this.x;
		this.lasty = this.y;
		this.x = 0;
		this.y = 0;
		this.paint();
	};// END FUNCTION ***********************

    Icon.prototype.getIconSymbol = function(type){
        if (theStyle == 'Neverwinter'){
            if (type == 'Dragon'){
                message = '<A HREF="#fake" onclick="return false;"><img class="icon" src="icon_dragon.gif"  alt="&#9816;"></a>';
            }else if (type == 'Treasure'){
                message = '<A HREF="#fake" onclick="return false;"><img class="icon" src="icon_treasure.gif"  alt="&#9813;"></a>';
            }
        }else if (theStyle == 'Basic'){
            if (type == 'Dragon'){
                message = '&#9816;';
            }else if (type == 'Treasure'){
                message = '&#9813;';
            }
        }
		return message;
    }

	Icon.prototype.paint = function(){
		if (this.lastx > 0){
			myLabyrinth['b_' + this.lastx + '_' + this.lasty].paint();
		}
		if (this.x > 0){
			myLabyrinth['b_' + this.x + '_' + this.y].paint();
		}
	};// END FUNCTION ***********************				
	
}// END FUNCTION ***********************


function show_Dragon(){
	if (GAMECOUNT == 0){ return;}
	Icons[1].placeIcon(Players[NumPlayers].x, Players[NumPlayers].y);
	Icons[1].paint();
}


function show_Treasure(){
	if (GAMECOUNT == 0){ return;}
	Icons[0].placeIcon(Players[NumPlayers].homex, Players[NumPlayers].homey);
	Icons[0].paint();
}


// create a player object
function Player(){
	//this.id = 0; // 1 or 2
	this.myName = 'P';// + (OnTurn + 1); //player assigned name
	this.myNumber = -1;
	this.x = 0;
	this.y = 0;
	this.lastx = 0;
	this.lasty = 0;
	this.homex = 0;
	this.homey = 0;
	this.moves = 0;
	this.tempMaxmoves = 8;
	this.maxmoves = 8;// reduce by 2 after each battle lost, reduce to 4 if player has treasure
	this.hasTreasure = false; //does this player have the treasure now?
	this.alive = false;
	
	//object functions *************
	
	Player.prototype.pRefresh = function(num){
		this.myNumber = num;
		this.myName = 'P' + (this.myNumber + 1); //player assigned name
		this.x = 0;
		this.y = 0;
		this.lastx = 0;
		this.lasty = 0;
		this.moves = 0;
		this.tempMaxmoves = 0;
		this.maxmoves = 8;// reduce by 2 after each battle lost, reduce to 4 if player has treasure
		this.homex = 0;
		this.homey = 0;
		this.alive = true;
		this.hasTreasure = false;
	};// END FUNCTION ***********************
	
	if (typeof Player._initialized == 'undefined'){
		Player.prototype.moveTo = function(newx, newy){
		//do stuff
		if (this.alive == false){ return;}
		var oldMessage, newMessage, lastBox, newBox, blocked, wall;
		//var srchstr = '<h1>' + this.myName + '</h1>';
		blocked = true;
		wall = 'none';
		var oDiv1, oDiv2;
		postDebugMessage('moves made ' + this.moves, 'debug', false);
		if (this.moves < this.maxmoves){
			//check if move is legal
			//check if new box  adjacent to current box
			if (this.x == newx || this.y == newy){
				if (Math.abs((this.x + this.y) - (newx + newy)) == 1){
					//square is adjacent, now check for wall
					//this check depends on what direction the player is coming from
					if (newx > this.x){
						wall = 'east';
            myLabyrinth['b_' + this.x + '_' + this.y].feast = true;
            myLabyrinth['b_' + (this.x + 1) + '_' + this.y].fwest = true;
						if (myLabyrinth['b_' + this.x + '_' + this.y].east == false){
							blocked = false;
						}else{ 
              blocked = true;
            }
					}else if (newx < this.x){
						wall = 'west';
            myLabyrinth['b_' + this.x + '_' + this.y].fwest = true;
            myLabyrinth['b_' + (this.x - 1) + '_' + this.y].feast = true;
						if (myLabyrinth['b_' + this.x + '_' + this.y].west == false){
							blocked = false;
						}else{ 
              blocked = true;
            }
					}else if (newy < this.y){
						wall = 'south';
            myLabyrinth['b_' + this.x + '_' + this.y].fsouth = true;
            myLabyrinth['b_' + this.x + '_' + (this.y - 1)].fnorth = true;
						if (myLabyrinth['b_' + this.x + '_' + this.y].south == false){
							blocked = false;
						}else{ 
              blocked = true;
            }
					}else if (newy > this.y){
						wall = 'north';
            myLabyrinth['b_' + this.x + '_' + this.y].fnorth = true;
            myLabyrinth['b_' + this.x + '_' + (this.y + 1)].fsouth = true;
						if (myLabyrinth['b_' + this.x + '_' + this.y].north == false){
							blocked = false;
						}else{ 
              blocked = true;
            }
					}
					//postMessage('moveTo ' + blocked, 'messages', false);
					if (blocked == false){
						//then move to newx, newy
						// first update old square stuff
						lastBox = 'b_' + this.x + '_' + this.y;
						newBox =  'b_' + newx + '_' + newy;
						this.lastx = this.x;
						this.lasty = this.y;
						this.x = newx; //myLabyrinth[newBox].x;
						this.y = newy; //myLabyrinth[newBox].y;
						//postMessage('<h1>' + this.name + '</h1>', newBox, false);
						if (wall == 'east'){
							call_wallvis('floor', 'vw_' + lastBox);
						}else if (wall == 'west'){
							call_wallvis('floor', 'vw_' + newBox);
						}else if (wall == 'north'){
							//newBox = 'b_' + this.x + '_' + newy;
							//alert('gray hw_' + lastBox);
							call_wallvis('floor', 'hw_' + lastBox);
						}else if (wall == 'south'){
							//newBox = 'b_' + this.x + '_' + (this.y + 1);
							//alert('gray hw_' + newBox);
							call_wallvis('floor', 'hw_' + newBox);
						}
						myLabyrinth['b_' + this.lastx + '_' + this.lasty].paint();
						//draw the player gif to the floater, 
            //move floater to spot and then hide floater then paint new box
						moveFloater('b_' + this.lastx + '_' + this.lasty, 'b_' + this.x + '_' + this.y, this.myNumber);
				}else{
						lastBox = 'b_' + this.x + '_' + this.y;
						newBox =  'b_' + newx + '_' + newy;
						if (wall == 'east'){
							call_wallvis('wall', 'vw_' + lastBox);
						}else if (wall == 'west'){
							call_wallvis('wall', 'vw_' + newBox);
						}else if (wall == 'north'){
							call_wallvis('wall', 'hw_' + lastBox);
						}else if (wall == 'south'){
							call_wallvis('wall', 'hw_' + newBox);
						}
						postDebugMessage('moveTo ' + wall + ' FAILED' + this.moves, 'messages', false);
						this.moves = this.maxmoves;
					}
					this.moves++;
					postMessage((this.maxmoves - this.moves), "movesleftsp");
					ifCollide();
					this.findTreasure();
					this.victory();
			}}}
			postDebugMessage('this.moves=' + this.moves + 'gameover=' + GameOver);
			postDebugMessage('this.maxmoves=' + this.maxmoves + ' OnTurn=' + OnTurn);
			if (this.moves >= this.maxmoves && GameOver == false){
				this.endTurn();
				}else if (GameOver == false){
					postMessage(this.myName +  ' has made ' + (this.moves) + ' moves.', 'pmessageboard', true);
				}
		};// END FUNCTION ***********************
		
		Player.prototype.findTreasure = function(){
			if (TheTreasure.onPlayer == NumPlayers && TheTreasure.homex == this.x && TheTreasure.homey == this.y){
				TheTreasure.onPlayer = this.myNumber;
				this.hasTreasure = true;
				this.tempMaxmoves = this.maxmoves;
				this.maxmoves = 4;
				myLabyrinth['b_' + this.x + '_' + this.y].paint();
				postDebugMessage('<h1 class="mb">' + this.myName + ' has found the TREASURE!!', 'debug', false);		
				postMessage('' + this.myName + ' has found the TREASURE!!', 'pmessageboard', true);		
				postMessage(Players[TheTreasure.onPlayer].myName, 'hastreasuresp', true);			
                //alert(this.myName + ' has found the TREASURE!!');
			}
		};// END FUNCTION *********************
		
		Player.prototype.victory = function(){
			if (this.hasTreasure == true &&	this.x == this.homex && this.y == this.homey){
				//postMessage(this.myName + ' has WON!!', 'messages', true);		
				game_Over();
				postMessage('' + this.myName + ' has WON!! Hit the New Game button to start again.', 'pmessageboard');
			} 
		};// END FUNCTION *********************
				
		// if bool = true, player was attacked by Dragon	
		Player.prototype.endTurn = function(bool){
            var message = null;
            if (bool == true){
                message = '' + this.myName + ', you were attacked by the Dragon and sent to your home square';
            }else{
                message = '' + this.myName + ', your Turn is over.';
            }
            postMessage(message, 'pmessageboard', true);
            //postMessageBoard(message, 'messageboard');
            incTurn();
            this.moves = 0;
            if (OnTurn == NumPlayers) {
                Players[NumPlayers].moveTo();
            }
		};// END FUNCTION ***********************			
		
		Player.prototype.death = function(){
			postMessage(this.myName + ' has been killed.', 'pmessageboard', false, true);
			//alert(this.myName);
			//postMessage('GAME OVER!!', 'Dragonmessages', true);
			this.alive = false;
			this.hasTreasure = false;
			if (TheTreasure.onPlayer == this.myNumber){
				TheTreasure.onPlayer = NumPlayers;
				postMessage('', 'hastreasuresp');
			}
            if (this.myNumber == OnTurn){
                incTurn();
            }
			if (isGameOver()){
				game_Over();
			}
		};// END FUNCTION ***********************			
		
		Player.prototype.goHome = function(){
			this.lastx = this.x;
			this.lasty = this.y;
			this.x = this.homex;
			this.y = this.homey;
			this.paint();
			if (OnTurn == this.myNumber){
				this.endTurn(true);
			}
		};// END FUNCTION ***********************			
		
		//players only attack each other when one has the treasure and both
		//are on the same square
		Player.prototype.attack = function(){
			//alert(this.myName + ' attacks');
			var other, rand, on;
			if (TheTreasure.onPlayer == NumPlayers){ return;}
			on = TheTreasure.onPlayer;
			rand = Math.floor(Math.random()*NumPlayers);//roughly %50 each
			if (rand != on){
				Players[rand].hasTreasure = true;
				Players[on].hasTreasure = false;
				Players[rand].tempMaxmoves = Players[rand].maxmoves;
				Players[rand].maxmoves = 4;
				Players[on].maxmoves = Players[on].tempMaxmoves;
				TheTreasure.onPlayer = rand;
				postMessage('' + Players[rand].myName + ' stole the treasure from ' + Players[on].myName + '!!', 'pmessageboard');
				postMessage(Players[TheTreasure.onPlayer].myName, 'hastreasuresp');
			}
		};// END FUNCTION ***********************
	
		Player.prototype.paint = function(){
			myLabyrinth['b_' + this.lastx + '_' + this.lasty].paint();
			myLabyrinth['b_' + this.x + '_' + this.y].paint();
		};// END FUNCTION ***********************					
		
		Player.prototype.notHome = function(){
			return (this.x != this.homex || this.y != this.homey);
		};// END FUNCTION ***********************					
		
		Player.prototype.isHome = function(){
			return (this.x == this.homex && this.y == this.homey);
		};// END FUNCTION ***********************					

		Player.prototype.getPlayerSymbol = function(){
            var message = '';
            if (theStyle == 'Neverwinter'){
                if (this.alive ){
                    if (this.hasTreasure){
                        message = '<A HREF="#fake" onclick="return false;"><IMG class="rich" src="' + this.myName + '.jpg"  alt="&#9820;"></A>';
                    }else{
                        message = '<A HREF="#fake" onclick="return false;"><IMG class="alive" src="' + this.myName + '.jpg"  alt="&#9820;"></A>';
                    }
                }else if (!this.alive ){
                    message = '<A HREF="#fake" onclick="return false;"><IMG class="dead" src="' + this.myName + '.jpg"  alt="&#9812;"></A>';
                }
            }else if (theStyle == 'Basic'){
                if (this.alive ){
                    if (this.hasTreasure){
                        message = '&#9818;';//'<strong>&#9820;</strong>';
                    }else{
                        message = '&#9818;';//&#9820;';
                    }
                }else if (!this.alive ){
                    message = '&#9812;';
                }
            }
            return message;
		};// END FUNCTION ***********************

        Player.prototype.getPlayerColor = function(){
            var colornum = this.myNumber % myColors.length;
            var colstr = myColors[colornum*2 + 1];
            return colstr;
        };// END FUNCTION ***********************

        //get the players background color or image
        Player.prototype.getPlayerBack = function(){
            var message = this.myName +  'HOME';
            /*
             *if (theStyle == 'Neverwinter'){
                message =  'url(' + this.myName + '_back.gif)';
            }else if (theStyle == 'Basic'){
                message = myColors[this.myNumber * 2 ];
            }
            */
            return message;
        };// END FUNCTION ***********************

		Player.prototype.setHome = function(divname){			
			var taboo = false;
			if (this.myNumber == 0){
				this.x = myLabyrinth[divname].x;
				this.y = myLabyrinth[divname].y;
				this.lastx = myLabyrinth[divname].x;
				this.lasty = myLabyrinth[divname].y;
				this.homex = myLabyrinth[divname].x;
				this.homey = myLabyrinth[divname].y;
				this.paint();	
				//alert('first sethome indx=' + this.myNumber);				
			}else{
				for (var indx = 0; indx < NumPlayers; indx++){//make sure players do not have same start square
					if (myLabyrinth[divname].x == Players[indx].homex && myLabyrinth[divname].y == Players[indx].homey){
						return;
						}
				}
				this.x = myLabyrinth[divname].x;
				this.y = myLabyrinth[divname].y;
				this.lastx = myLabyrinth[divname].x;
				this.lasty = myLabyrinth[divname].y;
				this.homex = myLabyrinth[divname].x;
				this.homey = myLabyrinth[divname].y;
				this.paint();	
				//alert('second sethome idx=' + this.myNumber);				
			}
			incTurn();
			if (OnTurn == NumPlayers){
				Players[OnTurn].setHome();
			}
		};// END FUNCTION ***********************						
	}
	Player._initialized = true;
}// END FUNCTION ***********************


//end a players turn
function end_turn(evt){
	if (GameOver == true || BEGAN_TURN == false){return;}
	var thisBox;
	if (!evt) {
		evt = event;
		thisBox = evt.srcElement;
	} else {
		thisBox = evt.target;
	}
	Players[OnTurn].endTurn();
	thisBox.style.zIndex='10';
}// END FUNCTION ***********************




function hide_control_panel(){
	theSide = document.getElementById("mybar");
	theSide.style.zIndex='0';
	set_visible('mybar', 'hidden');
	set_visible('new', 'hidden');
	set_visible('end', 'hidden');
	set_visible('bDragonIcon', 'hidden');
	set_visible('bTreasureIcon', 'hidden');
	set_visible('bRemoveDragonIcon', 'hidden');
	set_visible('bRemoveTreasureIcon', 'hidden');
	set_visible('bShowTitle', 'hidden');
	set_visible('bShowRules', 'hidden');
	set_visible('bShowAbout', 'hidden');
	set_visible('bShowLabyrinth', 'hidden');
	set_visible('bShowTreasure', 'hidden');
	set_visible('bShowDragon', 'hidden');	
}

function show_control_panel(){
	theSide = document.getElementById("mybar");
	theSide.style.zIndex='12';
	set_visible('mybar', 'visible');
	set_visible('new', 'visible');
	set_visible('end', 'visible');
	set_visible('bDragonIcon', 'visible');
	set_visible('bTreasureIcon', 'visible');
	set_visible('bRemoveDragonIcon', 'visible');
	set_visible('bRemoveTreasureIcon', 'visible');	
	set_visible('bShowTitle', 'visible');
	set_visible('bShowRules', 'visible');
	set_visible('bShowAbout', 'visible');
	set_visible('bShowLabyrinth', 'visible');
	set_visible('bShowTreasure', 'visible');
	set_visible('bShowDragon', 'visible');	
}

function show_newgameoptions(evt){
	var thisBox;
	if (!evt) {
		evt = event;
		thisBox = evt.srcElement;
	} else {
		thisBox = evt.target;
	}	
	set_visible('newgameoptions', 'visible');
	set_visible('startnew', 'visible');
	set_visible('cancel', 'visible');
	thisBox.style.zIndex='12';
	hide_control_panel();
}
	
function hide_newgameoptions(evt){
	var thisBox;
	if (!evt) {
		evt = event;
		thisBox = evt.srcElement;
	} else {
		thisBox = evt.target;
	}	
	set_visible('newgameoptions', 'hidden');
	set_visible('startnew', 'hidden');
	set_visible('cancel', 'hidden');
	thisBox.style.zIndex='1';
	show_control_panel();
}

function show_mybar(evt){
	var thisBox;
	if (!evt) {
		evt = event;
		thisBox = evt.srcElement;
	} else {
		thisBox = evt.target;
	}	
	set_visible('mybar', 'visible');
	thisBox.style.zIndex='10';
	set_visible('new', 'visible');
	set_visible('end', 'visible');
	set_visible('bDragonIcon', 'visible');
	set_visible('bTreasureIcon', 'visible');
	set_visible('bRemoveDragonIcon', 'visible');
	set_visible('bRemoveTreasureIcon', 'visible');	
	set_visible('bShowTitle', 'visible');
	set_visible('bShowRules', 'visible');
	set_visible('bShowAbout', 'visible');
	set_visible('bShowLabyrinth', 'visible');
	set_visible('bShowDragon', 'visible');
	set_visible('bShowTreasure', 'visible');	
}// END FUNCTION ***********************

// create a player object
function Dragon(){
	this.myName = 'Dragon';
	this.myNumber = NumPlayers;
	this.asleep = true;
	this.alive = true;
	this.hasTreasure = false;
	this.x = 1;
	this.y = 1;
	this.lastx = 1;
	this.lasty = 1;
	this.moves = 0;
	this.maxmoves = 1;//irrelevant for Dragons
	this.homex = 1;
	this.homey = 1;
	if (typeof Dragon._initialized == 'undefined'){
		  Dragon.prototype.mRefresh = function(){
				this.myName = 'Dragon';
				this.myNumber = NumPlayers;
				this.x = 1;
				this.y = 1;
				this.lastx = 1;
				this.lasty = 1;
				this.moves = 1;
				this.maxmoves = 1;
				this.homex = 1;
				this.homey = 1;
				this.asleep = true;
				this.alive = true;
				this.hasTreasure = false;
			};// END FUNCTION ***********************
			
			Dragon.prototype.moveTo = function(){
				this.listen();
				if (this.asleep == false){
					if (TheTreasure.onPlayer == NumPlayers){
						//find nearest player
						var newx, newy, newBox, oldBox;
						var attack, attackdist, found, count, indx;
						found = false;
						count = 0;
						indx = 0;
						attack = NumPlayers;
						attackdist = 100;
						var pdist = new Array();
						pdist[0] = 0;
						var targets = new Array();
						targets[0] = 0;
						//find all eligible players
						//copare distance
						//keep shortest
						while( count < NumPlayers){
						//postDebugMessage('00attack=' + attack, 'Dragonmessages', false);
							if (Players[count].alive && (Players[count].myNumber != NumPlayers) && (Players[count].notHome())){
								if ((Math.abs(Players[count].x - Players[NumPlayers].x)) >= (Math.abs(Players[count].y - Players[NumPlayers].y))){
									pdist[indx] = Math.abs(Players[count].x - Players[NumPlayers].x);
								}else{
									pdist[indx] = Math.abs(Players[count].y - Players[NumPlayers].y);
								}
								//find lowest dist
								targets[indx] = count;
								if (pdist[indx] < attackdist){
									attack = count;
									attackdist = pdist[indx];
								}else if (pdist[indx] == attackdist){
									// fifty fifty
									if (Math.floor(Math.random()*2) == 0){
										attack = targets[count];
										attackdist = pdist[indx];
									}
								}
								indx++;
							}
							count++;
						}//end while
						count = 0;
						indx = 0;
					}else{
						attack = TheTreasure.onPlayer;
					}	
					if (attack == NumPlayers){//if there is no available player then go home
						//alert('Dragon Going Home');
						newx = this.x;
						newy = this.y;
						if (this.x > this.homex){
							newx = this.x - 1;
							}else if (this.x < this.homex){
								newx = this.x + 1;
								}
						if (this.y > this.homey){
							newy = this.y - 1;
							}else if (this.y < this.homey){
								newy = this.y + 1;
							}
					}else{//chase player
						//chase Players[attack]
						//alert('Dragon Chasing ' + Players[attack].myName);
						newx = this.x;
						newy = this.y;
						if (Players[attack].x > this.x){ 
							newx = this.x + 1;
						}else if (Players[attack].x < this.x){ 
							newx = this.x - 1;
						}
						if (Players[attack].y > this.y){ 
							newy = this.y + 1;
						}else if (Players[attack].y < this.y){ 
							newy = this.y - 1;
						}
					}
				
					this.lastx = this.x;
					this.lasty = this.y;
					this.x = newx;
					this.y = newy;
					newBox = 'b_' + this.x + '_' + this.y;		
					oldBox = 'b_' + this.lastx + '_' + this.lasty;				
					if (oldBox != newBox){
						postMessage('The Dragon moves!!!', 'bmessageboard', true);
					//	postMessageBoard('<h1 class="mb">The Dragon moves!</h1>', 'dragonmessageboard');
					}else{
						postMessage('The Dragon is silent.', 'bmessageboard', true);
					}
					ifCollide();				
					this.paint();
				}//end if asleep == false
				this.endTurn();
			};// END FUNCTION ***********************			
			

			Dragon.prototype.paint = function(){
					myLabyrinth['b_' + this.lastx + '_' + this.lasty].paint();
					myLabyrinth['b_' + this.x + '_' + this.y].paint();
			};// END FUNCTION ***********************					
			
            Dragon.prototype.getPlayerColor = function(){
                var colornum = this.myNumber % myColors.length;
                var colstr = myColors[colornum*2 + 1];
                return colstr;
            };// END FUNCTION ***********************

            //get the players background color or image
            Dragon.prototype.getPlayerBack = function(){
                var message = 'DRHOME';
                /*
                if (theStyle == 'Neverwinter'){
                    message = 'url(icon_dragon.gif)';
                }else if (theStyle == 'Basic'){
                    message = myColors[this.myNumber * 2 ];
                }
                */
                return message;
            };// END FUNCTION ***********************

            Dragon.prototype.getPlayerSymbol = function(){
                var message = '';
                if (theStyle == 'Neverwinter'){
                    message = '<A HREF="#fake" onclick="return false;"><img class="alive" src="nwn_rdd.jpg"  alt="&#9822;"></a>';
                }else if (theStyle == 'Basic'){
                    message = '&#9822;';
                }
                return message;
            }

			Dragon.prototype.attack = function(playerNumber){
				//alert(this.myName + ' attacks P' + playerNumber);
				if (Players[playerNumber].alive && ((Players[playerNumber].x != Players[playerNumber].homex) || (Players[playerNumber].y != Players[playerNumber].homey))){
					Players[playerNumber].maxmoves = Players[playerNumber].maxmoves - 2;
					if (Players[playerNumber].maxmoves < 4 || Players[playerNumber].hasTreasure){
						postMessage('The Dragon kills ' + Players[playerNumber].myName + '!', 'bmessageboard', false);
						Players[playerNumber].death();
					}else{
						postMessage('The Dragon attacks ' + Players[playerNumber].myName + '!', 'bmessageboard', false);
						Players[playerNumber].goHome();
					}
				}
			};// END FUNCTION ***********************
			
			Dragon.prototype.awake = function(){
				if (this.asleep == true){
					this.asleep = false;
					//postMessage('The Dragon AWAKES!!', 'Dragonmessages', true);
					//postDebugMessage('The Dragon AWAKES!!player0 on ' + Players[0].x + ':' + Players[0].y + ' Dragon on ' + this.x + ':' + this.y, 'debug', true);
					postMessage('The Dragon AWAKES!', 'bmessageboard', false, false);
					postMessage('Yes', 'awakesp', true);
				}else{
					postMessage('No', 'awakesp', true);
				}
			};// END FUNCTION ***********************
			
			Dragon.prototype.endTurn = function(){
				postMessage('The Dragon ends its turn.', 'bmessageboard', false, false);
				//postMessageBoard('Dragon moves!!', 'messageboard');
				incTurn();
				this.moves = 0; 
			};// END FUNCTION ***********************	
			
			Dragon.prototype.listen = function(){			
				// is Dragon still asleep?  is he now awakened?
				if (this.asleep == true){
					var count = 0;
					//check for players nearby
					while (count < NumPlayers){
						if (Players[count].alive && Players[count].notHome){
							if ((Math.abs(Players[count].x - this.homex) <= MINDISTANCE) && (Math.abs(Players[count].y - this.homey) <= MINDISTANCE)){
								this.awake();
								break;
							}
						}
					count++;
					}
				}
			};// END FUNCTION ***********************				
			
			Dragon.prototype.setHome = function(){			
				//set homeid
				var myIndex, count;
				var found_home = false;
				count = 0;
				myIndex = Math.floor(Math.random()*(MAXCOL*MAXROW)) + 1;
				postDebugMessage(myIndex + ' myIndex', 'messages', false);
				//loop through myLabyrith looking for a good square not too close
				//to the players home squares.  start earching at myLabyrinth[number]
				while (found_home == false && count++ < (2*MAXCOL*MAXROW)){
					homex = myLabyrinth['b_' + ((myIndex % MAXCOL) + 1) + '_' + (Math.ceil(myIndex/MAXCOL))].x;
					homey = myLabyrinth['b_' + ((myIndex % MAXROW) + 1) + '_' + (Math.ceil(myIndex/MAXROW))].y;
					postDebugMessage(myIndex + '=myIndex box is b_' + homex + '_' + homey, 'messages', false);
					//check for players nearby
						if ((Math.abs(Players[0].homex - homex) > MINDISTANCE) || (Math.abs(Players[0].homey - homey) > MINDISTANCE)){
							found_home = true;
						}else{found_home = false;}
						if (Players[1].alive && found_home == true){
							if ((Math.abs(Players[1].homex - homex) > MINDISTANCE) || (Math.abs(Players[1].homey - homey) > MINDISTANCE)){
								found_home = true;
							}else{found_home = false;}
						}		
					myIndex = (myIndex % (MAXROW*MAXCOL)) + 3;					
				}//end while
				if (found_home){
					this.x = homex;
					this.y = homey;
					this.lastx = homex;
					this.lasty = homey;
					this.homex = homex;
					this.homey = homey;
					TheTreasure.setHome(homex, homey);
					incTurn();
					MoveType = 1;	
					BEGAN_TURN = true;
				}else{
					postMessage('No home found for the Dragon!, restart game.', 'bmessageboard', true);
					//postMessage('no home found for the Dragon!, restart game.', 'bmessageboard', true);
				}
			};// END FUNCTION ***********************				
		}
	Dragon._initialized = true;
}// END FUNCTION ***********************


//detect collision and handle it
//sequence of events:
//1 - player enters box
//2 - if dragon there then dragon attacks OnTurn
//3 - if other player with treasure there then player attack player
function ifCollide(){
	///any entering player gets hit by Dragon
	//alert('1 ifcollide ' + OnTurn);
	if (OnTurn != NumPlayers){// never true if called by Dragon.moveTo
		//alert('2 ifcollide ' + OnTurn);
		if ((Players[OnTurn].x == Players[NumPlayers].x) && (Players[OnTurn].y == Players[NumPlayers].y)){
			//alert('3 ifcollide ' + OnTurn  + Players[OnTurn].x + Players[OnTurn].homex);
			if (Players[OnTurn].notHome){ 
				//alert('4 ifcollide ' + OnTurn);
				Players[NumPlayers].awake();
				Players[NumPlayers].attack(OnTurn);
				return;
			}
		}
	}
	//if anyone on square has treasure attack them
	if (TheTreasure.onPlayer != NumPlayers && Players[OnTurn].hasTreasure == false){
		if (Players[OnTurn].x == Players[TheTreasure.onPlayer].x && Players[OnTurn].y == Players[TheTreasure.onPlayer].y){
			 Players[OnTurn].attack(TheTreasure.onPlayer);//either palyer attaking runs same code
			 return;
		}
	}
	
	//if Dragon enters square attack a player at random
	//assuming none have treasure, that case should be handles above
	if (OnTurn == NumPlayers){
		var indx, count;//found, 
		count = 0;
		indx = Math.floor(Math.random()*NumPlayers);
		while (count++ <= NumPlayers ){//found == false && 
			if (Players[indx].alive && indx != NumPlayers){
				if (Players[indx].x == Players[NumPlayers].x && Players[indx].y == Players[NumPlayers].y){
					//found = true;
					Players[NumPlayers].attack(indx);
					return;
				}
			}
			indx++;
			indx = indx % NumPlayers;	
		}//end while
	}//end if
}// END FUNCTION ***********************


//do a move from the players square to the next
function click_On_Box(evt) {
  //alert("click");
	if (GameOver == true){ 
		postMessage('The game is over, hit the New Game button to start again.', 'pmessageboard', false); 
		//postMessageBoard('The game is over, hit the New Game button to start again.', 'dragonmessageboard', false);
		return;
		}
	var thisBox;
	if (!evt) {
		evt = event;
		thisBox = evt.srcElement;
		} else {
			thisBox = evt.target;
		}
    var srcType = 'box';//ok
	if (thisBox.className == 'box' ||
        thisBox.className == "P1HOME" ||
        thisBox.className == "P2HOME" ||
        thisBox.className == "DRHOME"){
		srcType = 'box';//ok
	}else if (thisBox.className == 'alive' || thisBox.className == 'dead' || thisBox.className == 'rich' || thisBox.className == 'icon'){ 
		//take care of image click, pass event to box
		srcType = 'img';
		thisBox = thisBox.parentNode.parentNode;
		//alert(thisBox + thisBox.className);
	}else{ return;}// only handle clicks on certain images and the boxes
	var oldx, oldy, newx, newy, lastx, lasty, lastBox, oldMessage;
	postDebugMessage('OnTurn=' + OnTurn + ' MoveType= ' + MoveType + ' clicked on:' + thisBox.id,  'messages');
	newx = myLabyrinth[thisBox.id].x;
	newy = myLabyrinth[thisBox.id].y;
	
	switch(MoveType){
		case 0:
			Players[OnTurn].setHome(thisBox.id);
			break;
		case 1:
			Players[OnTurn].moveTo(myLabyrinth[thisBox.id].x, myLabyrinth[thisBox.id].y);
			break;
		case 2:
			//treasure icon
			Icons[0].placeIcon(myLabyrinth[thisBox.id].x, myLabyrinth[thisBox.id].y);
			myLabyrinth[thisBox.id].paint();
			if (Icons[0].lastx > 0){
				lastBox = 'b_' + Icons[0].lastx + '_' + Icons[0].lasty;
				myLabyrinth[lastBox].paint();
			}
			MoveType = 1;//tempMoveType;
			break;
		case 3:
		//Dragon icon
			Icons[1].placeIcon(myLabyrinth[thisBox.id].x, myLabyrinth[thisBox.id].y);
			myLabyrinth[thisBox.id].paint();
			if (Icons[1].lastx > 0){
				lastBox = 'b_' + Icons[1].lastx + '_' + Icons[1].lasty;
				myLabyrinth[lastBox].paint();
			}
			MoveType = 1;//tempMoveType;
			break;
		case BLOCK:
		default: 	return;	
	}
}// END FUNCTION ***********************


function repaintSprites(){
    //repaint players
    Players[0].paint();
    Players[1].paint();
    if (Players.legnth > 2) Players[2].paint();
    //repaint icons
    Icons[0].paint();
    Icons[1].paint();
}

function moveFloater(oldBox, newBox, count){
	ONEWBOX = document.getElementById(newBox);
	MYOLDBOX = document.getElementById(oldBox);
	OFLOATER = document.getElementById('floater');
	var ox = parseInt(MYOLDBOX.style.left);
	var oy = parseInt(MYOLDBOX.style.top);
	var nx = parseInt(ONEWBOX.style.left);
	var ny = parseInt(ONEWBOX.style.top);
	if (nx > ox) {xplus = true}else{xplus = false;}
	if (ny > oy) {yplus = true}else{yplus = false;}
    message = Players[count].getPlayerSymbol();
    postMessage(message, 'floater', true);
	OFLOATER.style.top  = oy + 'px';
	OFLOATER.style.left = ox + 'px';
	OFLOATER.style.visibility = 'visible';
	OFLOATER.style.width = BOX_SIZE + 'px';
	OFLOATER.style.height = BOX_SIZE + 'px';
    OFLOATER.style.fontSize = FONTSIZE;
    OFLOATER.style.color = Players[count].getPlayerColor();
	
	if (Math.abs(parseInt(OFLOATER.style.left) - nx) > 15 || Math.abs(parseInt(OFLOATER.style.top) - ny) > 1){
		newx = nx;
		newy = ny;
		nowMove();
	}
}

function nowMove(){
	if (Math.abs(parseInt(OFLOATER.style.top) - newy) > 1){
		if (yplus){
			OFLOATER.style.top =  (parseInt(OFLOATER.style.top) + 2) + 'px';
		}else{
			OFLOATER.style.top =  (parseInt(OFLOATER.style.top) - 2) + 'px';
		}
	}
	if (Math.abs(parseInt(OFLOATER.style.left) - newx) > 1){
		if (xplus){
			OFLOATER.style.left =  (parseInt(OFLOATER.style.left) + 2) + 'px';
		}else{
			OFLOATER.style.left =  (parseInt(OFLOATER.style.left) - 2) + 'px';
		}
	}
	if (Math.abs(parseInt(OFLOATER.style.left) - newx) > 1 || Math.abs(parseInt(OFLOATER.style.top) - newy) > 1){
		setTimeout("nowMove()", 1);
	}else{
		OFLOATER.style.visibility = 'hidden';
		myLabyrinth[ONEWBOX.id].paint();
	}
}

function sleep(millisecs){
  //millisecs = millisecs * 1000;
  var sleeping = true;
  var now = new Date();
  var alarm;
  var startingMSeconds = now.getTime();
//  alert("starting nap at timestamp: " + startingMSeconds + "\nWill sleep for: " + naptime + " ms");
  while(sleeping){
     alarm = new Date();
     alarmMSeconds = alarm.getTime();
     if(alarmMSeconds - startingMSeconds > millisecs){ sleeping = false; }
	}  	
}


// create a room object
function Room() {
this.north = true;//is there a wall on this side?
this.east = true;
this.south = true;
this.west = true;
this.fnorth = false;//has a player tried this wall yet?
this.feast = false;
this.fsouth = false;
this.fwest = false;

this.x = 0;
this.y = 0;
this.setid = 0;
this.visited = false;
this.sp_used = false;

if (typeof Room._initialized == 'undefined'){
		Room.prototype.paint = function(){
			var message = '';
			//set special color of boxes, eg home squares, 
			//Dragon and treasure icons 
			var oDiv1 = document.getElementById('b_' + this.x + '_' + this.y);
			var count = 0;
			var colornum = 0;
			var bool = false;
			var colstr = 'gray';
			if (oDiv1 != null){
                setBoxDefaults(oDiv1);
                oDiv1.style.fontSize = FONTSIZE;
                //paint each player to box, the Dragon will be on top if present
				while (count < NumPlayers){
                    //paint players
					if ( Players[count].x == this.x && Players[count].y == this.y ){
                        message = Players[count].getPlayerSymbol();
                        postMessage(message, 'b_' + this.x + '_' + this.y, true);
                        oDiv1.style.color = Players[count].getPlayerColor();
                        //setBoxBack(  oDiv1, Players[count].getPlayerBack());
						}
                    //paint players homes
					if ( Players[count].homex == this.x && Players[count].homey == this.y ){
                        //message = Players[count].getPlayerSymbol();
                        postMessage(message, 'b_' + this.x + '_' + this.y, true);
                        oDiv1.style.color = Players[count].getPlayerColor();
                        oDiv1.setAttribute('class', Players[count].getPlayerBack());//setBoxBack(  oDiv1, Players[count].getPlayerBack());
						}
					count++;
				}
			}// end if (oDiv1 != null)

            //paint icons to box
			if (message == '' && Icons[1].x == this.x && Icons[1].y == this.y ){//set Dragon icon
                message = Icons[1].getIconSymbol('Dragon');
                postMessage(message, 'b_' + this.x + '_' + this.y, true);
                oDiv1.style.color = '#8B0000';
			}else if (message == '' && Icons[0].x == this.x && Icons[0].y == this.y ){//set Treasure icon
				message = Icons[1].getIconSymbol('Treasure');
                postMessage(message, 'b_' + this.x + '_' + this.y, true);
                oDiv1.style.color = '#8B0000';
			}
			//paint dragon to box
			if ((this.x == Players[NumPlayers].x) && (this.y == Players[NumPlayers].y)){
				if (DragonVis == true && message == ''){//for debugging
                    message = Players[NumPlayers].getPlayerSymbol();
                    postMessage(message, 'b_' + this.x + '_' + this.y, true);
                    oDiv1.style.color = Players[NumPlayers].getPlayerColor();
                    //setBoxBack(  oDiv1, Players[NumPlayers].getPlayerColor());
				}
			}

			//paint the player onturn to box to make sure their icon is on top
			if (OnTurn != NumPlayers){
				if (Players[OnTurn].alive && (Players[OnTurn].x == this.x) && (Players[OnTurn].y == this.y) ){
					message = Players[OnTurn].getPlayerSymbol();
                    postMessage(message, 'b_' + this.x + '_' + this.y, true);
                    oDiv1.style.color = Players[OnTurn].getPlayerColor();
                    //setBoxBack(  oDiv1, Players[OnTurn].getPlayerBack());
//					if ( Players[OnTurn].homex == this.x && Players[OnTurn].homey == this.y ){//set home color of player 1
//						//colstr = getPlayerColor(count);
//                        //Players[OnTurn].
//                        setBoxBack(OnTurn, oDiv1, colstr);
//						}
				}
			}
            
            //oDiv1.innerHTML = oDiv1.innerHTML + myLabyrinth['b_' + this.x + '_' + this.y].setid;
            //oDiv1.style.backgroundColor = colstr;
            
            //oDiv1.style.color = Players[OnTurn].getPlayerColor();
            //Players[OnTurn].paint();
        };// END FUNCTION ***********************

  	Room.prototype.knockextrawall = function(bool){  
      var nextroom = null;
      if (this.sp_used){ return false;}
      if (bool){
        //knock down a wall if there is one with a large difference in setid
        //examine adjacent rooms for setid 
        //find room2 - a non-joined room with the largest variance in setid
        
        nextroom = makepassage(this.x, this.y);        
        if (nextroom.length > 1 && Math.abs(myLabyrinth[nextroom].setid - this.setid) > 9){
          join('b_' + this.x + '_' + this.y, nextroom);
          this.sp_used = true;
          //alert('b_' + this.x + '_' + this.y + ' to ' + nextroom + ' ' + ++numknocks);
          return true;
        }else{
          return false;          
        }
      }else{
        //knock down a wall regardless of setid variance       
        nextroom = makepassage(this.x, this.y);        
        if( nextroom.length > 1 ){
          join('b_' + this.x + '_' + this.y, nextroom);        
          //alert('b_' + this.x + '_' + this.y + '  to ' + nextroom + ' ' + ++numknocks);
          this.sp_used = true;
          return true;
          }
        return false;
      }
    };//end func

	}//end if _initialized

	Room._initialized = true;
}// END FUNCTION ***********************





function getPlayerColorx(count){
    var colornum = count % myColors.length;
    var colstr = myColors[colornum];
    return colstr;
}


function setBoxBackColor( oDiv1, color){
    oDiv1.style.backgroundColor = color;
}
function setBoxBackImg( oDiv1, image){
    oDiv1.style.backgroundImage = image;
    oDiv1.style.backgroundRepeat =  'no-repeat'
    oDiv1.style.backgroundPosition = 'center';
}


function setBoxDefaults(oDiv1){
    oDiv1.setAttribute('class', 'box');
    oDiv1.innerHTML = '';
    /*
    if (theStyle == 'Neverwinter'){
        setBoxBackImg( oDiv1, 'url(bgtexture_3_dark.gif)');
    }else if (theStyle == 'Basic'){
        oDiv1.setAttribute('class', 'box');//setBoxBackColor( oDiv1, 'gray');
        oDiv1.style.backgroundImage = '';
        oDiv1.style.backgroundRepeat =  '';
        oDiv1.style.backgroundPosition = '';
    }
    */
}


//param color is either a colort or a string giving  a url image
function setBoxBackx( oDiv1, color){
    if (theStyle == 'Neverwinter'){
        setBoxBackImg( oDiv1, color);
    }else if (theStyle == 'Basic'){
        //oDiv1.setAttribute('class', 'box');
        setBoxBackColor( oDiv1, color);
        oDiv1.style.backgroundImage = '';
        oDiv1.style.backgroundRepeat =  '';
        oDiv1.style.backgroundPosition = '';
    }
}


function getPlayerSymbolFloatx(count){
    var message = '';
    if (theStyle == 'Neverwinter'){
        if (Players[count].alive ){
            if (Players[count].hasTreasure){
                message = '<A HREF="#fake" onclick="return false;"><IMG class="rich" src="' + Players[count].myName + '.jpg"  alt="&#9820;"></A>';
            }else{
                message = '<A HREF="#fake" onclick="return false;"><IMG class="alive" src="' + Players[count].myName + '.jpg"  alt="&#9820;"></A>';
            }
        }else if (!Players[count].alive ){
            message = '<A HREF="#fake" onclick="return false;"><IMG class="dead" src="' + Players[count].myName + '.jpg"  alt="&#9812;"></A>';
        }
    }else if (theStyle == 'Basic'){
        if (Players[count].alive ){
            if (Players[count].hasTreasure){
                message = '&#9820;';
            }else{
                message = '&#9820;';
            }
        }else if (!Players[count].alive ){
            message = '&#9812;';
        }
    }
    return message;
}

function getDragonSymbolx(){
    var message = '';
    if (theStyle == 'Neverwinter'){
        message = '<A HREF="#fake" onclick="return false;"><img class="alive" src="nwn_rdd.jpg"  alt="&#9822;"></a>';
    }else if (theStyle == 'Basic'){
       message = '&#9822;';
    }
    return message;
}


function getPlayerSymbolx(count, box ){
    var message = '';
    if (theStyle == 'Neverwinter'){
        if (Players[count].alive && Players[count].x == box.x && Players[count].y == box.y ){
            if (Players[count].hasTreasure){
                message = '<A HREF="#fake" onclick="return false;"><IMG class="rich" src="' + Players[count].myName + '.jpg"  alt="' + Players[count].myName + ' is Rich"></A>';
            }else{
                message = '<A HREF="#fake" onclick="return false;"><IMG class="alive" src="' + Players[count].myName + '.jpg"  alt="' + Players[count].myName + ' is Alive"></A>';
            }
        }else if (!Players[count].alive  && Players[count].x == box.x && Players[count].y == box.y ){
            message = '<A HREF="#fake" onclick="return false;"><IMG class="dead" src="' + Players[count].myName + '.jpg"  alt="' + Players[count].myName + ' is Dead"></A>';
        }
    }else if (theStyle == 'Basic'){
        if (Players[count].alive && Players[count].x == box.x && Players[count].y == box.y ){
            if (Players[count].hasTreasure){
                message = '&#9820;';
            }else{
                message = '&#9820;';
            }
        }else if (!Players[count].alive  && Players[count].x == box.x && Players[count].y == box.y ){
            message = '&#9812;';
        }
    }
    return message;
}






// set a wall to visible and to a given color                                        
function call_wallvis(segment, sid) {
	var oDiv1 = document.getElementById(sid);
	if (oDiv1 != null){
		if (segment == 'floor'){//floor
            oDiv1.setAttribute("class", "floor");
			//oDiv1.style.backgroundColor = 'gray';
			//oDiv1.style.background = 'url(bgtexture_3_dark.gif)';
			//oDiv1.style.visibility = 'visible';
		}else if (segment == 'wall'){//wall
			oDiv1.setAttribute("class", "wall");
            //    style.backgroundColor = 'wall';
			//oDiv1.style.background = 'url(bgtexture_3_pale.gif)';
			//oDiv1.style.visibility = 'visible';
		}else if (segment == 'hide'){// unknown
            oDiv1.setAttribute("class", "unknown");
            //style.backgroundColor = 'black';
            //oDiv1.style.background = 'url(black.gif)';
	  }
  }
}// END FUNCTION ***********************


//hide a wall
function call_wallhide(sid) {
	var oDiv1 = document.getElementById(sid);
	if (oDiv1 != null){
        oDiv1.setAttribute("class", "unknown");
		//oDiv1.style.backgroundColor = 'gold';
		//oDiv1.style.background = 'url(bgtexture_3_dark.gif)';
	}
}// END FUNCTION ***********************

function set_over_small_button(evt){
	var thisBox;
	if (!evt) {
		evt = event;
		thisBox = evt.srcElement;
	} else {
		thisBox = evt.target;
	} 
	//alert('over' + thisBox.id);
	thisBox.style.width='90px';
	thisBox.style.height='14px';
	thisBox.style.zIndex='100';
	thisBox.style.color = 'black';
	thisBox.style.backgroundColor = 'white';
}

function set_out_small_button(evt){
	//window.status = '';
		var thisBox;
	if (!evt) {
		evt = event;
		thisBox = evt.srcElement;
	} else {
		thisBox = evt.target;
	} 
	thisBox.style.width='16px';
	thisBox.style.height='16px';
	thisBox.style.zIndex='10';
	thisBox.style.color = 'silver';
	thisBox.style.backgroundColor = 'silver';
}

function set_over_button(evt){
	var thisBox;
	if (!evt) {
		evt = event;
		thisBox = evt.srcElement;
	} else {
		thisBox = evt.target;
	} 
	//alert('over' + thisBox.id);
	//window.status = 'Maximize Controls Panel';
	thisBox.style.backgroundColor = 'white';
}


function set_down_button(evt){
	var thisBox;
	if (!evt) {
		evt = event;
		thisBox = evt.srcElement;
	} else {
		thisBox = evt.target;
	} 
	//var str = thisBox.style.borderStyle;
	//alert('border=' + thisBox.style.borderStyle);
	thisBox.style.borderStyle = 'inset';
}

function set_up_button(evt){
	//window.status = '';
	var thisBox;
	if (!evt) {
		evt = event;
		thisBox = evt.srcElement;
	} else {
		thisBox = evt.target;
	} 
	//var str = '3px outset red';// + thisBox.style.backgroundColor + ';'
	//alert('border=' + thisBox.style.borderStyle);
	thisBox.style.borderStyle = 'outset';
}

function set_out_button(evt){
	//window.status = '';
		var thisBox;
	if (!evt) {
		evt = event;
		thisBox = evt.srcElement;
	} else {
		thisBox = evt.target;
	} 
	thisBox.style.backgroundColor = 'silver';
}

function set_onFocus_button(evt){
	//window.status = '';
	var thisBox;
	if (!evt) {
		evt = event;
		thisBox = evt.srcElement;
	} else {
		thisBox = evt.target;
	} 
	thisBox.style.backgroundColor = 'silver';
}

function set_onBlur_button(evt){
	//window.status = '';
	var thisBox;
	if (!evt) {
		evt = event;
		thisBox = evt.srcElement;
	} else {
		thisBox = evt.target;
	} 
	thisBox.style.backgroundColor = 'silver';
}


function setDragonIcon(){ set_icon('Dragon');}
function setRemoveIcon(){ rem_icon('Dragon');}
function setTreasureIcon(){ set_icon('treasure');}
function setRemoveIcon(){ rem_icon('treasure');}
function showWelcome(){ 
	var messages = document.getElementById('messages');
	var thediv = document.getElementById('Welcome');
	messages.innerHTML = thediv.innerHTML;
	set_visible('messages', 'visible');
}
function showRules(){
	var messages = document.getElementById('messages');
	var thediv = document.getElementById('playinstructions');
	messages.innerHTML = thediv.innerHTML;
	set_visible('messages', 'visible');
}
function showAbout(){ 
	var messages = document.getElementById('messages');
	var thediv = document.getElementById('About');
	messages.innerHTML = thediv.innerHTML;
	set_visible('messages', 'visible');
}

function showMessages(str){ 
	var messages = document.getElementById('messages');
	var thediv = document.getElementById('str');
	messages.innerHTML = thediv.innerHTML;
	set_visible('messages', 'visible');
}


//attach event handlers to all div.box
function attachHandlers() {
	//get viewport size and set myframe size
	var theframe = document.getElementById("myframe");
    var myWidth = 0;
    var myHeight = 0;
	if(typeof window.innerWidth != 'undefined'){
		 myWidth  = window.innerWidth;
		 myHeight = window.innerHeight;
	}else{
		 myWidth = document.body.offsetWidth;
		 MyHeight = myWidth;
	}//OnTurn == NumPlayers
	if (myWidth > myHeight){
		myWidth = myHeight;
	}
	LABYRINTH_WIDTH = (myWidth * 0.9) + 'px';
	//setSize();
	var theElements = document.getElementsByTagName("div");
	for (var loop = 0; loop < theElements.length; loop++) {
		if (theElements[loop].className == "box" ||
            theElements[loop].className == "P1HOME" ||
            theElements[loop].className == "P2HOME" ||
            theElements[loop].className == "DRHOME") {
			theElements[loop].onclick = click_On_Box;
		}
	}
	theSide = document.getElementById("Square_Size");
    theSide.onchange = repaint;

	theSide = document.getElementById("cancel");
	theSide.onclick = hide_newgameoptions;
	theSide.onmouseover = set_over_button;
	theSide.onmouseout = set_out_button;
	theSide.onmousedown = set_down_button;
	theSide.onmouseup = set_up_button;
	
	theSide = document.getElementById("new");
	theSide.onclick = show_newgameoptions;
	theSide.onmouseover = set_over_button;
    theSide.onmouseout = set_out_button;
	theSide.onmousedown = set_down_button;
	theSide.onmouseup = set_up_button;

	theSide = document.getElementById("startnew");
	theSide.onclick = new_game;
	theSide.onmouseover = set_over_button;
	theSide.onmouseout = set_out_button;
	theSide.onmousedown = set_down_button;
	theSide.onmouseup = set_up_button;
	
	theSide = document.getElementById("end");
	theSide.onclick = end_turn;
	theSide.onmouseover = set_over_button;
	theSide.onmouseout = set_out_button;
	theSide.onmousedown = set_down_button;
	theSide.onmouseup = set_up_button;
	
	theSide = document.getElementById("bDragonIcon");
	theSide.onmouseover = set_over_button;
	theSide.onmouseout = set_out_button;
	theSide.onclick = setDragonIcon;
	theSide.onmousedown = set_down_button;
	theSide.onmouseup = set_up_button;
	
	theSide = document.getElementById("bTreasureIcon");
	theSide.onmouseover = set_over_button;
	theSide.onmouseout = set_out_button;
	theSide.onclick = setTreasureIcon;
	theSide.onmousedown = set_down_button;
    theSide.onmouseup = set_up_button;
	
	theSide = document.getElementById("bRemoveDragonIcon");
	theSide.onmouseover = set_over_button;
	theSide.onmouseout = set_out_button;
	theSide.onclick = remDragonIcon;
	theSide.onmousedown = set_down_button;
	theSide.onmouseup = set_up_button;
	
	theSide = document.getElementById("bRemoveTreasureIcon");
	theSide.onmouseover = set_over_button;
	theSide.onmouseout = set_out_button;
	theSide.onclick = remTreasureIcon;	
	theSide.onmousedown = set_down_button;
	theSide.onmouseup = set_up_button;
	
	theSide = document.getElementById("bShowTitle");
	theSide.onmouseover = set_over_button;
	theSide.onmouseout = set_out_button;
	theSide.onclick = showWelcome;
	theSide.onmousedown = set_down_button;
	theSide.onmouseup = set_up_button;
	
	theSide = document.getElementById("bShowAbout");
	theSide.onmouseover = set_over_button;
	theSide.onmouseout = set_out_button;
	theSide.onclick = showAbout;
	theSide.onmousedown = set_down_button;
	theSide.onmouseup = set_up_button;
	
	theSide = document.getElementById("bShowLabyrinth");
	theSide.onmouseover = set_over_button;
	theSide.onmouseout = set_out_button;
	theSide.onclick = paint_labyrinth;
	theSide.onmousedown = set_down_button;
	theSide.onmouseup = set_up_button;
	
	theSide = document.getElementById("bShowDragon");
	theSide.onmouseover = set_over_button;
	theSide.onmouseout = set_out_button;
	theSide.onclick = show_Dragon;
	theSide.onmousedown = set_down_button;
	theSide.onmouseup = set_up_button;
	
	theSide = document.getElementById("bShowTreasure");
	theSide.onmouseover = set_over_button;
	theSide.onmouseout = set_out_button;
	theSide.onclick = show_Treasure;
	theSide.onmousedown = set_down_button;
	theSide.onmouseup = set_up_button;
	
	theSide = document.getElementById("bShowRules");
	theSide.onmouseover = set_over_button;
	theSide.onmouseout = set_out_button;
	theSide.onclick = showRules;
	theSide.onmousedown = set_down_button;
	theSide.onmouseup = set_up_button;
}// END FUNCTION ***********************


//draw the labyrinth onto the board div
function draw_labyrinth(){
  //alert("draw " + numLabs++);
	//first delete all box, wall and post divs
	var myBoard = document.getElementById("board");
	if (myBoard != null){
		myBoard.parentNode.removeChild(myBoard);
	}
	var myIFrame = document.getElementById("innerframe");	
	myBoard = document.createElement('div');	
	myBoard.className = 'board';
	myBoard.id = 'board';
	var myBoardWidth = ((MAXROW * BOX_SIZE) + (5 * (MAXROW-1)) );
	myBoard.style.width  = ((MAXROW * BOX_SIZE) + (5 * (MAXROW-1)) ) + 'px';
	myBoard.style.height = ((MAXCOL * BOX_SIZE) + (5 * (MAXCOL-1)) ) + 'px';
	myIFrame.appendChild(myBoard);

	//now it needs to draw the rooms and intersplice the walls and posts
	var divname = null;
	var mydiv = null;
	mydiv = document.createElement('div');
	mydiv.className = 'floater';
	mydiv.id = 'floater';
	mydiv.style.width = BOX_SIZE + 'px';
	mydiv.style.height = BOX_SIZE + 'px';
	mydiv.style.visibility = 'hidden';
	mydiv.style.top = '1px';
	mydiv.style.left = '1px';
	myBoard.appendChild(mydiv);
	//alert('BOX_SIZE=' + BOX_SIZE + ' floater width=' + mydiv.style.width + ' height=' + mydiv.style.height);
	
	//draw the MAXROW row on the top of the board
	for ( var yloop = 0; yloop < MAXROW; yloop++){
		for ( var xloop = 0; xloop < MAXCOL; xloop++){
			divname = 'b_' + (xloop+1) + '_' + (yloop+1);
			mydiv = document.createElement('div');
			mydiv.className = 'box';
			mydiv.id = divname;
			mydiv.style.width = BOX_SIZE + 'px';
			mydiv.style.height = BOX_SIZE + 'px';
			mydiv.style.top = (myBoardWidth - ( ((yloop + 1) * BOX_SIZE) + (yloop * 5))) + 'px'; 
			mydiv.style.left = (xloop * BOX_SIZE + (xloop * 5)) + 'px';
			myBoard.appendChild(mydiv);
			if (xloop < MAXCOL-1){
				mydiv = document.createElement('div');
				mydiv.className = 'vertical_wall';
				mydiv.id = 'vw_b_' + (xloop+1) + '_' + (yloop+1);
				mydiv.style.width = '5px';
				mydiv.style.height = BOX_SIZE + 'px';
				mydiv.style.top = (myBoardWidth - ( ((yloop + 1) * BOX_SIZE) + (yloop * 5))) + 'px'; 
				mydiv.style.left = ((xloop+1) * BOX_SIZE + (xloop * 5)) + 'px';
				myBoard.appendChild(mydiv);
			}else{
				if (yloop < MAXROW-1){
					for ( var xloop2 = 0; xloop2 < MAXCOL; xloop2++){
						divname = 'hw_b_' + (xloop2+1) + '_' + (yloop+1);
						//myLabyrinth[divname]
						mydiv = document.createElement('div');
						mydiv.className = 'horizontal_wall';
						mydiv.id = divname;
						mydiv.style.width = BOX_SIZE + 'px';
						mydiv.style.height = '5px';
						mydiv.style.top = (myBoardWidth - ( ((yloop + 1) * BOX_SIZE) + ((yloop+1) * 5))) + 'px';
						mydiv.style.left = (xloop2 * BOX_SIZE + (xloop2 * 5)) + 'px';
						myBoard.appendChild(mydiv);
						if (xloop2 < MAXCOL-1){
							mydiv = document.createElement('div');
							mydiv.className = 'post';
							mydiv.style.width = '5px';
							mydiv.style.height = '5px';
							mydiv.style.top = (myBoardWidth - ( ((yloop + 1) * BOX_SIZE) + ((yloop+1) * 5))) + 'px';						   
							mydiv.style.left = ((xloop2+1) * BOX_SIZE + (xloop2 * 5)) + 'px';
							myBoard.appendChild(mydiv);
						}	
					}
				}
			}
		}
	}
	myBoard.style.visibility = 'visible';
}// END FUNCTION ***********************


//paint the maze walls for the cheat
function paint_labyrinth(){
	for ( var yloop = 1; yloop < (MAXROW + 1); yloop++){
		for ( var xloop = 1; xloop < (MAXCOL + 1); xloop++){
      myLabyrinth['b_' + xloop + '_' + yloop].paint();
			if ( myLabyrinth['b_' + xloop + '_' + yloop].north == true){
				call_wallvis('wall', "hw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x +  '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
				}else{
				call_wallvis('floor',  "hw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x +  '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
				}

			if ( myLabyrinth['b_' + xloop + '_' + yloop].east == true){
				call_wallvis('wall', "vw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x  + '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
				}else{
				call_wallvis('floor',  "vw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x +  '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
				}
    }
	}
}	// END FUNCTION ***********************

//repaint the maze walls after a  setSize 
function repaint_labyrinth(){
	for ( var yloop = 1; yloop < (MAXROW + 1); yloop++){
		for ( var xloop = 1; xloop < (MAXCOL + 1); xloop++){
      myLabyrinth['b_' + xloop + '_' + yloop].paint();

			if ( myLabyrinth['b_' + xloop + '_' + yloop].north == true && myLabyrinth['b_' + xloop + '_' + yloop].fnorth == true){
				call_wallvis('wall', "hw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x +  '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
			}else if (myLabyrinth['b_' + xloop + '_' + yloop].fnorth == true){
     		call_wallvis('floor',  "hw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x +  '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
      }else{
				call_wallvis('hide',  "hw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x +  '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
			}
			if ( myLabyrinth['b_' + xloop + '_' + yloop].east == true && myLabyrinth['b_' + xloop + '_' + yloop].feast == true){
				call_wallvis('wall', "vw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x  + '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
				}else if (myLabyrinth['b_' + xloop + '_' + yloop].feast == true){
				  call_wallvis('floor', "vw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x + '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
        }else{
  				call_wallvis('hide', "vw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x + '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
				}
		myLabyrinth['b_' + xloop + '_' + yloop].paint();
    }
	}
}	// END FUNCTION ***********************

//clear the maze walls
function clear_labyrinth(){
	for ( var yloop = 1; yloop < (MAXROW + 1); yloop++){
		for ( var xloop = 1; xloop < (MAXCOL + 1); xloop++){
			if ( myLabyrinth['b_' + xloop + '_' + yloop].south == true){
				call_wallhide("hw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x +  '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
				}else{
				call_wallhide("hw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x +  '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
				}
			if ( myLabyrinth['b_' + xloop + '_' + yloop].north == true){
				call_wallhide("hw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x  + '_' + (myLabyrinth['b_' + xloop + '_' + yloop].y + 1));
				}else{
				call_wallhide("hw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x +  '_' + (myLabyrinth['b_' + xloop + '_' + yloop].y + 1));
				}
			if ( myLabyrinth['b_' + xloop + '_' + yloop].east == true){
				call_wallhide("vw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x  + '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
				}else{
				call_wallhide("vw_b_" + myLabyrinth['b_' + xloop + '_' + yloop].x +  '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
				}
			if ( myLabyrinth['b_' + xloop + '_' + yloop].west == true){
				call_wallhide("vw_b_" + (myLabyrinth['b_' + xloop + '_' + yloop].x - 1) + '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
				}else{
				call_wallhide("vw_b_" + (myLabyrinth['b_' + xloop + '_' + yloop].x - 1) + '_' + myLabyrinth['b_' + xloop + '_' + yloop].y);
				}
			postDebugMessage(myLabyrinth['b_' + xloop + '_' + yloop].setid, 'b_' + xloop + '_' + yloop, true);
			postMessage('', 'b_' + xloop + '_' + yloop, true);
			call_wallvis('gray', 'b_' + xloop + '_' + yloop);
		}
	}
}	// END FUNCTION ***********************





//make messageboard invisiblity, vis = 'visible' or 'hidden'
function set_visible(divname, vis){
	var oDiv1 = document.getElementById(divname);
	oDiv1.style.visibility = vis;
}// END FUNCTION ***********************

// post the message myString to the div divname,
// if overwrite == true then overwrite, otherwise concatenate
// if overwrite == true && ontop == true then the new message appears on the top of the other messages
// ontop and overwrite are true by default
function postMessage(myString, divname, overwrite, ontop){
	var oDiv1 = document.getElementById(divname);
    if (typeof(overwrite) == "undefined"){  overwrite = true;}
    if (typeof(ontop) == "undefined"){  ontop = true;}
		if (oDiv1 != null){
      var fulltext = ""; 
			if (overwrite == true){
			  fulltext = myString;
			}else{
        if (ontop == true){
          fulltext = myString + '<br/>' + oDiv1.innerHTML;
        }else{
					fulltext = oDiv1.innerHTML + '<br/>' + myString;
				}
      }
    }
		oDiv1.innerHTML = fulltext;
}// END FUNCTION ***********************


// post a debug message myString to the div debug 
// if overwrite == true then overwrite, otherwise concatenate 
// if overwrite == true && ontop == true then the new message appears on the top of the other messages
function postDebugMessage(myString, overwrite, ontop){
  if (DEBUG){
	  var divname = 'debug';
  	var oDiv1 = document.getElementById(divname);
    if (overwrite == "undefined"){  overwrite = true;}
    if (ontop == "undefined"){  ontop = true;}
    if (oDiv1 != null){
      var fulltext = ""; 
  	  if (overwrite == true){
	  	  fulltext = myString;
		  }else{
        if (ontop == true){
          fulltext = myString + '<br/>' + oDiv1.innerHTML;
        }else{
	  			fulltext = oDiv1.innerHTML + '<br/>' + myString;
		  	}
      }
    }
  	oDiv1.innerHTML = fulltext;
	}//end if DEBUG
}// END FUNCTION ***********************


function getBoxIDfromInt(num){
	if (typeof num  == 'undefined' || num < 1){ 
		//alert('failed num=' + num);
		return 'fail';
		}
	var y = Math.ceil(num/MAXROW);
	var x = num % MAXCOL;
	if (x == 0) x = MAXCOL;
	//if boxes started at b_0_0 instead of b_1_1 I could just use
	//y = Math.floor(num/MAXROW);
	//x = num % MAXCOL;
	var box = 'b_' + x + '_' + y;
	//alert('box=' + box);
	return box;
}


//reinitialize the labyrinth
function reinit_labyrinth(){
  myLabyrinth = null;
  myStack = null;
  myStack = [];
  myLabyrinth = new Labyrinth();
}// END FUNCTION ***********************

// init, carve and paint
function init_carve_paint(){
	reinit_labyrinth();
	//MAXHALL = Math.round(Math.random()) + 3;
	//postDebugMessage('maxhall = ' + MAXHALL, 'messages');
	carve_labyrinth();
	//paint_labyrinth();
}// END FUNCTION ***********************


//start a new game
function new_game(){
	GameOver = true;
	BEGAN_TURN = false;
	GAMECOUNT++;
    specialcells = null;
    specialcells = []
    myStack = null;
    myStack = [];
	//alert('selected value is ' + LABYRINTH_WIDTH);
	var myarray = document.getElementById('NumPlayers');
	NumPlayers = parseInt(myarray.options[myarray.selectedIndex].getAttribute("value"));
	var Dragonarray = document.getElementById('DragonVis');
	if (Dragonarray.options[Dragonarray.selectedIndex].getAttribute("value") == 'Yes'){
		DragonVis = true;
	}else{
		DragonVis = false;
	}
    setSize();
	BOOL = false;
	NUMLOOPS = 2 + Math.floor((MAXROW - 8)/2);  //2 for an 8x8, 
	init_carve_paint();
	MoveType = -99;
	tempMoveType = 0;	
	OnTurn = 0;
	GameOver = false;
	Players = new Array();
	while (OnTurn < NumPlayers){	
		Players[OnTurn] = new Player();
		Players[OnTurn].pRefresh(OnTurn);
		OnTurn++;
	}
	Players[OnTurn] = new Dragon();
	Players[OnTurn].mRefresh();
	postMessage('No', 'awakesp');
	TheTreasure.tRefresh();
	Icons[0] = new Icon();
	Icons[0].myName = 'T';
	Icons[1] = new Icon();
	Icons[1].myName = 'M';
	OnTurn = 0;
	MoveType = 0;	
	postDebugMessage('DEBUG MESSAGES', 'debug', true);		
    draw_labyrinth();
    clearMessages();
	attachHandlers();
	//setSize(true);
}// END FUNCTION ***********************

function clearMessages(){
    var thediv = document.getElementById("onmovesp");
	thediv.innerHTML = '';
    thediv = document.getElementById("movesleftsp");
	thediv.innerHTML = '';
    thediv = document.getElementById("hastreasuresp");
	thediv.innerHTML = 'In Lair';
    thediv = document.getElementById("awakesp");
	thediv.innerHTML = 'Asleep';
    thediv = document.getElementById("bmessageboard");
	thediv.innerHTML = '';
    thediv = document.getElementById("pmessageboard");
	thediv.innerHTML = '';
}


//set the initial place of the player
function set_player(){
	//find player whose turn it is and set their safe square
}// END FUNCTION ***********************


//select the icon to be placed on the player clicked square	
function set_icon(str_name){
	if (str_name == 'treasure'){
		MoveType = 2;
	}else if (str_name == 'Dragon'){
		MoveType = 3;
	}
}// END FUNCTION ***********************


function remDragonIcon(str){
	rem_Icon('Dragon');
}

function remTreasureIcon(str){
	rem_Icon('Treasure');
}

function rem_Icon(str){
	var icon;
	if (str == 'Treasure'){	icon = 0;}else{	icon = 1;}
	Icons[icon].remIcon();
}

function getAllSheets() {
	if( !window.ScriptEngine && navigator.__ice_version ) { return document.styleSheets; }
	if( document.getElementsByTagName ) { var Lt = document.getElementsByTagName('link'), St = document.getElementsByTagName('style');
	} else if( document.styleSheets && document.all ) { var Lt = document.all.tags('LINK'), St = document.all.tags('STYLE');
	} else { return []; } for( var x = 0, os = []; Lt[x]; x++ ) {
		var rel = Lt[x].rel ? Lt[x].rel : Lt[x].getAttribute ? Lt[x].getAttribute('rel') : '';
		if( typeof( rel ) == 'string' && rel.toLowerCase().indexOf('style') + 1 ) { os[os.length] = Lt[x]; }
	} for( var x = 0; St[x]; x++ ) { os[os.length] = St[x]; } return os;
}

function changeStyle(mystyle) {
    theStyle = mystyle;
	window.userHasChosen = window.MWJss;
	for( var x = 0, ss = getAllSheets(); ss[x]; x++ ) {
		if( ss[x].title ) { ss[x].disabled = true; }
		for( var y = 0; y < arguments.length; y++ ) { if( ss[x].title == arguments[y] ) { ss[x].disabled = false;  } }
    }
    repaintSprites();
}

// *************** create objects and handlers **************
//create the Labyrinth 
var myLabyrinth;
var specialcells = null;
specialcells = [];

//myLabyrinth = new Labyrinth(); 
var myStack = null;
myStack = [];
window.onload = attachHandlers;


*/
