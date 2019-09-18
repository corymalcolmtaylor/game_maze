import 'package:flutter/material.dart';

import 'dart:io' show Platform;

import 'maze.dart';
import 'w_StartNewGame.dart';
import 'w_MazeBackButton.dart';
import './utils.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final title = 'Alice and the Hedge Maze';

    return MaterialApp(
      title: title,
      theme: ThemeData(
          brightness: Brightness.dark,
          textTheme: TextTheme(
              title: TextStyle(color: Colors.cyanAccent),
              body1: TextStyle(color: Colors.cyanAccent))),
      home: Scaffold(
        appBar: AppBar(
          title: Text(title, style: TextStyle(color: Colors.cyanAccent)),
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
  final wallThickness = Utils.WALLTHICKNESS;
  var roomLength = 0.0;
  var maxWidth = 0.0;

  @override
  void initState() {
    super.initState();
    maze = Maze(numRows);
    maze.carveLabyrinth();
  }

  void startNewGameAndSetState() {
    startNewGame();
    setState(() {
      print('started new game');
    });
  }

  void setMyState() {
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
    //if earlier versions of android the goblin needs to switch direction facing
    if (Platform.isAndroid && pixie.ilk == Ilk.minotaur) {
      if (radians == 3) {
        radians = 0.0;
      } else {
        radians = 3.0;
      }
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
          textScaleFactor: 1.0,
          style: TextStyle(
              height: 1.0,
              color: Colors.black,
              fontSize: whatIsTheEmojiFontSizeOfThisPixie(pixie: pixie)),
        ),
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
          // print('set rad to 3 for ${lamb.emoji} ${lamb.x} > ${lamb.lastX}');
          lamb.facing = Directions.right;
        } else {
          xRadians = 6.0;
          //print('set rad to 6 for ${lamb.emoji}  ${lamb.x} > ${lamb.lastX}');
          lamb.facing = Directions.left;
        }
      }

      endLeft = whatIsTheLeftOffsetOfThisPixie(pixie: lamb);
      endTop = whatIsTheTopOffsetOfThisPixie(pixie: lamb);

      if (lamb.condition == Condition.dead) {
        lamb.emoji = '💀';
      }
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
    });
    return icons;
  }

  double howMuchToReduceTheFontSizeForThisPixie({Pixie pixie}) {
    var reduceSizeBy = 2.0;
    if (pixie.ilk == Ilk.lamb) reduceSizeBy += 2;
    return reduceSizeBy * wallThickness;
  }

  double whatIsTheEmojiFontSizeOfThisPixie({Pixie pixie}) {
    return roomLength - howMuchToReduceTheFontSizeForThisPixie(pixie: pixie);
  }

  double whatIsTheTopOffsetOfThisPixie({Pixie pixie}) {
    var retval = ((pixie.y - 1) * roomLength);
    if (pixie.ilk != Ilk.lamb) {
      retval += roomLength / 12;
    }
    if (Platform.isAndroid) {
      return retval +
          (howMuchToReduceTheFontSizeForThisPixie(pixie: pixie) / 4);
    }
    return retval + wallThickness;
  }

  double whatIsTheLeftOffsetOfThisPixie({Pixie pixie}) {
    var retval = ((pixie.x - 1) * roomLength);
    if (Platform.isIOS) {
      return retval +
          (howMuchToReduceTheFontSizeForThisPixie(pixie: pixie) / 2);
    } else {
      return retval +
          (howMuchToReduceTheFontSizeForThisPixie(pixie: pixie) / 4);
    }
  }

  void computerMove({bool delayMove}) async {
    if (maze.gameIsOver ||
        !maze.lambs.any((lamb) => lamb.condition == Condition.alive)) {
      maze.gameIsOver = true;
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
      str = 'The Goblin got Alice! ️😞\n';
    } else {
      if (maze.player.savedLambs > maze.player.lostLambs) {
        str = '${maze.player.savedLambs} rescured!\nYou WIN! 😀';
      } else if (maze.player.savedLambs == maze.player.lostLambs) {
        str = '${maze.player.savedLambs} rescured.\nYou draw! 😐';
      } else {
        str = '${maze.player.lostLambs} captured. 😞';
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

    var endLeft = ((room.x - 1) * roomLength);
    var endTop = ((room.y - 1) * roomLength);

    return Positioned(
      key: Key("room${room.x}_${room.y}"),
      left: endLeft,
      top: endTop,
      child: Container(
        width: roomLength,
        height: roomLength,
        decoration: BoxDecoration(
          color: floorColor,
          border: Border(
            bottom: BorderSide(color: southColor, width: wallThickness),
            top: BorderSide(color: northColor, width: wallThickness),
            right: BorderSide(color: eastColor, width: wallThickness),
            left: BorderSide(color: westColor, width: wallThickness),
          ),
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
            'If the goblin captures Alice the game ends but otherwise ' +
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
                  color: Colors.cyan,
                  style: BorderStyle.solid,
                  width: wallThickness),
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
    var msg = maze.gameOverMessage;
    const MAZEDIMENSIONS = 'Maze Dimensions';

    if (!maze.gameIsOver) {
      title = NEWGAME;
      msg = '';
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(title,
                          style: TextStyle(
                              fontSize: 28, color: Colors.cyanAccent)),
                      if (msg != '')
                        Text(
                          msg,
                          style:
                              TextStyle(fontSize: 22, color: Colors.cyanAccent),
                        ),
                      Text(
                        MAZEDIMENSIONS,
                        style:
                            TextStyle(fontSize: 22, color: Colors.cyanAccent),
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
                                    width: Utils.WALLTHICKNESS,
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
                                  width: wallThickness),
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
                  if (title == NEWGAME) MazeBackButton(setstate: setMyState),
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
    var maxHeight = MediaQuery.of(context).size.height;
    // print(
    //    'setsizes width = $maxWidth hieght = $maxHeight ${maxWidth / maxHeight}');
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      maxWidth = MediaQuery.of(context).size.height * 0.75;
    } else {
      if (maxWidth / maxHeight > 0.66) {
        maxWidth = maxWidth * 0.85;
      }
    }
    roomLength =
        (((maxWidth.floor() - (wallThickness * (maze.maxRow))) / maze.maxRow))
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
                  color: Colors.cyan,
                  style: BorderStyle.solid,
                  width: wallThickness),
              onPressed: () {
                setState(() {
                  handleEndOfGame();
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
    var trs = <Widget>[];
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      //print('build in landscape');
    } else {
      //print('build in portrait');
    }

    for (int i = 1; i <= maze.maxRow; i++) {
      trs.addAll(
        List.from(
          maze.myLabyrinth.entries
              .where((elroom) => elroom.value.y == i)
              .map(
                (el) => makeRoom(el.value),
              )
              .toList(),
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
      //print('build in landscape');
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
              onHorizontalDragEnd: (dragDetails) {
                print('onHorizontalDragEnd   ');
                moveThePlayer(direction: dir);
              },
              onVerticalDragEnd: (dragDetails) {
                print('onVerticalDragEnd   ');
                moveThePlayer(direction: dir);
              },
              onVerticalDragUpdate: (dragDetails) {
                print('onVerticalDragUpdate   ');
                vertaicalDragUpdate(dragDetails);
              },
              onHorizontalDragUpdate: (dragDetails) {
                print('onHorizontalDragUpdate   ');
                horizontalDragUpdate(dragDetails);
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
                    overflow: Overflow.visible, children: [...trs, ...sprites]),
              ),
            ),
          ],
        ),
      );
    } else {
      //print('build in portrait');

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
              Center(
                child: GestureDetector(
                  onHorizontalDragEnd: (dragDetails) {
                    print('onHorizontalDragEnd   ');
                    moveThePlayer(direction: dir);
                  },
                  onVerticalDragEnd: (dragDetails) {
                    print('onVerticalDragEnd   ');
                    moveThePlayer(direction: dir);
                  },
                  onVerticalDragUpdate: (dragDetails) {
                    print('onVerticalDragUpdate   ');
                    vertaicalDragUpdate(dragDetails);
                  },
                  onHorizontalDragUpdate: (dragDetails) {
                    print('onHorizontalDragUpdate   ');
                    horizontalDragUpdate(dragDetails);
                  },
                  onDoubleTap: () {
                    print('onDoubleTap   ');
                    handlePlayerHitAWall();
                    maze.whosTurnIsIt = Ilk.minotaur;
                    computerMove(delayMove: maze.player.delayComputerMove);
                  },
                  child: SizedBox(
                    width: roomLength * numRows,
                    height: roomLength * numRows,
                    child: Stack(
                        overflow: Overflow.visible,
                        children: [...trs, ...sprites]),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void moveThePlayer({Directions direction}) {
    if (movePlayer(direction: direction)) {
      if (maze.whosTurnIsIt == Ilk.minotaur) {
        computerMove(delayMove: maze.player.delayComputerMove);
      }
    } else {
      //print('player not moved');
    }
  }

  void horizontalDragUpdate(DragUpdateDetails dragDetails) {
    if (dragDetails.primaryDelta > 0) {
      dir = Directions.right;
    } else {
      if (dragDetails.primaryDelta < 0) {
        dir = Directions.left;
      }
    }
  }

  void vertaicalDragUpdate(DragUpdateDetails dragDetails) {
    if (dragDetails.primaryDelta > 0) {
      dir = Directions.down;
    } else if (dragDetails.primaryDelta < 0) {
      dir = Directions.up;
    }
  }

  /*return true if the minotaur should move next, otherwise false */
  bool movePlayer({Directions direction}) {
    if (maze.gameIsOver) return false;
    if (maze.whosTurnIsIt != Ilk.player) return false;
    if (maze.player.movesLeft <= 0) return true;

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
    maze.gameIsOver = false;
    setState(() {});
  }
}
