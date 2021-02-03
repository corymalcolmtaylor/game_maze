import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_maze/core/utils.dart';
import 'package:game_maze/features/game/presentation/bloc/game_bloc.dart';
import 'package:game_maze/features/game/presentation/widgets/w_MazeBackButton.dart';
import 'package:game_maze/features/panel/presentation/bloc/panel_bloc.dart';
import 'package:game_maze/generated/l10n.dart';
import 'package:game_maze/theme.dart';
import 'package:url_launcher/url_launcher.dart';

import 'maze_area.dart';
import 'w_VirusButton.dart';

class MazeScaffold extends StatefulWidget {
  @override
  _MazeScaffoldState createState() => _MazeScaffoldState();
}

class _MazeScaffoldState extends State<MazeScaffold> {
  PanelBloc getPanelBloc() {
    return BlocProvider.of<PanelBloc>(context);
  }

  GameBloc getMazeBloc() {
    return BlocProvider.of<GameBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    var strtitle = S.of(context).aliceAndTheHedgeMaze;
    print('****** MazeScaffold build OS: ${Platform.operatingSystem}');

    return BlocBuilder<PanelBloc, PanelState>(builder: (context, panelstate) {
      var showDishButton = (getPanelBloc().state is! DishPanel &&
          (getMazeBloc().state is! InitialGame));
      var showOptionsButton = (getPanelBloc().state is DishPanel ||
          ((getMazeBloc().state is LoadedGame) &&
              getPanelBloc().state is! SettingsPanel));
      return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.black,
          centerTitle: false,
          title: Text(strtitle, style: theme.textTheme.headline6),
          actions: <Widget>[
            if (showDishButton)
              Container(
                margin: const EdgeInsets.all(10.0),
                child: VirusButton(
                  key: const Key('Dish'),
                  onclick: () {
                    // Respond to button press
                    getPanelBloc().add(const ShowDishPanel());
                    print('VirusButton, Show dish ');
                  },
                  label: S.of(context).maze,
                  tstyle: theme.textTheme.headline6,
                  radius: 20.0,
                ),
              ),
            if (showOptionsButton)
              Container(
                margin: const EdgeInsets.all(10.0),
                child: VirusButton(
                  onclick: () {
                    // Respond to button press
                    getPanelBloc().add(const ShowSettingsPanel());
                    print('icon button, Show settings ');
                  },
                  label: S.of(context).options,
                  tstyle: theme.textTheme.headline6,
                  radius: 20.0,
                ),
              ),
            PopupMenuButton<GameActions>(
              onSelected: (GameActions result) {
                if (result == GameActions.options) {
                  getPanelBloc().add(const ShowSettingsPanel());
                  print('PopupMenuButton, Show options');
                } else if (result == GameActions.rules) {
                  //showRules(context);
                  getPanelBloc().add(const ShowRulesPanel());
                  print('icon button, Show Rules');
                } else if (result == GameActions.about) {
                  //showInformation(context);
                  getPanelBloc().add(const ShowAboutPanel());
                  print('icon button, Show about');
                }
              },
              color: Colors.grey[900],
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<GameActions>>[
                if (!showOptionsButton &&
                    getPanelBloc().state is! SettingsPanel)
                  PopupMenuItem<GameActions>(
                    enabled: (getPanelBloc().state is! SettingsPanel),
                    value: GameActions.options,
                    child: Text(
                      S.of(context).options,
                      textScaleFactor: maxTSF(context),
                      style: (getPanelBloc().state is! SettingsPanel)
                          ? theme.textTheme.headline6
                          : theme.textTheme.headline6
                              .copyWith(color: Colors.grey[500]),
                    ),
                  ),
                PopupMenuItem<GameActions>(
                  enabled: (getPanelBloc().state is! RulesPanel),
                  value: GameActions.rules,
                  child: Text(
                    S.of(context).rules,
                    textScaleFactor: maxTSF(context),
                    style: (getPanelBloc().state is! RulesPanel)
                        ? theme.textTheme.headline6
                        : theme.textTheme.headline6
                            .copyWith(color: Colors.grey[500]),
                  ),
                ),
                PopupMenuItem<GameActions>(
                  enabled: (getPanelBloc().state is! AboutPanel),
                  value: GameActions.about,
                  child: Text(
                    S.of(context).about,
                    textScaleFactor: maxTSF(context),
                    style: (getPanelBloc().state is! AboutPanel)
                        ? theme.textTheme.headline6
                        : theme.textTheme.headline6
                            .copyWith(color: Colors.grey[500]),
                  ),
                )
              ],
            ),
          ],
        ),
        body: MazeArea(),
      );
    });
  }

  Future<void> showRulesxreturn(BuildContext context) async {
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
    RichText message = RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: S.of(context).rescueThem, //   swipeVerticallyOrH,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).alice,
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
            text: '👧',
            style: !Platform.isAndroid ? notoalice : theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).toTouchThem,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).goblin,
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
            text: S.of(context).easy,
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
            text: S.of(context).modeIsTheDefault,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).hard,
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
              text: S.of(context).modeMeansThat,
              style: theme.textTheme.bodyText2),
          TextSpan(
            text: S.of(context).tough,
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
            text: S.of(context).modeIsLikeHard,
            style: theme.textTheme.bodyText2,
          ),
        ],
      ),
    );

    return showDialog<void>(
      context: context,

      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: Center(
              child: Text(
                S.of(context).rules,
                style: theme.textTheme.headline2,
              ),
            ),
            content: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    message,
                    MazeBackButton(),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> showInformationx(BuildContext context) {
    Text title = Text(
      S.of(context).aliceAndTheHedgeMaze,
      style: theme.textTheme.headline4,
    );
    Text message = Text(
      S.of(context).isASimpleMazeG,
      style: theme.textTheme.bodyText2,
    );
    Text emailText = Text(S.of(context).thesoftwaretaylorgmailcom,
        style: theme.textTheme.headline6.copyWith(color: Colors.cyanAccent));
    GestureDetector emaillink = GestureDetector(
      child: emailText,
      onTap: () {
        print('email tapped');
        _launchURL(context);
      },
    );
    var alert = AlertDialog(
      backgroundColor: Colors.black87,
      title: Center(
        child: Text(
          S.of(context).about,
          style: theme.textTheme.headline2,
        ),
      ),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              title,
              message,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: emaillink,
              ),
              MazeBackButton(),
            ],
          ),
        ),
      ),
    );
    return showDialog<void>(
      context: context,

      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return alert;
          },
        );
      },
    );
  }

  Future<void> _launchURL(BuildContext context) async {
    var url =
        '${S.of(context).mailtothesoft}${S.of(context).aliceAndTheHedgeMaze}';
    try {
      if (await canLaunch(url)) {
        print('try to launch');
        await launch(url);
      } else {
        throw '${S.of(context).couldNotLaunch} $url';
      }
    } catch (e) {
      print('catch e ${e.toString()}');
    }
  }
}
