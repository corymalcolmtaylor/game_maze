import 'dart:io';

import 'package:flutter/material.dart';
import 'package:game_maze/generated/l10n.dart';
import 'package:game_maze/theme.dart';

class EnRules extends StatelessWidget {
  EnRules();

  @override
  Widget build(BuildContext context) {
    var notoalice = TextStyle(
      fontSize: 22,
      color: Colors.orange[800],
      fontFamily: 'NotoEmoji',
      backgroundColor: Colors.green[200],
    );
    var notogoblin = TextStyle(
        fontSize: 22,
        color: Colors.red[800],
        fontFamily: 'NotoEmoji',
        backgroundColor: Colors.green[200]);
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: S.of(context).rescueThem, //   swipeVerticallyOrH,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: '\n${S.of(context).alice}',
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
            text: '👧',
            style: !Platform.isAndroid ? notoalice : theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: ' ${S.of(context).toTouchThem}',
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: '\n${S.of(context).goblin}',
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
            text: '👺',
            style: !Platform.isAndroid ? notogoblin : theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).swipeVerticallyOrH,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).sheMovesOneStep,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).ifTheGoblinCap,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).difficultyModes,
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
            text: '\n${S.of(context).easy}',
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
            text: S.of(context).modeIsTheDefault,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: '\n\n${S.of(context).hard}',
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
              text: S.of(context).modeMeansThat,
              style: theme.textTheme.bodyText2),
          TextSpan(
            text: '\n\n${S.of(context).tough}',
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
            text: '${S.of(context).modeIsLikeHard} \n\n',
            style: theme.textTheme.bodyText2,
          ),
        ],
      ),
    );
  }
}
