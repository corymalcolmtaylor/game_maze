import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:game_maze/core/maze.dart';
import 'package:game_maze/core/pixie.dart';
import 'package:game_maze/core/room.dart';
import 'package:game_maze/core/utils.dart';
import 'package:game_maze/features/game/presentation/bloc/game_bloc.dart';
import 'package:game_maze/features/game/presentation/widgets/enInfo.dart';
import 'package:game_maze/features/game/presentation/widgets/enRules.dart';
import 'package:game_maze/features/game/presentation/widgets/w_MazeBackButton.dart';
import 'package:game_maze/features/panel/presentation/bloc/panel_bloc.dart';
import 'package:game_maze/features/panel/presentation/widgets/en_options.dart';
import 'package:game_maze/generated/l10n.dart';
import 'package:game_maze/theme.dart';

class MazeArea extends StatefulWidget {
  @override
  _MazeAreaState createState() {
    return _MazeAreaState();
  }
}

class _MazeAreaState extends State<MazeArea>
    with SingleTickerProviderStateMixin {
  //Maze maze;
  int numRows = 8;
  final maximumMoveAttempts = 8;

  var sprites = <Widget>[];
  var roomLength = 0.0;
  var maxWidth = 0.0;
  var hDelta = 0.0;
  var vDelta = 0.0;
  GameDifficulty difficulty = GameDifficulty.normal;
  Directions dir;

  TapGestureRecognizer _emailPressRecognizer;

  @override
  void initState() {
    super.initState();
    //maze = Maze(numRows, difficulty);
    //getMaze().carveLabyrinth();
  }

  Maze getMaze() {
    GameState gs = BlocProvider.of<GameBloc>(context).state;
    if (gs is InitialGame) {
      return gs.maze;
    }
    if (gs is LoadedGame) {
      return gs.maze;
    }
    return Maze(8, GameDifficulty.normal);
  }

  PanelBloc getPanelBloc() {
    return BlocProvider.of<PanelBloc>(context);
  }

  AnimatedPositioned getAnimatedSpriteIconThisPixie({@required Pixie pixie}) {
    var endTop = 0.0;
    var endLeft = 0.0;

    var radians = 0.0;
    if (pixie.lastX > 0 && pixie.x < pixie.lastX) {
      radians = 3.0;
    }
    //if earlier versions of android the goblin needs to switch direction facing
    if (pixie.ilk == Ilk.minotaur) {
      if (radians == 3) {
        radians = 0.0;
      } else {
        radians = 3.0;
      }
    }

    endLeft = whatIsTheLeftOffsetOfThisPixie(pixie: pixie);
    endTop = whatIsTheTopOffsetOfThisPixie(pixie: pixie);

    return getAnimatedPositionedForThisPixie(
        pixie: pixie, endLeft: endLeft, endTop: endTop, radians: radians);
  }

  List<AnimatedPositioned> getAnimatedSpriteIconsForLambs(Room room) {
    var endTop = 0.0;
    var endLeft = 0.0;
    List<AnimatedPositioned> icons = [];

    var lambs = getMaze().lambs.where(
          (el) => el.location == 'b_${room.x}_${room.y}',
        );

    lambs.forEach((pixie) {
      var radians = 0.0;
      if (pixie.x != pixie.lastX) {
        if (pixie.x > pixie.lastX) {
          radians = 3.0;
          pixie.facing = Directions.right;
        } else {
          radians = 6.0;
          pixie.facing = Directions.left;
        }
      }

      if (pixie.condition == Condition.dead) {
        pixie.emoji = '💀';
      }

      endLeft = whatIsTheLeftOffsetOfThisPixie(pixie: pixie);
      endTop = whatIsTheTopOffsetOfThisPixie(pixie: pixie);

      icons.add(
        getAnimatedPositionedForThisPixie(
            pixie: pixie, endLeft: endLeft, endTop: endTop, radians: radians),
      );
    });
    return icons;
  }

  AnimatedPositioned getAnimatedPositionedForThisPixie(
      {Pixie pixie, double endLeft, double endTop, double radians}) {
    return AnimatedPositioned(
      width: roomLength,
      key: Key(pixie.key),
      left: endLeft,
      top: endTop,
      height: whatIsTheEmojiFontSizeOfThisPixie(pixie: pixie),
      curve: Curves.linear,
      duration: Duration(milliseconds: Utils.animDurationMilliSeconds),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(1, 1, 1) // perspective
            ..rotateX(0)
            ..rotateY(radians),
          alignment: FractionalOffset.center,
          child: getEmojiText(pixie),
        ),
      ),
    );
  }

  Widget getEmojiText(Pixie pixie) {
    if (!Platform.isAndroid) {
      return Text(
        pixie.emoji,
        textScaleFactor: 0.8,
        style: TextStyle(
          height: 1.0,
          fontFamily: 'NotoEmoji',
          color: getMaze().isEasy() || pixie.isVisible
              ? Color(pixie.preferredColor)
              : Colors.transparent,
          fontSize: whatIsTheEmojiFontSizeOfThisPixie(pixie: pixie),
        ),
      );
    } else {
      return Text(
        pixie.emoji,
        textScaleFactor: 0.8,
        style: TextStyle(
          height: 1.0,
          color: getMaze().isEasy() || pixie.isVisible
              ? Colors.black
              : Colors.transparent,
          fontSize: whatIsTheEmojiFontSizeOfThisPixie(pixie: pixie),
        ),
      );
    }
  }

  double whatIsTheEmojiFontSizeOfThisPixie({Pixie pixie}) {
    return roomLength - (Utils.wallThickness * 3);
  }

  double whatIsTheTopOffsetOfThisPixie({Pixie pixie}) {
    var retval = ((pixie.y - 1) * roomLength);
    //retval += roomLength * 0.1;
    return retval + (2 * Utils.wallThickness);
  }

  double whatIsTheLeftOffsetOfThisPixie({Pixie pixie}) {
    var retval = ((pixie.x - 1) * roomLength);
    return retval + Utils.wallThickness;
  }

  void computerMovex({bool delayMove}) async {
    if (getMaze().gameIsOver() ||
        !getMaze().lambs.any((lamb) => lamb.condition == Condition.alive)) {
      getMaze().setGameIsOver(true);
      //  handleEndOfGame();
      return;
    }

    int minoDelay = 0;
    if (delayMove) {
      minoDelay = Utils.animDurationMilliSeconds;
    }
    var lambDelay = 0;
    if (getMaze().getWhosTurnIsIt() == Ilk.minotaur) {
      lambDelay = Utils.animDurationMilliSeconds;
      Future.delayed(Duration(milliseconds: minoDelay), () {
        getMaze().moveMinotaur();
        setState(() {
          // just force redraw
        });
      });
    }

    Future.delayed(Duration(milliseconds: minoDelay + lambDelay), () {
      var gameOver = getMaze().moveLambs();
      getMaze().clearLocationsOfLambsInThisCondition(condition: Condition.dead);

      setState(() {
        // just force redraw
      });

      if (gameOver) {
        Future.delayed(
            Duration(milliseconds: 1 * Utils.animDurationMilliSeconds), () {
          // handleEndOfGame();
        });
      } else {
        getMaze().preparePlayerForATurn();
      }
    }).then((_) {
      Future.delayed(Duration(milliseconds: Utils.animDurationMilliSeconds),
          () {
        print('clear freed 2');
        getMaze()
            .clearLocationsOfLambsInThisCondition(condition: Condition.freed);
        setState(() {
          // just force redraw
        });
      });
    });
  }

  void handleEndOfGamex() {
    String str = '';
    getMaze().setEogEmoji('');
    if (getMaze().player.condition == Condition.dead) {
      str = S.of(context).theGoblinGotAlice;
      getMaze().setEogEmoji('😞');
    } else {
      if (getMaze().player.savedLambs > getMaze().player.lostLambs) {
        str =
            '${S.of(context).youRescued} ${getMaze().player.savedLambs}${S.of(context).nyouWin}';
        getMaze().setEogEmoji('😀');
      } else if (getMaze().player.savedLambs == getMaze().player.lostLambs) {
        str =
            '${getMaze().player.savedLambs} ${S.of(context).rescuedAndCaptured}';
        getMaze().setEogEmoji('😐');
      } else {
        str = '${S.of(context).goblinCaptured}${getMaze().player.lostLambs}. ';
        getMaze().setEogEmoji('😞');
      }
    }
    getMaze().setGameOverMessage(str);

    //showGameOverMessage();
    BlocProvider.of<PanelBloc>(context).add(const ShowSettingsPanel());
  }

  Widget makeRoom(Room room) {
    /*  rooms shall be changed to square containers in rows of a set width */
    var floorColor = Colors.green[200];
    var northColor =
        (room.downWallIsUp == true) ? Colors.green[700] : floorColor;
    var southColor = (room.upWallIsUp == true) ? Colors.green[700] : floorColor;
    var westColor =
        (room.leftWallIsUp == true) ? Colors.green[700] : floorColor;
    var eastColor =
        (room.rightWallIsUp == true) ? Colors.green[700] : floorColor;

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
            bottom: BorderSide(color: southColor, width: Utils.wallThickness),
            top: BorderSide(color: northColor, width: Utils.wallThickness),
            right: BorderSide(color: eastColor, width: Utils.wallThickness),
            left: BorderSide(color: westColor, width: Utils.wallThickness),
          ),
        ),
      ),
    );
  }

  String getMazeDifficulty() {
    if (getMaze().difficulty == GameDifficulty.hard) return Utils.hard;
    if (getMaze().difficulty == GameDifficulty.tough) return Utils.tough;
    return Utils.normal;
  }

  void setMazeDifficulty(newValue) {
    if (newValue == Utils.hard)
      difficulty = GameDifficulty.hard;
    else if (newValue == Utils.tough)
      difficulty = GameDifficulty.tough;
    else
      difficulty = GameDifficulty.normal;
  }

  Future<void> showGameOverMessagex() async {
    var title = S.of(context).gameOver;
    var msg = getMaze().getGameOverMessage();

    if (!getMaze().gameIsOver()) {
      title = S.current.options;
      msg = '';
    }

    var emojiTextStyle = TextStyle(
      fontSize: 22,
      color: Colors.yellow,
      fontFamily: 'NotoEmoji',
    );

    return showDialog<void>(
      context: context,

      barrierDismissible: false, // user must tap button!
      builder: (context) {
        var numRowsInner = numRows;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            contentPadding: EdgeInsets.all(2),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: theme.textTheme.headline2,
                    ),
                  ),
                  if (msg != '')
                    RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                          text: msg,
                          style: theme.textTheme.bodyText1,
                        ),
                        TextSpan(
                          text: getMaze().getEogEmoji(),
                          style: emojiTextStyle,
                        ),
                      ]),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            S.of(context).mazeSize,
                            style: theme.textTheme.bodyText2,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              decoration: new BoxDecoration(
                                border: new Border.all(
                                    color: Colors.cyanAccent,
                                    width: Utils.borderWallThickness,
                                    style: BorderStyle.solid),
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: DropdownButtonHideUnderline(
                                  child: new Theme(
                                    data: Theme.of(context).copyWith(
                                      canvasColor: Colors.black87,
                                    ),
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
                                            textScaleFactor: 1.0,
                                            style: theme.textTheme.bodyText2,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            S.of(context).difficulty,
                            style: theme.textTheme.bodyText2,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              decoration: new BoxDecoration(
                                border: new Border.all(
                                    color: Colors.cyanAccent,
                                    width: Utils.borderWallThickness,
                                    style: BorderStyle.solid),
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: DropdownButtonHideUnderline(
                                  child: new Theme(
                                    data: Theme.of(context).copyWith(
                                      canvasColor: Colors.black87,
                                    ),
                                    child: DropdownButton<String>(
                                      isDense: true,
                                      value: getMazeDifficulty(),
                                      onChanged: (String newValue) {
                                        setMazeDifficulty(newValue);

                                        setState(() {
                                          print(' ');
                                        });
                                      },
                                      items: <String>[
                                        Utils.normal,
                                        Utils.hard,
                                        Utils.tough
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            textScaleFactor: 1.0,
                                            overflow: TextOverflow.visible,
                                            style: theme.textTheme.bodyText2,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (title == S.of(context).gameOver) MazeBackButton(),
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
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      maxWidth = MediaQuery.of(context).size.height * 0.75;
    } else {
      if (maxWidth / maxHeight > 0.66) {
        maxWidth = maxWidth * 0.95;
      }
    }
    roomLength =
        (((maxWidth.floor() - (Utils.wallThickness * (getMaze().getMaxRow()))) /
                getMaze().getMaxRow()))
            .floorToDouble();
  }

  Widget defineTopRow() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        child: OutlineButton(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
          borderSide: BorderSide(
              color: Colors.cyan,
              style: BorderStyle.solid,
              width: Utils.borderWallThickness),
          onPressed: () {
            setState(() {
              //  handleEndOfGame();
            });
          },
          child: Text(
            S.of(context).newGame,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyText2,
          ),
        ),
      ),
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
                S.of(context).aliceSaved,
                style: theme.textTheme.bodyText2,
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
                  child: Text(
                    '${getMaze().player.savedLambs.toString()} ' +
                        S.of(context).xf +
                        ' ${getMaze().getMaxRow().toString()}',
                    style: theme.textTheme.bodyText2,
                  )),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                S.of(context).goblinCaptured,
                style: theme.textTheme.bodyText2,
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
                  child: Text(
                    '${getMaze().player.lostLambs.toString()}',
                    style: theme.textTheme.bodyText2,
                  )),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                S.of(context).movesLeft,
                style: theme.textTheme.bodyText2,
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
                  child: Text(
                    '${getMaze().player.getMovesLeft()}',
                    style: theme.textTheme.bodyText2,
                  )),
            ],
          )
        ],
      ),
    );
  }

  Widget showRules(double stackSize) {
    var rulesTitle = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: <TextSpan>[
        TextSpan(
          text: '${S.of(context).rules}\n',
          style: theme.textTheme.headline2,
        ),
      ]),
    );

    Widget message;

    message = EnRules();
    if (maxWidth > 500 ||
        MediaQuery.of(context).orientation == Orientation.landscape) {
      message = Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
        child: message,
      );
    }
    if (kIsWeb) {
      message = Container(width: maxWidth, child: message);
    }

    return Scrollbar(
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(8.0),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              rulesTitle,
              message,
            ],
          ),
        ],
      ),
    );
  }

  Widget showAbout(double stackSize) {
    var infoTitle = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: <TextSpan>[
        TextSpan(
          text: '${S.of(context).about}\n',
          style: theme.textTheme.headline2,
        ),
      ]),
    );

    Widget message = EnInfo(
      _emailPressRecognizer,
    );
    if (maxWidth > 500 ||
        MediaQuery.of(context).orientation == Orientation.landscape) {
      message = Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
        child: message,
      );
    }
    if (kIsWeb) {
      message = Container(width: maxWidth, child: message);
    }
    var column = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        infoTitle,
        message,
      ],
    );
    //if (maxWidth > 500) return column;
    return Scrollbar(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        scrollDirection: Axis.vertical,
        children: [column],
      ),
    );
  }

  Widget showOptions() {
    //BlocProvider.of<PanelBloc>(context).add(const ShowSettingsPanel());
    return EnOptions(numRows: numRows, difficulty: difficulty);
  }

  @override
  Widget build(BuildContext context) {
    print('mazearea build id ${getMaze().randomid}');
    setSizes();
    var trs = <Widget>[];
    Widget otherPanel;

    if (getPanelBloc().state is RulesPanel) {
      otherPanel = showRules(maxWidth);
    } else if (getPanelBloc().state is SettingsPanel) {
      otherPanel = showOptions();
    } else if (getPanelBloc().state is AboutPanel) {
      otherPanel = showAbout(maxWidth);
    }
    return BlocBuilder<GameBloc, GameState>(builder: (context, mazestate) {
      print('BlocBuilder build 1 ${mazestate.maze.randomid}  ');
      print('BlocBuilder build 2 ${getMaze().randomid}  ');
      print('BlocBuilder build 3 ');
      for (int i = 1; i <= getMaze().getMaxRow(); i++) {
        trs.addAll(
          List.from(
            getMaze()
                .myLabyrinth
                .entries
                .where((elroom) => elroom.value.y == i)
                .map(
                  (el) => makeRoom(el.value),
                )
                .toList(),
          ),
        );
      }
      // add sprites
      getMaze().setPixiesVisibility();

      var llsprites = List.from(getMaze().myLabyrinth.entries.map(
            (el) => getAnimatedSpriteIconsForLambs(el.value),
          ));

      sprites.clear();
      llsprites.forEach((ll) {
        sprites.addAll(ll);
      });
      sprites.add(getAnimatedSpriteIconThisPixie(pixie: getMaze().player));

      sprites.add(getAnimatedSpriteIconThisPixie(pixie: getMaze().minotaur));

      Widget panel;
      if (BlocProvider.of<PanelBloc>(context).state is DishPanel) {
        print('is dish panel');
        if (MediaQuery.of(context).orientation == Orientation.landscape) {
          panel = Container(
            color: Colors.black,
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    color: Colors.black,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // defineTopRow(),
                        defineScoreRow(),
                      ],
                    ),
                  ),
                  buildCenter(trs, maxWidth),
                ],
              ),
            ),
          );
        } else {
          panel = Center(
            child: Container(
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          // defineTopRow(),
                          defineScoreRow(),
                        ],
                      ),
                    ],
                  ),
                  Center(child: buildCenter(trs, roomLength * numRows)),
                ],
              ),
            ),
          );
        }
      } else {
        print('is NOT dish panel');
        panel = otherPanel;
      }
      print('is what panel ?');
      return panel;
    });
  }

  GestureDetector buildCenter(List<Widget> trs, double stackSize) {
    return GestureDetector(
      onHorizontalDragEnd: (dragDetails) {
        if (hDelta.abs() > 25) {
          movePlayer(direction: dir);
        }
        hDelta = 0;
      },
      onVerticalDragEnd: (dragDetails) {
        if (vDelta.abs() > 25) {
          movePlayer(direction: dir);
        }
        vDelta = 0;
      },
      onVerticalDragUpdate: (dragDetails) {
        vertaicalDragUpdate(dragDetails);
      },
      onHorizontalDragUpdate: (dragDetails) {
        horizontalDragUpdate(dragDetails);
      },
      onDoubleTap: () {
        print('dtap');
        //BlocProvider.of<GameBloc>(context).add(EndTurnEvent(
        //    'end turn  alice ${DateTime.now().millisecondsSinceEpoch}'));
        //handlePlayerHitAWall();
        // getMaze().setWhosTurnItIs(Ilk.minotaur);
        //computerMove(delayMove: getMaze().player.delayComputerMove);
      },
      child: SizedBox(
        width: stackSize,
        height: stackSize,
        child: Stack(clipBehavior: Clip.none, children: [...trs, ...sprites]),
      ),
    );
  }

  void horizontalDragUpdate(DragUpdateDetails dragDetails) {
    hDelta += dragDetails.primaryDelta;
    if (dragDetails.primaryDelta > 0) {
      dir = Directions.right;
    } else {
      if (dragDetails.primaryDelta < 0) {
        dir = Directions.left;
      }
    }
  }

  void vertaicalDragUpdate(DragUpdateDetails dragDetails) {
    vDelta += dragDetails.primaryDelta;
    if (dragDetails.primaryDelta > 0) {
      dir = Directions.down;
    } else if (dragDetails.primaryDelta < 0) {
      dir = Directions.up;
    }
  }

  /*return true if the minotaur should move next, otherwise false */
  void movePlayer({Directions direction}) {
    if (getMaze().gameIsOver()) return;
    if (getMaze().getWhosTurnIsIt() != Ilk.player) return;
    if (getMaze().player.getMovesLeft() <= 0) return;

    BlocProvider.of<GameBloc>(context)
        .add(MoveEvent('move alice $direction', direction));
  }

  void startNewGame() {
    BlocProvider.of<GameBloc>(context)
        .add(InitializeNewGameEvent(numRows, difficulty));
  }
}
