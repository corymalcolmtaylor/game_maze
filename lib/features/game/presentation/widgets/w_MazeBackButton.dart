import 'package:flutter/material.dart';
import 'package:game_maze/theme.dart';
import 'package:game_maze/core/utils.dart';
import 'package:game_maze/generated/l10n.dart';

class MazeBackButton extends StatelessWidget {
  MazeBackButton();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 12, 6, 12),
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
          },
          child: Text(
            S.of(context).back,
            style: theme.textTheme.bodyText2,
          ),
        ),
      ),
    );
  }
}
