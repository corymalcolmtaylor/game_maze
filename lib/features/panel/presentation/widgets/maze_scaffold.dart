import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_maze/core/utils.dart';
import 'package:game_maze/features/game/presentation/bloc/game_bloc.dart';
import 'package:game_maze/features/game/presentation/widgets/maze_area.dart';
import 'package:game_maze/features/panel/presentation/bloc/panel_bloc.dart';
import 'package:game_maze/generated/l10n.dart';
import 'package:game_maze/theme.dart';

import 'maze_button.dart';

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
      var showDishButton = (getPanelBloc().state is! DishPanel);
      var showOptionsButton =
          !showDishButton && getPanelBloc().state is! SettingsPanel;
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.black,
          centerTitle: false,
          title: Text(strtitle, style: theme.textTheme.headline6),
          actions: <Widget>[
            if (showDishButton)
              Container(
                margin: const EdgeInsets.all(10.0),
                child: MazeButton(
                  key: const Key('Dish'),
                  onclick: () {
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
                child: MazeButton(
                  onclick: () {
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
                  getPanelBloc().add(const ShowRulesPanel());
                  print('icon button, Show Rules');
                } else if (result == GameActions.about) {
                  getPanelBloc().add(const ShowAboutPanel());
                  print('icon button, Show about');
                }
              },
              color: Colors.grey[900],
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<GameActions>>[
                if (!showOptionsButton)
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
}
