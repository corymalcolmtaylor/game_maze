import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_maze/core/maze.dart';
import 'package:game_maze/core/utils.dart';
import 'package:game_maze/features/game/presentation/bloc/game_bloc.dart';
import 'package:game_maze/features/game/presentation/widgets/start_new_game.dart';
import 'package:game_maze/features/panel/presentation/bloc/panel_bloc.dart';
import 'package:game_maze/generated/l10n.dart';
import 'package:game_maze/theme.dart';

class EnDish extends StatefulWidget {
  EnDish(
      {this.maxWidth,
      this.roomLength,
      this.numRows,
      this.trs,
      this.sprites,
      this.startNewGame});

  final double maxWidth;
  final double roomLength;
  final int numRows;
  final List<Widget> sprites;
  final List<Widget> trs;
  final Function startNewGame;

  @override
  _EnDishState createState() => _EnDishState();
}

class _EnDishState extends State<EnDish> {
  var hDelta = 0.0;
  var vDelta = 0.0;
  Directions dir;
  GameDifficulty difficulty;

  Maze getMaze() {
    return BlocProvider.of<GameBloc>(context).state.maze;
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

  GestureDetector buildCenter(List<Widget> trs, double stackSize) {
    return GestureDetector(
      onHorizontalDragEnd: (dragDetails) {
        if (getMaze().gameIsOver()) {
          BlocProvider.of<PanelBloc>(context).add(ShowSettingsPanel());
        } else {
          if (hDelta.abs() > 25) {
            movePlayer(direction: dir);
          }
        }
        hDelta = 0;
      },
      onVerticalDragEnd: (dragDetails) {
        if (getMaze().gameIsOver()) {
          BlocProvider.of<PanelBloc>(context).add(ShowSettingsPanel());
        } else {
          if (vDelta.abs() > 25) {
            movePlayer(direction: dir);
          }
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
        if (getMaze().gameIsOver()) {
          BlocProvider.of<PanelBloc>(context).add(ShowSettingsPanel());
        } else {
          BlocProvider.of<GameBloc>(context).add(EndTurnEvent(
              'end turn alice ${DateTime.now().millisecondsSinceEpoch}'));
        }
      },
      child: SizedBox(
        width: stackSize,
        height: stackSize,
        child: Stack(
            clipBehavior: Clip.none, children: [...trs, ...widget.sprites]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(flex: 1, child: defineScoreRow()),
                if (getMaze().gameIsOver())
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          StartNewGame(
                              numRows: widget.numRows,
                              difficulty: difficulty,
                              startgame: widget.startNewGame),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: (widget.maxWidth),
                                child: Text(
                                  getMaze().getGameOverMessage(),
                                  maxLines: 12,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyText1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
            buildCenter(widget.trs, widget.maxWidth),
          ],
        ),
      );
    } else {
      return Center(
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
            Center(
                child: buildCenter(
                    widget.trs, widget.roomLength * widget.numRows)),
            if (getMaze().gameIsOver())
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      StartNewGame(
                          numRows: widget.numRows,
                          difficulty: difficulty,
                          startgame: widget.startNewGame),
                      Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                          child: Text(
                            getMaze().getGameOverMessage(),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyText1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      );
    }
  }
}
