import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_maze/core/maze.dart';
import 'package:game_maze/core/utils.dart';
import 'package:game_maze/features/game/presentation/bloc/game_bloc.dart';
import 'package:game_maze/features/game/presentation/widgets/start_new_game.dart';
import 'package:game_maze/features/panel/presentation/bloc/panel_bloc.dart';
import 'package:game_maze/generated/l10n.dart';
import 'package:game_maze/theme.dart';

import 'maze_back_button.dart';

class EnOptions extends StatefulWidget {
  EnOptions({
    this.numRows,
    this.difficulty,
    this.setParentDifficulty,
  });
  final Function setParentDifficulty;
  final int numRows;
  final GameDifficulty difficulty;
  @override
  _EnOptionsState createState() => _EnOptionsState();
}

class _EnOptionsState extends State<EnOptions> {
  String getDifficulty(difficulty) {
    if (difficulty == GameDifficulty.hard) return Utils.hard;
    if (difficulty == GameDifficulty.tough) return Utils.tough;
    return Utils.normal;
  }

  GameDifficulty setMazeDifficulty(newValue) {
    if (newValue == Utils.hard)
      return GameDifficulty.hard;
    else if (newValue == Utils.tough)
      return GameDifficulty.tough;
    else
      return GameDifficulty.normal;
  }

  Maze getMaze() {
    return BlocProvider.of<GameBloc>(context).state.maze;
  }

  void startGame({int numRows, GameDifficulty difficulty}) {
    BlocProvider.of<GameBloc>(context)
        .add(InitializeNewGameEvent(numRows, difficulty));
    BlocProvider.of<PanelBloc>(context).add(const ShowDishPanel());
  }

  @override
  Widget build(BuildContext context) {
    print('build enoptions diff== ${widget.difficulty}');
    var title = S.of(context).gameOver;
    var msg = getMaze().getGameOverMessage();
    int numRowsInner = widget.numRows;
    GameDifficulty difficulty = widget.difficulty;

    if (!getMaze().gameIsOver()) {
      title = S.current.options;
      msg = '';
    }

    var emojiTextStyle = TextStyle(
      fontSize: 22,
      color: Colors.yellow,
      fontFamily: 'NotoEmoji',
    );

    return SingleChildScrollView(
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
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(10.0)),
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

                                setState(() {
                                  print('new val == $numRowsInner');
                                });
                              },
                              items: <String>[
                                '8',
                                '10',
                                '12',
                                '14'
                              ].map<DropdownMenuItem<String>>((String value) {
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
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(10.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: DropdownButtonHideUnderline(
                          child: new Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Colors.black87,
                            ),
                            child: DropdownButton<String>(
                              key: Key('PICKDIFFICULTY'),
                              isDense: true,
                              value: getDifficulty(difficulty),
                              onChanged: (String newValue) {
                                difficulty = setMazeDifficulty(newValue);
                                widget.setParentDifficulty(difficulty);
                                setState(() {
                                  print('n dif ${getDifficulty(difficulty)}');
                                });
                              },
                              items: <String>[
                                Utils.normal,
                                Utils.hard,
                                Utils.tough
                              ].map<DropdownMenuItem<String>>((String value) {
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
          if (MediaQuery.of(context).orientation == Orientation.landscape)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                StartNewGame(
                    startgame: startGame,
                    numRows: numRowsInner,
                    difficulty: difficulty),
              ],
            ),
          if (MediaQuery.of(context).orientation == Orientation.portrait)
            StartNewGame(
                startgame: startGame,
                numRows: numRowsInner,
                difficulty: difficulty),
          //if (title == S.of(context).gameOver) MazeBackButton(),
        ],
      ),
    );
  }
}
