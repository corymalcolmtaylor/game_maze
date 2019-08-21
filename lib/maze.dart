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
  static var badGuyHasMovedThisManyTimes = 0;
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
  var minotaursPath = 0;
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
  var delayComputerMove = true;
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
  var facing = Directions.left;
}

class Maze {
  int _maxRow;
  int _maxCol;
  bool gameIsOver = false;
  Ilk whosTurnIsIt = Ilk.player;
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
    whosTurnIsIt = Ilk.player;
    Room.badGuyHasMovedThisManyTimes = 0;
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
      player.condition = Condition.dead;
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
        } else if (boss.ilk == Ilk.player) {
          el.condition = Condition.freed;
          player.savedLambs++;
        }
        handled = true;
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
    final newloc = 'b_${x}_$y';
    if (pixie.ilk == Ilk.lamb && minotaur.location == newloc) {
      return false;
    }
    /* do not let lambs wak on each other */
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
    pixie.movesLeft--;

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
          if (!myLabyrinth[location].down) {
            return true;
          } else {
            return false;
          }
        }
        break;
      case Directions.up:
        {
          //is north wall up?
          if (!myLabyrinth[location].up) {
            return true;
          } else {
            return false;
          }
        }
        break;
      case Directions.right:
        {
          if (!myLabyrinth[location].right) {
            return true;
          } else {
            return false;
          }
        }
        break;
      case Directions.left:
        {
          if (!myLabyrinth[location].left) {
            return true;
          } else {
            return false;
          }
        }
    }
    return true;
  }

  bool moveThisPixieInThisDirection(Pixie pixie, Directions direction) {
    switch (direction) {
      case Directions.down:
        {
          //is south wall up?
          if (!myLabyrinth[pixie.location].down) {
            return movePixieToXY(pixie, pixie.x, pixie.y + 1);
          } else {
            return false;
          }
        }
        break;
      case Directions.up:
        {
          //is north wall up?
          if (!myLabyrinth[pixie.location].up) {
            return movePixieToXY(pixie, pixie.x, pixie.y - 1);
          } else {
            return false;
          }
        }
        break;
      case Directions.right:
        {
          if (!myLabyrinth[pixie.location].right) {
            return movePixieToXY(pixie, pixie.x + 1, pixie.y);
          } else {
            return false;
          }
        }
        break;
      case Directions.left:
        {
          if (!myLabyrinth[pixie.location].left) {
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
        bossGoHandleAnyLambsAtYourLocation(boss: player);
      } else {
        bossGoHandleAnyLambsAtYourLocation(boss: sprite);
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
      return playerDirection;
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
    if (myLabyrinth[room].up) walls++;
    if (myLabyrinth[room].down) walls++;
    if (myLabyrinth[room].left) walls++;
    if (myLabyrinth[room].right) walls++;
    return walls > 2;
  }

  bool roomIsAnIntersection({String room}) {
    if ((!myLabyrinth[room].left || !myLabyrinth[room].right) &&
        (!myLabyrinth[room].up || !myLabyrinth[room].down)) {
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
        if (y == maxCol + 1) return false;
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
        if (x == maxRow + 1) return false;
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
    myLabyrinth[location].minotaursPath = ++Room.badGuyHasMovedThisManyTimes;
    return myLabyrinth[location].minotaursPath;
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

    direction = changeDirectionFromBossToNearestLamb(
        boss: minotaur, direction: direction);
    if (direction != null) {
      bossCannotSeeALamb = false;
    } else {
      direction = randomDirection(location: minotaur.location);
    }

    minotaur.movesLeft = maxRow;
    int tries = 0;
    bool triedFirst = false;
    while (minotaur.movesLeft > 0) {
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

      if (bossCannotSeeALamb &&
          thereIsADeadEndFromLocationInDirection(
              location: {'x': minotaur.x, 'y': minotaur.y},
              direction: direction)) {
        minotaur.movesLeft = 0;
        continue; //try another direction
      }

      if (attemptToMoveThisPixieToAnAdjacentRoom(
          pix: minotaur, direction: direction)) {
        markMinotaursPath(location: minotaur.location);
        // 50% chance to stop on any intersection
        if (bossCannotSeeALamb && minotaurHasMovedAtLeastOnceThisTurn()) {
          if (roomIsAnIntersection(room: minotaur.location)) {
            if (rand.nextInt(2) == 0) {
              minotaur.movesLeft = 0;
              continue;
            }
            //check to see if a lamb can be seen from here
            if (direction !=
                changeDirectionFromBossToNearestLamb(
                    boss: minotaur, direction: direction)) {
              minotaur.movesLeft = 0;

              ///remember the dir the lamb was seen and use it on next turn
              ///to chase the lamb -- or not, that might make to game too hard
              continue;
            }
          }
        }
      } else {
        // if the minotaur moved and then failed to move then it has hit a wall so then end its turn
        if (minotaurHasMovedAtLeastOnceThisTurn()) {
          minotaur.movesLeft = 0;
        }
      }
    }

    return minotaurHasMovedAtLeastOnceThisTurn();
  }

  Directions randomDirection({String location}) {
    //find the dir of the accessible rooms with the lowest minotaurPath
    var index = rand.nextInt(Directions.values.length);
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
      print('1 least $least $dirx');
      if (aPixieCanMoveDirectionFromLocation(
          direction: dirx, location: location)) {
        var newLoaction =
            whatLocationIsFoundByMovingInThisDirectionFromThisPixiesLocation(
                direction: dirx, pixie: minotaur);
        print('2 least $least $dirx');
        if (myLabyrinth[newLoaction].minotaursPath < least) {
          least = myLabyrinth[newLoaction].minotaursPath;
          finalDir = dirx;
          print('3 least $least $dirx');
        }
      }
    });
    print('end least $least $finalDir');
    return finalDir;
  }

  Directions nextDirection(Directions direction) {
    return Directions.values[(direction.index + 1) % Directions.values.length];
  }

  bool moveLambs() {
    if (gameIsOver) return gameIsOver;
    lambs.forEach((lamb) {
      if (lamb.condition == Condition.alive) {
        attemptToMoveThisPixieToAnAdjacentRoom(pix: lamb);
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
    minotaur.movesLeft = maxRow;
    // minotaur.x = 8;
    //minotaur.y = 8;
    //minotaur.location = 'b_${minotaur.x}_${minotaur.y}';
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

    //player.x = 1;
    //player.y = 1;
    //player.location = 'b_${player.x}_${player.y}';
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
        lamb.emoji = '🐍';
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
        lamb.emoji = '🐈';
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
        lamb.emoji = '🦍';
        break;
      case 14:
        lamb.emoji = '🐒';
        break;
      case 15:
        lamb.emoji = '🦛';
        break;
      default:
        lamb.emoji = '🦇';
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
