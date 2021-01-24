import 'package:flutter/material.dart';
import 'package:game_maze/theme.dart';
import 'package:game_maze/core/utils.dart';
import 'package:game_maze/generated/l10n.dart';

class StartNewGame extends StatelessWidget {
  final Function startgame;
  StartNewGame({this.startgame});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
            Navigator.of(context).pop();
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
