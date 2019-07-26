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
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 900),
      value: 1.0,
      vsync: this,
    );
  }

  Widget getAnimatedPixieIcon(Room room) {
    var beginTop = 0.0; //(room.x -1) * roomLength;
    var beginLeft = 0.0;
    var endTop = 0.0;
    var endLeft = 0.0;
    Animation<RelativeRect> layerAnimation;

    if (widget.maze.minotaur.location == 'b_${room.x}_${room.y}') {
      beginTop = (widget.maze.minotaur.lastY - 1) * roomLength;
      beginLeft = (widget.maze.minotaur.lastX - 1) * roomLength;
      endTop = (widget.maze.minotaur.y - 1) * roomLength;
      endLeft = (widget.maze.minotaur.x - 1) * roomLength;
      layerAnimation = RelativeRectTween(
        begin: RelativeRect.fromLTRB(beginLeft, beginTop, 0.0, 0.0),
        end: RelativeRect.fromLTRB(endLeft, endTop, 0.0, 0.0),
      ).animate(_controller.view);
      return PositionedTransition(
        rect: layerAnimation,
        child: Text(
          widget.maze.minotaur.emoji,
          style: TextStyle(color: Colors.black, fontSize: roomLength),
        ),
      );
    }
    if (widget.maze.player.location == 'b_${room.x}_${room.y}') {
      beginTop = (widget.maze.player.lastY - 1) * roomLength;
      beginLeft = (widget.maze.player.lastX - 1) * roomLength;
      endTop = (widget.maze.player.y - 1) * roomLength;
      endLeft = (widget.maze.player.x - 1) * roomLength;
      layerAnimation = RelativeRectTween(
        begin: RelativeRect.fromLTRB(beginLeft, beginTop, 0.0, 0.0),
        end: RelativeRect.fromLTRB(endLeft, endTop, 0.0, 0.0),
      ).animate(_controller.view);
      return PositionedTransition(
        rect: layerAnimation,
        child: Text(
          widget.maze.player.emoji,
          style: TextStyle(color: Colors.black, fontSize: roomLength - 4),
        ),
      );
    }
    var lamb = widget.maze.lambs.firstWhere(
        (el) => el.location == 'b_${room.x}_${room.y}',
        orElse: () => null);

    if (lamb != null) {
      beginTop = (lamb.lastY - 1) * roomLength;
      beginLeft = (lamb.lastX - 1) * roomLength;
      endTop = (lamb.y - 1) * roomLength;
      endLeft = (lamb.x - 1) * roomLength;
      layerAnimation = RelativeRectTween(
        begin: RelativeRect.fromLTRB(beginLeft, beginTop, 0.0, 0.0),
        end: RelativeRect.fromLTRB(endLeft, endTop, 0.0, 0.0),
      ).animate(_controller.view);
      return PositionedTransition(
        rect: layerAnimation,
        child: Text(
          lamb.emoji,
          style: TextStyle(color: Colors.black, fontSize: roomLength - 8),
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
          style: TextStyle(color: Colors.black, fontSize: roomLength - 8),
        ),
      );
    }
    if (widget.maze.player.location == 'b_${room.x}_${room.y}') {
      return Center(
        child: Text(
          widget.maze.player.emoji,
          style: TextStyle(color: Colors.black, fontSize: roomLength - 8),
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
          style: TextStyle(color: Colors.black, fontSize: roomLength - 8),
        ),
      );
    }
    lamb = widget.maze.lambs.firstWhere(
        (el) => el.lastLocation == 'b_${room.x}_${room.y}',
        orElse: () => null);

    return null;
  }

  Widget makeRoom(Room room) {
    var floorColor = Colors.greenAccent;
    var northColor = (room.up == true) ? Colors.green : floorColor;
    var southColor = (room.down == true) ? Colors.green : floorColor;
    var westColor = (room.left == true) ? Colors.green : floorColor;
    var eastColor = (room.right == true) ? Colors.green : floorColor;

    TableCellVerticalAlignment val = TableCellVerticalAlignment.middle;

    return Table(
      border: TableBorder(
        top: BorderSide(width: 1.0, color: northColor),
        right: BorderSide(width: 1.0, color: eastColor),
        left: BorderSide(width: 1.0, color: westColor),
        bottom: BorderSide(width: 1.0, color: southColor),
      ),
      children: [
        TableRow(
          children: [
            TableCell(
              verticalAlignment: val,
              child: GestureDetector(
                onTap: () {
                  print('_MazeRoomState   b_${room.x}_${room.y} tapped');
                  widget.maze.player.x = widget.maze.player.x + 1;

                  widget.maze.player.location =
                      'b_${widget.maze.player.x}_${widget.maze.player.y}';
                },
                child: Container(
                  color: floorColor,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: roomLength,
                    height: roomLength,
                    //child: getRoomPixieIcon(room),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool movePixie(Pixie pix, Directions dir) {
    if (widget.maze.movePixie(pix, dir)) {
      if (pix.ilk != Ilk.lamb && widget.maze.killLambInRoom(pix)) {
        if (pix.ilk == Ilk.minotaur) {
          print('killed a lamb');
          widget.maze.player.lostLambs++;
        }
        if (pix.ilk == Ilk.player) {
          print('saved a lamb');
          widget.maze.player.savedLambs++;
        }
      }
      if (pix.ilk == Ilk.lamb) {
        if (pix.location == widget.maze.player.location) {
          widget.maze.saveLamb(pix);
        }
      }
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
          randint++;
          break;
        case 1:
          success = movePixie(pix, Directions.up);
          randint++;
          break;
        case 2:
          success = movePixie(pix, Directions.right);
          randint++;
          break;
        case 3:
          success = movePixie(pix, Directions.left);
          randint = 0;
      }
      if (success) return true;
      numberOfMoveTries++;
    }
  }

  bool moveMinotaur() {
    if (gameIsOver) return false;
    return tryToMove(widget.maze.minotaur, rand.nextInt(4), 0);
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
    var trs = <TableRow>[];

    for (int i = 1; i <= widget.maze.maxRow; i++) {
      trs.add(
        TableRow(
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
                Table(children: trs),
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
                                print('move north  pressed');
                                setState(() {
                                  if (gameIsOver == false) {
                                    movePixie(
                                        widget.maze.player, Directions.up);
                                    if (widget.maze.player.moveRate <= 0) {
                                      moveMinotaur();
                                      moveLambs();
                                    }

                                    print(
                                        'newlocation ${widget.maze.player.x} ${widget.maze.player.y}');
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
                                print('move west pressed');
                                if (gameIsOver == false) {
                                  setState(() {
                                    movePixie(
                                        widget.maze.player, Directions.left);
                                    if (widget.maze.player.moveRate <= 0) {
                                      moveMinotaur();
                                      moveLambs();
                                    }

                                    print(
                                        'newlocation ${widget.maze.player.x} ${widget.maze.player.y}');
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
                                print(' move east pressed');
                                if (gameIsOver == false) {
                                  setState(() {
                                    movePixie(
                                        widget.maze.player, Directions.right);
                                    if (widget.maze.player.moveRate <= 0) {
                                      moveMinotaur();
                                      moveLambs();
                                    }

                                    print(
                                        'newlocation ${widget.maze.player.x} ${widget.maze.player.y}');
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
                                print('move south  pressed');
                                if (gameIsOver == false) {
                                  setState(() {
                                    movePixie(
                                        widget.maze.player, Directions.down);
                                    if (widget.maze.player.moveRate <= 0) {
                                      moveMinotaur();
                                      moveLambs();
                                    }
                                    print(
                                        'newlocation ${widget.maze.player.x} ${widget.maze.player.y}');
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
