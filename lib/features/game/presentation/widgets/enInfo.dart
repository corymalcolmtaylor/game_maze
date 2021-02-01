import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_maze/features/panel/presentation/bloc/panel_bloc.dart';
import 'package:game_maze/generated/l10n.dart';
import 'package:game_maze/theme.dart';

import 'w_MazeBackButton.dart';

class EnInfo extends StatefulWidget {
  EnInfo(this._emailPressRecognizer);
  final TapGestureRecognizer _emailPressRecognizer;

  @override
  _EnInfoState createState() => _EnInfoState();
}

class _EnInfoState extends State<EnInfo> {
  @override
  Widget build(BuildContext context) {
    var version = '';
    if (BlocProvider.of<PanelBloc>(context).state is AboutPanel) {
      AboutPanel ap = BlocProvider.of<PanelBloc>(context).state;
      version = ap.version;
    }

    return Scrollbar(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
                textAlign: TextAlign.left,
                text: TextSpan(children: <TextSpan>[
                  TextSpan(
                    text: S.of(context).aliceAndTheHedgeMaze,
                    style: theme.textTheme.headline4,
                  ),
                  TextSpan(
                    text: S.of(context).isASimpleMazeG,
                    style: theme.textTheme.headline6
                        .copyWith(color: Colors.cyanAccent),
                  ),
                  TextSpan(
                    text: S.of(context).thesoftwaretaylorgmailcom,
                    style: theme.textTheme.bodyText2,
                    recognizer: widget._emailPressRecognizer,
                  ),
                  if (!kIsWeb)
                    TextSpan(
                      text: version,
                      style: theme.textTheme.bodyText2,
                    ),
                ])),
            MazeBackButton(),
          ],
        ),
      ),
    );
  }
}
