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
import 'package:game_maze/features/panel/presentation/widgets/en_dish.dart';
import 'package:game_maze/features/panel/presentation/widgets/en_info.dart';
import 'package:game_maze/features/panel/presentation/widgets/en_options.dart';
import 'package:game_maze/features/panel/presentation/widgets/en_rules.dart';
import 'package:game_maze/generated/l10n.dart';
import 'package:game_maze/theme.dart';
import 'package:url_launcher/url_launcher.dart';

import 'start_new_game.dart';

class MazeArea extends StatefulWidget {
  @override
  _MazeAreaState createState() {
    return _MazeAreaState();
  }
}

class _MazeAreaState extends State<MazeArea>
    with SingleTickerProviderStateMixin {
  int numRows = 8;
  final maximumMoveAttempts = 8;

  var sprites = <Widget>[];

  var roomLength = 0.0;
  var maxWidth = 0.0;

  GameDifficulty difficulty = GameDifficulty.normal;

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

  @override
  Widget build(BuildContext context) {
    print('mazearea build id ${getMaze().randomid}');
    setSizes();
    var trs = <Widget>[];
    Widget otherPanel;

    if (getPanelBloc().state is RulesPanel) {
      otherPanel = EnRules(maxWidth);
    } else if (getPanelBloc().state is SettingsPanel) {
      otherPanel = EnOptions(
        numRows: numRows,
        difficulty: difficulty,
        setParentDifficulty: setDifficulty,
        setParentNumRows: setNumRows,
        startNewGame: startNewGame,
      );
    } else if (getPanelBloc().state is AboutPanel) {
      otherPanel = EnInfo(maxWidth, _emailPressRecognizer);
    }
    return BlocBuilder<GameBloc, GameState>(builder: (context, mazestate) {
      print('BlocBuilder build 1 ${mazestate.maze.randomid}  ');

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
        print('state is dish panel');
        panel = EnDish(
            maxWidth: maxWidth,
            roomLength: roomLength,
            numRows: numRows,
            sprites: [...sprites],
            trs: [...trs],
            startNewGame: startNewGame);
      } else {
        print('state is NOT dish panel');
        panel = otherPanel;
      }
      if (BlocProvider.of<PanelBloc>(context).state is SettingsPanel)
        print('state is  settings panel ');
      if (BlocProvider.of<PanelBloc>(context).state is RulesPanel)
        print('state is  rules panel ');
      if (BlocProvider.of<PanelBloc>(context).state is AboutPanel)
        print('state is about panel ');
      return panel;
    });
  }

  void startNewGame() {
    BlocProvider.of<GameBloc>(context)
        .add(InitializeNewGameEvent(numRows, difficulty));
    BlocProvider.of<PanelBloc>(context).add(ShowDishPanel());
  }
}
