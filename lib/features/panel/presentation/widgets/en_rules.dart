import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:game_maze/generated/l10n.dart';
import 'package:game_maze/theme.dart';

class EnRules extends StatelessWidget {
  final double maxWidth;
  EnRules(this.maxWidth);

  @override
  Widget build(BuildContext context) {
    var rulesTitle = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: <TextSpan>[
        TextSpan(
          text: '${S.of(context).rules}\n',
          style: theme.textTheme.headline2,
        ),
      ]),
    );
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
    Widget message;

    message = RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: S.of(context).rescueThem, //   swipeVerticallyOrH,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: '${S.of(context).alice}',
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
            text: '${S.of(context).goblin}',
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
}
