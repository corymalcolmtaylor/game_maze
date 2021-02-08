import 'package:flutter/material.dart';
import 'package:game_maze/theme.dart';
import 'package:game_maze/core/utils.dart';
import 'package:game_maze/generated/l10n.dart';

class StartNewGame extends StatelessWidget {
  final int numRows;
  final GameDifficulty difficulty;
  final startgame;

  StartNewGame({this.numRows, this.difficulty, this.startgame});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
      child: Container(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            side: BorderSide(
                color: Colors.cyan,
                style: BorderStyle.solid,
                width: Utils.borderWallThickness),
          ),
          onPressed: () {
            startgame();
          },
          child: Text(
            S.of(context).startGame,
            style: theme.textTheme.bodyText2,
          ),
        ),
      ),
    );
  }
}
