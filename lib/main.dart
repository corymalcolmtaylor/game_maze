import 'package:flutter/material.dart';
import 'dart:math' as Math;
import 'maze.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final title = 'Alice in The Hedge Maze';
    final numberRows = 8;
    Maze maze = Maze(numberRows);
    maze.carveLabyrinth();

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
        body: MazeArea(maze),
      ),
    );
  }
}

class MazeArea extends StatefulWidget {
  final Maze maze;

  MazeArea(this.maze);

  @override
  _MazeAreaState createState() => _MazeAreaState();
}

class _MazeAreaState extends State<MazeArea>
    with SingleTickerProviderStateMixin {
  var pixies = <Widget>[];
  var wallThickness = 2.0;
  var roomLength = 0.0;
  var maxWidth = 0.0;
  var rand = Math.Random.secure();
  var numRows = 8;
  var gameIsOver = false;

  @override
  void initState() {
    super.initState();
  }

  Widget getAnimatedPixieIcon(Room room) {
    var endTop = 0.0;
    var endLeft = 0.0;

    if (widget.maze.minotaur.location == 'b_${room.x}_${room.y}') {
      endTop = ((widget.maze.minotaur.y - 1) * roomLength) +
          (2 * widget.maze.minotaur.y) -
          4;
      endLeft = ((widget.maze.minotaur.x - 1) * roomLength) +
          (2 * widget.maze.minotaur.x);

      return AnimatedPositioned(
        key: Key(widget.maze.minotaur.key),
        left: endLeft,
        top: endTop,
        curve: Curves.linear,
        duration: Duration(milliseconds: 900),
        child: Text(
          widget.maze.minotaur.emoji,
          style: TextStyle(color: Colors.black, fontSize: roomLength - 8),
        ),
      );
    }

    if (widget.maze.player.location == 'b_${room.x}_${room.y}') {
      endTop = ((widget.maze.player.y - 1) * roomLength) +
          (2 * widget.maze.player.y) -
          4;

      endLeft = ((widget.maze.player.x - 1) * roomLength) +
          (2 * widget.maze.player.x);

      return AnimatedPositioned(
        key: Key(widget.maze.player.key),
        left: endLeft,
        top: endTop,
        duration: Duration(milliseconds: 900),
        child: Text(
          widget.maze.player.emoji,
          style: TextStyle(color: Colors.black, fontSize: roomLength - 6),
        ),
      );
    }
    var lamb = widget.maze.lambs.firstWhere(
        (el) => el.location == 'b_${room.x}_${room.y}',
        orElse: () => null);

    if (lamb != null) {
      endTop = ((lamb.y - 1) * roomLength) + (2 * lamb.y);
      endLeft = ((lamb.x - 1) * roomLength) + (2 * lamb.x);
      // endTop = endTop * 0.99;

      return AnimatedPositioned(
        key: Key(lamb.key),
        left: endLeft,
        top: endTop,
        duration: Duration(milliseconds: 900),
        child: Text(
          lamb.emoji,
          style: TextStyle(color: Colors.black, fontSize: roomLength - 12),
        ),
      );
    }

    return null;
  }

  Widget getRoomPixieIcon(Room room) {
    if (widget.maze.minotaur.location == 'b_${room.x}_${room.y}') {
      return Center(
        child: Text(
          widget.maze.minotaur.emoji,
          style: TextStyle(color: Colors.black, fontSize: roomLength - 12),
        ),
      );
    }
    if (widget.maze.player.location == 'b_${room.x}_${room.y}') {
      return Center(
        child: Text(
          widget.maze.player.emoji,
          style: TextStyle(color: Colors.black, fontSize: roomLength - 12),
        ),
      );
    }
    var lamb = widget.maze.lambs.firstWhere(
        (el) => el.location == 'b_${room.x}_${room.y}',
        orElse: () => null);

    if (lamb != null) {
      return Center(
        child: Text(
          lamb.emoji,
          style: TextStyle(color: Colors.black, fontSize: roomLength - 16),
        ),
      );
    }
    lamb = widget.maze.lambs.firstWhere(
        (el) => el.lastLocation == 'b_${room.x}_${room.y}',
        orElse: () => null);

    return null;
  }

  void computerMove() {
    moveMinotaur();
    moveLambs();
    widget.maze.player.movesLeft = widget.maze.playerMoves;
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

          if (tryToMovePlayerToXY(widget.maze.player, room.x, room.y)) {
            print('moved there');
            if (widget.maze.player.movesLeft == 0) {
              setState(() {
                computerMove();
              });
            }
          } else {
            print('cannot move there');
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
    if (widget.maze.movePixie(pix, dir)) {
      if (pix.ilk != Ilk.lamb && widget.maze.killLambInRoom(pix)) {
        if (pix.ilk == Ilk.minotaur) {
          print('killed a lamb');
          widget.maze.player.lostLambs++;
          widget.maze.minotaur.movesLeft = 0;
        }
        if (pix.ilk == Ilk.player) {
          print('saved a lamb');
          widget.maze.player.savedLambs++;
          widget.maze.player.movesLeft = 0;
        }
      }
      if (pix.ilk == Ilk.lamb) {
        if (pix.location == widget.maze.player.location) {
          widget.maze.saveLamb(pix);
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
    while (widget.maze.minotaur.movesLeft > 0) {
      if (moved == false) {
        dir = rand.nextInt(4);
      }
      if (tryToMove(widget.maze.minotaur, dir, 0)) {
        moved = true;
        print(
            'mino moved to ${widget.maze.minotaur.x} ${widget.maze.minotaur.y}');
      } else {
        print('failed to move in that dir');
        //if moved and then failed to move-- then end minotaurs turn
        if (moved) {
          widget.maze.minotaur.movesLeft = 0;
        }
      }
    }
    widget.maze.minotaur.movesLeft = widget.maze.maxRow;
    return moved;
  }

  bool moveLambs() {
    if (gameIsOver) return false;
    widget.maze.lambs.forEach((lamb) {
      if (lamb.living == Status.alive) {
        tryToMove(lamb, rand.nextInt(4), 0);
      }
    });
    var anyLeftAlive =
        widget.maze.lambs.any((lamb) => lamb.living == Status.alive);
    if (!anyLeftAlive) {
      return endGame();
    }
    return true;
  }

  bool endGame() {
    gameIsOver = true;
    Text message;
    if (widget.maze.player.savedLambs > widget.maze.player.lostLambs) {
      message = Text('You Win');
    } else {
      message = Text('You Lose');
    }
    _neverSatisfied(message);

    return false;
  }

  Future<void> _neverSatisfied(Text msg) async {
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
        ((maxWidth.floor() - (wallThickness * (widget.maze.maxRow + 1))) /
                widget.maze.maxRow)
            .floorToDouble();
  }

  @override
  Widget build(BuildContext context) {
    setSizes();
    var trs = <Row>[];

    for (int i = 1; i <= widget.maze.maxRow; i++) {
      trs.add(
        Row(
          children: List.from(
            widget.maze.myLabyrinth.entries
                .where((elroom) => elroom.value.y == i)
                .map(
                  (el) => makeRoom(el.value),
                )
                .toList(),
          ),
        ),
      );
    }
    // add pixies

    pixies = List.from(widget.maze.myLabyrinth.entries
        .map(
          (el) => getAnimatedPixieIcon(el.value),
        )
        .toList());
    pixies.removeWhere((item) => item == null);

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
                            pixies.clear();
                            widget.maze.maxRow = numRows;
                            setSizes();
                            widget.maze.initMaze();
                            widget.maze.carveLabyrinth();
                            gameIsOver = false;
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
                      child: Text(widget.maze.player.lostLambs.toString())),
                  Text('Friends Saved:'),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
                      child: Text(widget.maze.player.savedLambs.toString())),
                ],
              ),
            ),
            SizedBox(
              width: maxWidth,
              height: maxWidth,
              child: Stack(overflow: Overflow.visible, children: [
                Column(children: trs),

                // add pixies
                ...pixies
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
                                setState(() {
                                  if (gameIsOver) return;
                                  movePixie(widget.maze.player, Directions.up);
                                  if (widget.maze.player.movesLeft <= 0) {
                                    computerMove();
                                  }
                                });
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
                                  setState(() {
                                    movePixie(
                                        widget.maze.player, Directions.left);
                                    if (widget.maze.player.movesLeft <= 0) {
                                      moveMinotaur();
                                      moveLambs();
                                    }
                                  });
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
                                    setState(() {
                                      widget.maze.player.movesLeft = 0;

                                      moveMinotaur();
                                      moveLambs();

                                      print('end turn ');
                                    });
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
                                  setState(() {
                                    movePixie(
                                        widget.maze.player, Directions.right);
                                    if (widget.maze.player.movesLeft <= 0) {
                                      moveMinotaur();
                                      moveLambs();
                                    }
                                  });
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
                                  setState(() {
                                    movePixie(
                                        widget.maze.player, Directions.down);
                                    if (widget.maze.player.movesLeft <= 0) {
                                      moveMinotaur();
                                      moveLambs();
                                    }
                                  });
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
}
