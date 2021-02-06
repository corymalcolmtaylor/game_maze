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
import 'package:game_maze/features/panel/presentation/bloc/panel_bloc.dart';
import 'package:game_maze/features/panel/presentation/widgets/en_info.dart';
import 'package:game_maze/features/panel/presentation/widgets/en_options.dart';
import 'package:game_maze/features/panel/presentation/widgets/en_rules.dart';
import 'package:game_maze/generated/l10n.dart';
import 'package:game_maze/theme.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _emailPressRecognizer = TapGestureRecognizer()
      ..onTap = () async {
        const url = 'mailto:thesoftwaretaylor@gmail.com?'
            'subject=Alice%20and%20the%20Hedge%20Maze';
        print('$url');
        if (await canLaunch(url)) {
          print(' launch $url');
          await launch(url);
        } else {
          print('cannot launch $url');
          throw const MazeException(message: 'Could not launch $url');
        }
      };
  }

  @override
  void dispose() {
    super.dispose();
    _emailPressRecognizer.dispose();
  }

  Maze getMaze() {
    return BlocProvider.of<GameBloc>(context).state.maze;
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
      duration: const Duration(milliseconds: Utils.animDurationMilliSeconds),
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
    return retval + (2 * Utils.wallThickness);
  }

  double whatIsTheLeftOffsetOfThisPixie({Pixie pixie}) {
    var retval = ((pixie.x - 1) * roomLength);
    return retval + Utils.wallThickness;
  }

  Widget makeRoom(Room room) {
    /*  rooms shall be changed to square containers in rows of a set width */
    final floorColor = Colors.green[200];
    final northColor =
        (room.downWallIsUp == true) ? Colors.green[700] : floorColor;
    final southColor =
        (room.upWallIsUp == true) ? Colors.green[700] : floorColor;
    final westColor =
        (room.leftWallIsUp == true) ? Colors.green[700] : floorColor;
    final eastColor =
        (room.rightWallIsUp == true) ? Colors.green[700] : floorColor;

    final endLeft = ((room.x - 1) * roomLength);
    final endTop = ((room.y - 1) * roomLength);

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

    return Scrollbar(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        scrollDirection: Axis.vertical,
        children: [column],
      ),
    );
  }

  void setDifficulty(GameDifficulty diff) {
    setState(() {
      difficulty = diff;
    });
  }

  void setNumRows(int val) {
    setState(() {
      numRows = val;
    });
  }

  Widget showOptions() {
    return EnOptions(
      numRows: numRows,
      difficulty: difficulty,
      setParentDifficulty: setDifficulty,
      setParentNumRows: setNumRows,
      startNewGame: startNewGame,
    );
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
      trs.clear();
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
      print('BlocBuilder build 4 trs== ${trs.length}');

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
      print('BlocBuilder build 4 sprite==${sprites.length}');
      Widget panel;
      if (BlocProvider.of<PanelBloc>(context).state is DishPanel) {
        print('is dish panel');
        if (MediaQuery.of(context).orientation == Orientation.landscape) {
          panel = Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    defineScoreRow(),
                  ],
                ),
                buildCenter(trs, maxWidth),
              ],
            ),
          );
        } else {
          panel = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        defineScoreRow(),
                      ],
                    ),
                  ],
                ),
                Center(child: buildCenter(trs, roomLength * numRows)),
              ],
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
        BlocProvider.of<GameBloc>(context).add(EndTurnEvent(
            'end turn  alice ${DateTime.now().millisecondsSinceEpoch}'));
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
    BlocProvider.of<PanelBloc>(context).add(ShowDishPanel());
  }
}
