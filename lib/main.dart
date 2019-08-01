import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'maze.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final title = 'Alice in The Hedge Maze';

    return MaterialApp(
      title: title,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: MazeArea(),
      ),
    );
  }
}

class MazeArea extends StatefulWidget {
  @override
  _MazeAreaState createState() {
    return _MazeAreaState();
  }
}

class _MazeAreaState extends State<MazeArea>
    with SingleTickerProviderStateMixin {
  Maze maze;
  var numRows = 8;

  var sprites = <Widget>[];
  var wallThickness = 2.0;
  var roomLength = 0.0;
  var maxWidth = 0.0;
  var rand = Math.Random.secure();

  var gameIsOver = false;

  @override
  void initState() {
    super.initState();
    maze = Maze(numRows);
    maze.carveLabyrinth();
  }

  AnimatedPositioned getAnimatedSpriteIconForBosses(Pixie pix) {
    var endTop = 0.0;
    var endLeft = 0.0;
    endTop = ((pix.y - 1) * roomLength) + (2 * pix.y) - 4;
    endLeft = ((pix.x - 1) * roomLength) + (2 * pix.x);

    if (pix.ilk == Ilk.minotaur) {
      return AnimatedPositioned(
        key: Key(maze.minotaur.key),
        left: endLeft,
        top: endTop,
        curve: Curves.linear,
        duration: Duration(milliseconds: 900),
        child: Text(
          maze.minotaur.emoji,
          style: TextStyle(color: Colors.black, fontSize: roomLength - 8),
        ),
      );
    }

    if (pix.ilk == Ilk.player) {
      return AnimatedPositioned(
        key: Key(maze.player.key),
        left: endLeft,
        top: endTop,
        duration: Duration(milliseconds: 900),
        child: Text(
          maze.player.emoji,
          style: TextStyle(color: Colors.black, fontSize: roomLength - 6),
        ),
      );
    }
    return null;
  }

  List<AnimatedPositioned> getAnimatedSpriteIconsForLambs(Room room) {
    var endTop = 0.0;
    var endLeft = 0.0;
    List<AnimatedPositioned> icons = [];

    if (false && maze.minotaur.location == 'b_${room.x}_${room.y}') {
      endTop = ((maze.minotaur.y - 1) * roomLength) + (2 * maze.minotaur.y) - 4;
      endLeft = ((maze.minotaur.x - 1) * roomLength) + (2 * maze.minotaur.x);

      icons.add(
        AnimatedPositioned(
          key: Key(maze.minotaur.key),
          left: endLeft,
          top: endTop,
          curve: Curves.linear,
          duration: Duration(milliseconds: 900),
          child: Text(
            maze.minotaur.emoji,
            style: TextStyle(color: Colors.black, fontSize: roomLength - 8),
          ),
        ),
      );
    }

    if (false && maze.player.location == 'b_${room.x}_${room.y}') {
      endTop = ((maze.player.y - 1) * roomLength) + (2 * maze.player.y) - 4;
      endLeft = ((maze.player.x - 1) * roomLength) + (2 * maze.player.x);

      icons.add(
        AnimatedPositioned(
          key: Key(maze.player.key),
          left: endLeft,
          top: endTop,
          duration: Duration(milliseconds: 900),
          child: Text(
            maze.player.emoji,
            style: TextStyle(color: Colors.black, fontSize: roomLength - 6),
          ),
        ),
      );
    }
    var lambs = maze.lambs.where(
      (el) => el.location == 'b_${room.x}_${room.y}',
    );

    if (lambs != null) {
      lambs.forEach((lamb) {
        endTop = ((lamb.y - 1) * roomLength) + (2 * lamb.y);
        endLeft = ((lamb.x - 1) * roomLength) + (2 * lamb.x);

        icons.add(
          AnimatedPositioned(
            key: Key(lamb.key),
            left: endLeft,
            top: endTop,
            duration: Duration(milliseconds: 900),
            child: Text(
              lamb.emoji,
              style: TextStyle(color: Colors.black, fontSize: roomLength - 12),
            ),
          ),
        );
      });
    }

    return icons;
  }

  void computerMove() {
    setState(() {
      moveMinotaur();
    });
    setState(() {
      moveLambs();
    });

    maze.player.movesLeft = maze.playerMoves;
  }

  Widget makeRoom(Room room) {
    /*  rooms shall be changed to square containers in rows of a set width */
    var floorColor = Colors.greenAccent;
    var northColor = (room.up == true) ? Colors.green : floorColor;
    var southColor = (room.down == true) ? Colors.green : floorColor;
    var westColor = (room.left == true) ? Colors.green : floorColor;
    var eastColor = (room.right == true) ? Colors.green : floorColor;

    return Container(
      child: GestureDetector(
        onTap: () {
          print('_MazeRoomState   b_${room.x}_${room.y} tapped');
          if (gameIsOver == false) {
            if (tryToMovePlayerToXY(maze.player, room.x, room.y)) {
              setState(() {
                print('player moved to  b_${room.x}_${room.y}');
              });

              if (maze.player.movesLeft == 0) {
                computerMove();
              }
            } else {
              if (maze.player.movesLeft == 0) {
                //computerMove();
              }
              print('cannot move there');
            }
          }
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: floorColor,
            border: Border(
              bottom: BorderSide(color: southColor),
              top: BorderSide(color: northColor),
              right: BorderSide(color: eastColor),
              left: BorderSide(color: westColor),
            ),
          ),
          child: SizedBox(
            width: roomLength,
            height: roomLength,
            // child: getRoomPixieIcon(room),
          ),
        ),
      ),
    );
  }

  bool movePixie(Pixie pix, Directions dir) {
    if (maze.movePixie(pix, dir)) {
      if (pix.ilk != Ilk.lamb && maze.killLambInRoom(pix)) {}
      if (pix.ilk == Ilk.lamb) {
        if (pix.location == maze.player.location) {
          maze.saveLamb(pix);
        }
      }
      pix.movesLeft--;
      return true;
    }
    return false;
  }

  tryToMove(Pixie pix, int randint, int numberOfMoveTries) {
    bool success = false;
    while (numberOfMoveTries < 8) {
      switch (randint) {
        case 0:
          success = movePixie(pix, Directions.down);
          if (pix.ilk == Ilk.lamb) randint++;
          break;
        case 1:
          success = movePixie(pix, Directions.up);
          if (pix.ilk == Ilk.lamb) randint++;
          break;
        case 2:
          success = movePixie(pix, Directions.right);
          if (pix.ilk == Ilk.lamb) randint++;
          break;
        case 3:
          success = movePixie(pix, Directions.left);
          if (pix.ilk == Ilk.lamb) randint = 0;
      }
      if (success) return true;
      if (pix.ilk == Ilk.minotaur) return false;
      numberOfMoveTries++;
    }
  }

  bool tryToMovePlayerToXY(Pixie pix, int x, int y) {
    print('try to move from  ${pix.x} ${pix.y} to $x $y');

    if (x == (pix.x + 1) && y == pix.y) {
      return movePixie(pix, Directions.right);
    } else if (x == (pix.x - 1) && y == pix.y) {
      return movePixie(pix, Directions.left);
    } else if (x == (pix.x) && y == (pix.y + 1)) {
      return movePixie(pix, Directions.down);
    } else if (x == (pix.x) && y == (pix.y - 1)) {
      return movePixie(pix, Directions.up);
    }

    return false;
  }

  int directionOfSeenLamb() {
    //  no lamb seen
    return -1;
  }

  bool moveMinotaur() {
    // the minotaur moves in one direction until it gets a lamb,
    // runs into a wall or stops at an intersection of halls
    // first it charges the nearest pixie it sees (it cannot see around corners or through walls)
    // if no pixie is targeted it moves at random until it reaches a wall or an intersection
    // (there is a 50% chance it stops at an intersection unless it can now see a lamb when it will stop)

    if (gameIsOver) {
      return false;
    }
    var moved = false;
    var dir = 0;
    while (maze.minotaur.movesLeft > 0) {
      if (moved == false) {
        dir = rand.nextInt(4);
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
      var lambDir = directionOfSeenLamb();
      if (lambDir > -1) {
        dir = lambDir;
      }

      if (tryToMove(maze.minotaur, dir, 0)) {
        moved = true;
        print('mino moved to ${maze.minotaur.x} ${maze.minotaur.y}');
      } else {
        print('failed to move in that dir');
        //if moved and then failed to move-- then end minotaurs turn
        if (moved) {
          maze.minotaur.movesLeft = 0;
        }
      }
    }
    maze.minotaur.movesLeft = maze.maxRow;
    return moved;
  }

  bool moveLambs() {
    if (gameIsOver) return false;
    maze.lambs.forEach((lamb) {
      if (lamb.condition == Condition.alive) {
        tryToMove(lamb, rand.nextInt(4), 0);
      } else {
        //lamb.location = '';
      }
    });
    var anyLeftAlive =
        maze.lambs.any((lamb) => lamb.condition == Condition.alive);
    if (!anyLeftAlive) {
      return endGame();
    }
    return true;
  }

  bool endGame() {
    gameIsOver = true;
    Text message;

    message = Text(
        'Friends freed: ${maze.player.savedLambs}\nFriends lost: ${maze.player.lostLambs}');

    showGameOverMessage(message);
    print('after show dialog');

    return gameIsOver;
  }

  Future<void> showGameOverMessage(Text msg) async {
    print('ere show dialog');
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[msg],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  print('new game pressed');
                  startNewGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void setSizes() {
    maxWidth = MediaQuery.of(context).size.width;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      maxWidth = MediaQuery.of(context).size.height * 0.75;
    }
    roomLength =
        ((maxWidth.floor() - (wallThickness * (maze.maxRow + 1))) / maze.maxRow)
            .floorToDouble();
  }

  @override
  Widget build(BuildContext context) {
    setSizes();
    var trs = <Row>[];

    for (int i = 1; i <= maze.maxRow; i++) {
      trs.add(
        Row(
          children: List.from(
            maze.myLabyrinth.entries
                .where((elroom) => elroom.value.y == i)
                .map(
                  (el) => makeRoom(el.value),
                )
                .toList(),
          ),
        ),
      );
    }
    // add sprites

    var llsprites = List.from(maze.myLabyrinth.entries.map(
      (el) => getAnimatedSpriteIconsForLambs(el.value),
    ));

    sprites.clear();
    llsprites.forEach((ll) {
      sprites.addAll(ll);
    });
    sprites.add(getAnimatedSpriteIconForBosses(maze.player));
    sprites.add(getAnimatedSpriteIconForBosses(maze.minotaur));

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Text('Size of Maze'),
                  ),
                ),
                Center(
                  child: Container(
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                    child: DropdownButton<String>(
                      style: TextStyle(color: Colors.black, fontSize: 16),
                      value: numRows.toString(),
                      onChanged: (String newValue) {
                        setState(() {
                          numRows = int.parse(newValue);
                        });
                      },
                      items: <String>['8', '10', '12', '14']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                    child: Container(
                      child: OutlineButton(
                        color: Colors.amber,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        onPressed: () {
                          setState(() {
                            print('new game pressed');
                            startNewGame();
                          });
                        },
                        child: Text('New Game'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Friends Lost:'),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
                      child: Text(maze.player.lostLambs.toString())),
                  Text('Friends Saved:'),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
                      child: Text(maze.player.savedLambs.toString())),
                ],
              ),
            ),
            SizedBox(
              width: maxWidth,
              height: maxWidth,
              child: Stack(overflow: Overflow.visible, children: [
                Column(children: trs),

                // add pixies
                ...sprites
              ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Ink(
                            decoration: ShapeDecoration(
                              color: Colors.green,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              onPressed: () {
                                if (gameIsOver) return;
                                if (movePixie(maze.player, Directions.up)) {
                                  setState(() {
                                    print('player moved up');
                                  });
                                } else {
                                  maze.player.movesLeft = 0;
                                }
                                if (maze.player.movesLeft <= 0) {
                                  computerMove();
                                }
                              },
                              icon: Icon(Icons.arrow_upward),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Ink(
                            decoration: ShapeDecoration(
                              color: Colors.green,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              onPressed: () {
                                if (gameIsOver == false) {
                                  if (movePixie(maze.player, Directions.left)) {
                                    setState(() {
                                      print('player moved left');
                                    });
                                  } else {
                                    maze.player.movesLeft = 0;
                                  }
                                  if (maze.player.movesLeft <= 0) {
                                    computerMove();
                                  }
                                }
                              },
                              icon: Icon(Icons.arrow_back),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Ink(
                              decoration: ShapeDecoration(
                                color: Colors.orange,
                                shape: CircleBorder(),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  print('stay  pressed');
                                  if (gameIsOver == false) {
                                    maze.player.movesLeft = 0;
                                    computerMove();
                                    print('end turn ');
                                  }
                                },
                                icon: Icon(Icons.pause),
                              ),
                            ),
                          ),
                          Ink(
                            decoration: ShapeDecoration(
                              color: Colors.green,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              onPressed: () {
                                if (gameIsOver == false) {
                                  if (movePixie(
                                      maze.player, Directions.right)) {
                                    setState(() {
                                      print('player moved right');
                                    });
                                  } else {
                                    maze.player.movesLeft = 0;
                                  }
                                  if (maze.player.movesLeft <= 0) {
                                    computerMove();
                                  }
                                }
                              },
                              icon: Icon(Icons.arrow_forward),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Ink(
                            decoration: ShapeDecoration(
                              color: Colors.green,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              onPressed: () {
                                if (gameIsOver == false) {
                                  if (movePixie(maze.player, Directions.down)) {
                                    setState(() {
                                      print('player moved down');
                                    });
                                  } else {
                                    maze.player.movesLeft = 0;
                                  }
                                  if (maze.player.movesLeft <= 0) {
                                    computerMove();
                                  }
                                }
                              },
                              icon: Icon(Icons.arrow_downward),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void startNewGame() {
    sprites.clear();
    maze.maxRow = numRows;
    setSizes();
    maze.initMaze();
    maze.carveLabyrinth();
    gameIsOver = false;
  }
}
