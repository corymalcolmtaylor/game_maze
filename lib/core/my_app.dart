import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:game_maze/features/game/presentation/bloc/game_bloc.dart';
import 'package:game_maze/features/panel/presentation/bloc/panel_bloc.dart';
import 'package:game_maze/features/panel/presentation/widgets/maze_scaffold.dart';
import 'package:game_maze/generated/l10n.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        onGenerateTitle: (context) => S.of(context).aliceAndTheHedgeMaze,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          S.delegate
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<PanelBloc>(
              create: (BuildContext context) => PanelBloc(),
            ),
            BlocProvider<GameBloc>(
              create: (BuildContext context) => GameBloc(),
            ),
          ],
          child: MazeScaffold(),
        ));
  }
}
