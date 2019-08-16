import 'package:flutter/material.dart';

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
  int numRows = 8;
  final maximumMoveAttempts = 8;
  static const animDurationMilliSeconds = 700;

  var sprites = <Widget>[];
  final wallThickness = 2.0;
  var roomLength = 0.0;
  var maxWidth = 0.0;

  var gameIsOver = false;

  @override
  void initState() {
    super.initState();
    maze = Maze(numRows);
    maze.carveLabyrinth();
  }

  AnimatedPositioned getAnimatedSpriteIconForBosses({@required Pixie pix}) {
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
        duration: Duration(milliseconds: animDurationMilliSeconds),
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
        duration: Duration(milliseconds: animDurationMilliSeconds),
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

    var lambs = maze.lambs.where(
      (el) => el.location == 'b_${room.x}_${room.y}',
    );

    lambs.forEach((lamb) {
      endTop = ((lamb.y - 1) * roomLength) + (2 * lamb.y);
      endLeft = ((lamb.x - 1) * roomLength) + (2 * lamb.x);
      if (lamb.condition == Condition.dead) {
        lamb.emoji = '☠️';
        icons.add(
          AnimatedPositioned(
            key: Key(lamb.key),
            left: endLeft,
            top: endTop,
            duration: Duration(milliseconds: animDurationMilliSeconds),
            child: Text(
              lamb.emoji,
              style: TextStyle(color: Colors.black, fontSize: roomLength - 12),
            ),
          ),
        );
      } else if (lamb.condition == Condition.freed) {
        icons.add(
          AnimatedPositioned(
            key: Key(lamb.key),
            left: endLeft,
            top: endTop,
            duration: Duration(milliseconds: animDurationMilliSeconds),
            child: Text(
              lamb.emoji,
              style: TextStyle(color: Colors.black, fontSize: roomLength - 12),
            ),
          ),
        );
      } else {
        icons.add(
          AnimatedPositioned(
            key: Key(lamb.key),
            left: endLeft,
            top: endTop,
            duration: Duration(milliseconds: animDurationMilliSeconds),
            child: Text(
              lamb.emoji,
              style: TextStyle(color: Colors.black, fontSize: roomLength - 12),
            ),
          ),
        );
      }
    });

    return icons;
  }

  void computerMove({bool delayMove}) async {
    if (maze.gameIsOver ||
        !maze.lambs.any((lamb) => lamb.condition == Condition.alive)) {
      handleEndOfGame();
      return;
    }

    int delay = 0;
    if (delayMove) {
      delay = animDurationMilliSeconds;
    }
    Future.delayed(Duration(milliseconds: delay), () {
      maze.moveMinotaur();
      setState(() {
        // just force redraw
      });
    });

    Future.delayed(Duration(milliseconds: delay + animDurationMilliSeconds),
        () {
      var gameOver = maze.moveLambs();
      maze.lambs.forEach((lamb) {
        if (lamb.condition == Condition.dead) {
          lamb.location = '';
          lamb.lastLocation = '';
        }
      });
      setState(() {
        // just force redraw
      });

      if (gameOver) {
        handleEndOfGame();
      } else {
        preparePlayerForATurn();
      }
    });
  }

  void handleEndOfGame() {
    Text message;
    String str =
        'Friends Freed: ${maze.player.savedLambs}\nFriends Lost: ${maze.player.lostLambs}\n';
    if (maze.player.condition == Condition.dead) {
      str = str + 'The Goblin got Alice, you lost!';
    } else if (maze.player.savedLambs > maze.player.lostLambs) {
      str = str + 'You WIN!';
    } else if (maze.player.savedLambs == maze.player.lostLambs) {
      str = str + 'You Draw!';
    } else if (maze.player.savedLambs < maze.player.lostLambs) {
      str = str + 'You Lost!';
    }

    message = Text(str, style: TextStyle(fontSize: 22, color: Colors.cyan));

    showGameOverMessage(message);
  }

  void preparePlayerForATurn() {
    maze.player.movesLeft = maze.playerMoves;
    maze.player.delayComputerMove = true;
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
          if (maze.player.movesLeft <= 0) {
            return;
          }
          if (gameIsOver == false) {
            maze.lambs.forEach((lamb) {
              if (lamb.condition != Condition.alive && lamb.location != '') {
                lamb.location = '';
                lamb.lastLocation = '';
              }
            });
            if (maze.tryToMovePlayerToXY(maze.player, room.x, room.y)) {
              setState(() {
                print('player moved to  b_${room.x}_${room.y}');
              });

              if (maze.player.movesLeft == 0) {
                computerMove(delayMove: maze.player.delayComputerMove);
              }
            } else {
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
            //child: Text('${room.minotaursPath}')
            // child: getRoomPixieIcon(room),
          ),
        ),
      ),
    );
  }

  Future<void> showRules() async {
    Text message = Text(
        'Use the arrow buttons to move Alice 👧🏼 around the maze.\n' +
            'Avoid the goblin 👺 but rescue the others by getting Alice to them.\n' +
            'If the goblin likewise gets Alice you lose.\n' +
            'Once all the animals are gone if there are more that you have saved' +
            ' than have been eaten by the goblin you win, otherwise you lose.',
        style: TextStyle(fontSize: 22, color: Colors.cyan));
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          title: Text(
            'Game Play Rules',
            style: TextStyle(fontSize: 24, color: Colors.cyan),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[message],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK',
                  style: TextStyle(fontSize: 24, color: Colors.cyan)),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  print('OK showed rules');
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showGameOverMessage(Text msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          title: Text(
            'Game Over',
            style: TextStyle(fontSize: 24, color: Colors.cyan),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[msg],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK, start new Game',
                  style: TextStyle(fontSize: 24, color: Colors.cyan)),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
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

  Widget defineTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(
            child: Container(
              child: OutlineButton(
                color: Colors.amber,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
                onPressed: () {
                  setState(() {
                    showRules();
                  });
                },
                child: Text(
                  'Show Game Rules',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                    child: Text('Rows ' + value),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(
            child: Container(
              child: OutlineButton(
                color: Colors.amber,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0),
                ),
                onPressed: () {
                  setState(() {
                    startNewGame();
                  });
                },
                child: Text(
                  'New Game',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget defineScoreRow() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Friends Lost:',
            style: TextStyle(fontSize: 22),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
              child: Text(
                maze.player.lostLambs.toString(),
                style: TextStyle(fontSize: 22),
              )),
          Text(
            'Friends Saved:',
            style: TextStyle(fontSize: 22),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
              child: Text(
                maze.player.savedLambs.toString(),
                style: TextStyle(fontSize: 22),
              )),
        ],
      ),
    );
  }

  Widget defineControlsPanel() {
    return Row(
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
                        if (movePlayer(direction: Directions.up) <= 0) {
                          computerMove(
                              delayMove: maze.player.delayComputerMove);
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
                        if (movePlayer(direction: Directions.left) <= 0) {
                          computerMove(
                              delayMove: maze.player.delayComputerMove);
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
                          if (gameIsOver == false) {
                            maze.player.movesLeft = 0;
                            computerMove(
                                delayMove: maze.player.delayComputerMove);
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
                        if (movePlayer(direction: Directions.right) <= 0) {
                          computerMove(
                              delayMove: maze.player.delayComputerMove);
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
                        if (movePlayer(direction: Directions.down) <= 0) {
                          computerMove(
                              delayMove: maze.player.delayComputerMove);
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
    );
  }

  @override
  Widget build(BuildContext context) {
    setSizes();
    var trs = <Row>[];
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      print('build in landscape');
    } else {
      print('build in portrait');
    }

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
    sprites.add(getAnimatedSpriteIconForBosses(pix: maze.player));
    sprites.add(getAnimatedSpriteIconForBosses(pix: maze.minotaur));

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      print('build in landscape');
      return Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: maxWidth,
              height: maxWidth,
              child: Stack(
                  overflow: Overflow.visible,
                  children: [Column(children: trs), ...sprites]),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  defineTopRow(),
                  defineScoreRow(),
                  defineControlsPanel(),
                ],
              ),
            )
          ],
        ),
      );
    } else {
      print('build in portrait');

      return ListView(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              defineTopRow(),
              defineScoreRow(),
              SizedBox(
                width: maxWidth,
                height: maxWidth,
                child: Stack(
                    overflow: Overflow.visible,
                    children: [Column(children: trs), ...sprites]),
              ),
              defineControlsPanel(),
            ],
          ),
        ],
      );
    }
  }

  int movePlayer({Directions direction}) {
    if (gameIsOver) return 0;
    maze.lambs.forEach((lamb) {
      if (lamb.condition == Condition.freed) {
        lamb.location = '';
        lamb.lastLocation = '';
      }
    });
    if (maze.player.movesLeft <= 0) {
      maze.player.movesLeft = -1;
      return 0;
    }

    if (maze.moveThisSpriteInThisDirection(maze.player, direction)) {
      setState(() {
        print('player moved  ' + direction.toString());
      });
    } else {
      maze.player.movesLeft = 0;
    }

    return maze.player.movesLeft;
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
