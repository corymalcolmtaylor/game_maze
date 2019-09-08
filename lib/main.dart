import 'package:flutter/material.dart';

import 'dart:io' show Platform;

import 'maze.dart';
import 'w_StartNewGame.dart';
import 'w_MazeBackButton.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final title = 'Alice in the Hedge Maze';

    return MaterialApp(
      title: title,
      theme: ThemeData(
          brightness: Brightness.dark,
          //primaryColor: Colors.lightGreen[800],
          //accentColor: Colors.cyan[600],
          textTheme: TextTheme(
              title: TextStyle(color: Colors.cyanAccent),
              body1: TextStyle(color: Colors.cyanAccent))),
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

  startNewGameAndSetState() {
    startNewGame();
    setState(() {
      print('started new game');
    });
  }

  AnimatedPositioned getAnimatedSpriteIconThisPixie({@required Pixie pixie}) {
    var endTop = 0.0;
    var endLeft = 0.0;

    endLeft = whatIsTheLeftOffsetOfThisPixie(pixie: pixie);
    endTop = whatIsTheTopOffsetOfThisPixie(pixie: pixie);

    var radians = 0.0;
    if (pixie.lastX > 0 && pixie.x < pixie.lastX) {
      radians = 3.0;
    }

    return AnimatedPositioned(
      key: Key(pixie.key),
      left: endLeft,
      top: endTop,
      height: roomLength,
      curve: Curves.linear,
      duration: Duration(milliseconds: animDurationMilliSeconds),
      child: Transform(
        // Transform widget

        transform: Matrix4.identity()
          ..setEntry(1, 1, 1) // perspective
          ..rotateX(0)
          ..rotateY(radians),
        alignment: FractionalOffset.center,
        child: Text(
          pixie.emoji,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
          textScaleFactor: 1.0,
          style: TextStyle(
              height: 1.15,
              color: Colors.black,
              fontSize: whatIsTheEmojiFontSizeOfThisPixie(pixie: pixie)),
        ), // <<< set your widget here
      ),
    );
  }

  List<AnimatedPositioned> getAnimatedSpriteIconsForLambs(Room room) {
    var endTop = 0.0;
    var endLeft = 0.0;
    List<AnimatedPositioned> icons = [];

    var lambs = maze.lambs.where(
      (el) => el.location == 'b_${room.x}_${room.y}',
    );

    lambs.forEach((lamb) {
      var xRadians = 0.0;
      if (lamb.x != lamb.lastX) {
        if (lamb.x > lamb.lastX) {
          xRadians = 3.0;
          print('set rad to 3 for ${lamb.emoji} ${lamb.x} > ${lamb.lastX}');
          lamb.facing = Directions.right;
        } else {
          xRadians = 6.0;
          print('set rad to 6 for ${lamb.emoji}  ${lamb.x} > ${lamb.lastX}');
          lamb.facing = Directions.left;
        }
      }

      endLeft = whatIsTheLeftOffsetOfThisPixie(pixie: lamb);
      endTop = whatIsTheTopOffsetOfThisPixie(pixie: lamb);

      if (lamb.condition == Condition.dead) {
        lamb.emoji = '☠️';
        icons.add(
          AnimatedPositioned(
            key: Key(lamb.key),
            left: endLeft,
            top: endTop,
            height: whatIsTheEmojiFontSizeOfThisPixie(pixie: lamb),
            duration: Duration(milliseconds: animDurationMilliSeconds),
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(1, 1, 1) // perspective
                ..rotateX(0)
                ..rotateY(xRadians),
              alignment: FractionalOffset.center,
              child: Text(
                lamb.emoji,
                textScaleFactor: 1.0,
                style: TextStyle(
                    height: 1.15,
                    color: Colors.black,
                    fontSize: whatIsTheEmojiFontSizeOfThisPixie(pixie: lamb)),
              ),
            ),
          ),
        );
      } else if (lamb.condition == Condition.freed) {
        icons.add(
          AnimatedPositioned(
            key: Key(lamb.key),
            left: endLeft,
            top: endTop,
            height: whatIsTheEmojiFontSizeOfThisPixie(pixie: lamb),
            duration: Duration(milliseconds: animDurationMilliSeconds),
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(1, 1, 1) // perspective
                ..rotateX(0)
                ..rotateY(xRadians),
              alignment: FractionalOffset.center,
              child: Text(
                lamb.emoji,
                textScaleFactor: 1.0,
                style: TextStyle(
                    height: 1.15,
                    color: Colors.black,
                    fontSize: whatIsTheEmojiFontSizeOfThisPixie(pixie: lamb)),
              ),
            ),
          ),
        );
      } else {
        icons.add(
          AnimatedPositioned(
              key: Key(lamb.key),
              left: endLeft,
              top: endTop,
              height: whatIsTheEmojiFontSizeOfThisPixie(pixie: lamb),
              duration: Duration(milliseconds: animDurationMilliSeconds),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(1, 1, 1) // perspective
                  ..rotateX(0)
                  ..rotateY(xRadians),
                alignment: FractionalOffset.center,
                child: Text(
                  lamb.emoji,
                  textScaleFactor: 1.0,
                  style: TextStyle(
                      height: 1.15,
                      color: Colors.black,
                      fontSize: whatIsTheEmojiFontSizeOfThisPixie(pixie: lamb)),
                ),
              )),
        );
      }
    });
    return icons;
  }

  double whatIsTheEmojiFontSizeOfThisPixie({Pixie pixie}) {
    if (pixie.ilk == Ilk.lamb) return roomLength - (roomLength / 6);
    return roomLength - (roomLength / 10);
  }

  double whatIsTheTopOffsetOfThisPixie({Pixie pixie}) {
    var retval = ((pixie.y - 1) * roomLength) + (wallThickness * (pixie.y - 1));
    if (pixie.ilk == Ilk.lamb) {
      retval += 2;
    }
    if (Platform.isAndroid) {
      if (pixie.ilk != Ilk.lamb) {
        return retval - 2;
      }
    }
    return retval;
  }

  double whatIsTheLeftOffsetOfThisPixie({Pixie pixie}) {
    var retval = ((pixie.x - 1) * roomLength) + (wallThickness * (pixie.x - 1));
    if (pixie.ilk == Ilk.lamb) {
      retval += 2;
    }

    return retval + (numRows / 2);
  }

  void computerMove({bool delayMove}) async {
    if (maze.gameIsOver ||
        !maze.lambs.any((lamb) => lamb.condition == Condition.alive)) {
      handleEndOfGame();
      return;
    }

    int minoDelay = 0;
    if (delayMove) {
      minoDelay = animDurationMilliSeconds;
    }
    var lambDelay = 0;
    if (maze.whosTurnIsIt == Ilk.minotaur) {
      lambDelay = animDurationMilliSeconds;
      Future.delayed(Duration(milliseconds: minoDelay), () {
        maze.moveMinotaur();
        maze.whosTurnIsIt = Ilk.lamb;
        setState(() {
          // just force redraw
        });
      });
    }

    Future.delayed(Duration(milliseconds: minoDelay + lambDelay), () {
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
    String str = '';
    if (maze.player.condition == Condition.dead) {
      str = 'The Goblin got Alice!\nYou lost! ☹️';
    } else {
      if (maze.player.savedLambs > maze.player.lostLambs) {
        str = '${maze.player.savedLambs} rescured!\nYou WIN! 🙂';
      } else if (maze.player.savedLambs == maze.player.lostLambs) {
        str = '${maze.player.savedLambs} rescured.\nYou draw! 😐';
      } else {
        str = '${maze.player.lostLambs} captured.\nYou lost! ☹️';
      }
    }
    maze.gameOverMessage = str;
    showGameOverMessage();
  }

  void preparePlayerForATurn() {
    maze.player.movesLeft = maze.playerMoves;
    maze.player.delayComputerMove = true;
    maze.whosTurnIsIt = Ilk.player;
  }

  Widget makeRoom(Room room) {
    /*  rooms shall be changed to square containers in rows of a set width */
    var floorColor = Colors.greenAccent;
    var northColor = (room.up == true) ? Colors.green : floorColor;
    var southColor = (room.down == true) ? Colors.green : floorColor;
    var westColor = (room.left == true) ? Colors.green : floorColor;
    var eastColor = (room.right == true) ? Colors.green : floorColor;

    return Container(
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
    );
  }

  Future<void> showRules() async {
    Text message = Text(
        'Swipe the maze to move Alice 👧 around the maze one step at a time.\n' +
            'She gets three moves per turn.\n' +
            'End her turn early by moving into a wall or double tapping.\n' +
            'Rescue the animals by getting Alice to them before they get captured by the goblin 👺.\n' +
            'If the goblin captures Alice you lose but otherwise ' +
            'if she saves more animals than get captured you win.',
        style: TextStyle(fontSize: 22, color: Colors.cyanAccent));
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          title: Center(
            child: Text(
              'Rules',
              style: TextStyle(fontSize: 24, color: Colors.cyanAccent),
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[message],
            ),
          ),
          actions: <Widget>[
            OutlineButton(
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
              color: Colors.cyanAccent,
              borderSide: BorderSide(
                  color: Colors.cyan, style: BorderStyle.solid, width: 1),
              onPressed: () {
                Navigator.of(context).pop();
                showGameOverMessage();
                setState(() {
                  print('OK showed rules');
                });
              },
              child: Text('OK',
                  style: TextStyle(fontSize: 24, color: Colors.cyanAccent)),
            ),
          ],
        );
      },
    );
  }

  Future<void> showGameOverMessage() async {
    const NEWGAME = 'New Game';
    const GAMEOVER = 'Game Over';
    var title = GAMEOVER;
    var msg = maze.gameOverMessage + '\nMaze Dimensions';

    if (!maze.gameIsOver) {
      title = NEWGAME;
      msg = 'Maze Dimensions';
    }
    return showDialog<void>(
      context: context,

      barrierDismissible: false, // user must tap button!
      builder: (context) {
        var numRowsInner = numRows;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(title,
                          style: TextStyle(
                              fontSize: 28, color: Colors.cyanAccent)),
                      Center(
                        child: Text(
                          msg,
                          style:
                              TextStyle(fontSize: 22, color: Colors.cyanAccent),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              decoration: new BoxDecoration(
                                border: new Border.all(
                                    color: Colors.cyanAccent,
                                    width: 1.0,
                                    style: BorderStyle.solid),
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(20.0)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isDense: true,
                                    value: numRowsInner.toString(),
                                    onChanged: (String newValue) {
                                      numRowsInner = int.parse(newValue);
                                      numRows = numRowsInner;
                                      setState(() {
                                        print('new val == $numRowsInner');
                                      });
                                    },
                                    items: <String>['8', '10', '12', '14']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          '${value}x$value',
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.cyanAccent),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                            child: OutlineButton(
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                              color: Colors.cyanAccent,
                              borderSide: BorderSide(
                                  color: Colors.cyan,
                                  style: BorderStyle.solid,
                                  width: 1),
                              onPressed: () {
                                setState(() {
                                  Navigator.of(context).pop();
                                  showRules();
                                });
                              },
                              child: Text(
                                'Show Rules',
                                style: TextStyle(
                                    fontSize: 24, color: Colors.cyanAccent),
                              ),
                            ),
                          ),
                          if (MediaQuery.of(context).orientation ==
                              Orientation.landscape)
                            StartNewGame(
                              startgame: startNewGameAndSetState,
                            ),
                        ],
                      ),
                      if (MediaQuery.of(context).orientation ==
                          Orientation.portrait)
                        StartNewGame(
                          startgame: startNewGameAndSetState,
                        ),
                    ],
                  ),
                  if (title == NEWGAME) MazeBackButton(setstate: setState),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void setSizes() {
    maxWidth = MediaQuery.of(context).size.width;
    var maxHieght = MediaQuery.of(context).size.height;
    print('setsizes wid = $maxWidth hit = $maxHieght ${maxWidth / maxHieght}');
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      maxWidth = MediaQuery.of(context).size.height * 0.75;
    } else {
      if (maxWidth / maxHieght > 0.66) {
        maxWidth = maxWidth * 0.85;
      }
    }
    roomLength =
        ((maxWidth.floor() - (wallThickness * (maze.maxRow + 1))) / maze.maxRow)
            .floorToDouble();
  }

  Widget defineTopRow() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: OutlineButton(
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
              borderSide: BorderSide(
                  color: Colors.cyan, style: BorderStyle.solid, width: 1),
              onPressed: () {
                setState(() {
                  handleEndOfGame();
                  //startNewGame();
                });
              },
              child: Text(
                'New Game\nOptions and Rules',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, color: Colors.cyanAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget defineScoreRow() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        //direction: Axis.horizontal,
        //alignment: WrapAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: <Widget>[
              Text(
                'Alice Saved:',
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
          Row(
            children: <Widget>[
              Text(
                'Goblin Captured:',
                style: TextStyle(fontSize: 22),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
                  child: Text(
                    maze.player.lostLambs.toString(),
                    style: TextStyle(fontSize: 22),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Directions dir;
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
    sprites.add(getAnimatedSpriteIconThisPixie(pixie: maze.player));
    sprites.add(getAnimatedSpriteIconThisPixie(pixie: maze.minotaur));

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      print('build in landscape');
      return Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  defineTopRow(),
                  defineScoreRow(),
                ],
              ),
            ),
            GestureDetector(
              onHorizontalDragEnd: (deets) {
                moveThePlayer(direction: dir);
              },
              onVerticalDragEnd: (deets) {
                moveThePlayer(direction: dir);
              },
              onVerticalDragUpdate: (deets) {
                vertaicalDragUpdate(deets);
              },
              onHorizontalDragUpdate: (deets) {
                horizontalDragUpdate(deets);
              },
              onDoubleTap: () {
                print('onDoubleTap   ');
                handlePlayerHitAWall();
                maze.whosTurnIsIt = Ilk.minotaur;
                computerMove(delayMove: maze.player.delayComputerMove);
              },
              child: SizedBox(
                width: maxWidth,
                height: maxWidth,
                child: Stack(
                    overflow: Overflow.visible,
                    children: [Column(children: trs), ...sprites]),
              ),
            ),
          ],
        ),
      );
    } else {
      print('build in portrait');

      return Center(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      defineTopRow(),
                      defineScoreRow(),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onHorizontalDragEnd: (deets) {
                  moveThePlayer(direction: dir);
                },
                onVerticalDragEnd: (deets) {
                  moveThePlayer(direction: dir);
                },
                onVerticalDragUpdate: (deets) {
                  vertaicalDragUpdate(deets);
                },
                onHorizontalDragUpdate: (deets) {
                  horizontalDragUpdate(deets);
                },
                onDoubleTap: () {
                  print('onDoubleTap   ');
                  handlePlayerHitAWall();
                  maze.whosTurnIsIt = Ilk.minotaur;
                  computerMove(delayMove: maze.player.delayComputerMove);
                },
                child: SizedBox(
                  width: maxWidth,
                  height: maxWidth,
                  child: Stack(
                      overflow: Overflow.visible,
                      children: [Column(children: trs), ...sprites]),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void moveThePlayer({Directions direction}) {
    //print('moveThePlayer   ');

    if (movePlayer(direction: direction)) {
      //print('player moved');
      if (maze.whosTurnIsIt == Ilk.minotaur) {
        computerMove(delayMove: maze.player.delayComputerMove);
      }
    } else {
      //print('player not moved');
    }
  }

  void horizontalDragUpdate(DragUpdateDetails deets) {
    //print('onHorizontalDragUpdate  ');
    if (deets.primaryDelta > 0) {
      //print('right pressed');
      dir = Directions.right;
    } else {
      if (deets.primaryDelta < 0) {
        //print('left pressed');
        dir = Directions.left;
      }
    }
  }

  void vertaicalDragUpdate(DragUpdateDetails deets) {
    //print('onVerticalDragUpdate  ');
    if (deets.primaryDelta > 0) {
      //print('down pressed');
      dir = Directions.down;
    } else if (deets.primaryDelta < 0) {
      //print('up pressed');
      dir = Directions.up;
    }
  }

  void verticalDragMove(DragEndDetails deets) {
    //print('vert drag');
    //print(deets.toString());
  }

  /*return true if the minotaur should move next, otherwise false */
  bool movePlayer({Directions direction}) {
    //print('movePlayer 1');
    if (gameIsOver) return false;
    //print('movePlayer 2 ${maze.whosTurnIsIt}');
    if (maze.whosTurnIsIt != Ilk.player) return false;
    //print('movePlayer 3');
    if (maze.player.movesLeft <= 0) return true;
    //print('movePlayer 4');

    maze.lambs.forEach((lamb) {
      if (lamb.condition == Condition.freed) {
        lamb.location = '';
        lamb.lastLocation = '';
      }
    });

    if (maze.moveThisSpriteInThisDirection(maze.player, direction)) {
      setState(() {
        //print('player moved  ' + direction.toString());
      });
    } else {
      handlePlayerHitAWall();
    }
    if (maze.player.movesLeft <= 0) {
      maze.whosTurnIsIt = Ilk.minotaur;
    }
    if (maze.whosTurnIsIt == Ilk.minotaur) return true;
    return false;
  }

  void handlePlayerHitAWall() {
    maze.player.movesLeft = 0;
  }

  void startNewGame() {
    sprites.clear();
    maze.maxRow = numRows;
    setSizes();
    maze.initMaze();
    maze.carveLabyrinth();
    gameIsOver = false;
    setState(() {});
  }
}
