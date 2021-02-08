import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_maze/features/panel/presentation/bloc/panel_bloc.dart';
import 'package:game_maze/generated/l10n.dart';
import 'package:game_maze/theme.dart';

class EnInfo extends StatefulWidget {
  EnInfo(this.maxWidth, this._emailPressRecognizer);
  final TapGestureRecognizer _emailPressRecognizer;
  final maxWidth;

  @override
  _EnInfoState createState() => _EnInfoState();
}

class _EnInfoState extends State<EnInfo> {
  @override
  Widget build(BuildContext context) {
    var infoTitle = RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: <TextSpan>[
        TextSpan(
          text: '${S.of(context).about}\n',
          style: theme.textTheme.headline2,
        ),
      ]),
    );
    var version = '';
    if (BlocProvider.of<PanelBloc>(context).state is AboutPanel) {
      AboutPanel ap = BlocProvider.of<PanelBloc>(context).state;
      version = ap.version;
    }
    Widget message = Scrollbar(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: S.of(context).aliceAndTheHedgeMaze,
                    style: theme.textTheme.bodyText1,
                  ),
                  TextSpan(
                    text: ' ${S.of(context).isASimpleMazeG} ',
                    style: theme.textTheme.bodyText2,
                  ),
                  TextSpan(
                    text: S.of(context).thesoftwaretaylorgmailcom,
                    style: theme.textTheme.bodyText1,
                    recognizer: widget._emailPressRecognizer,
                  ),
                  if (!kIsWeb)
                    TextSpan(
                      text: version,
                      style: theme.textTheme.bodyText2,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.maxWidth > 500 ||
        MediaQuery.of(context).orientation == Orientation.landscape) {
      message = Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
        child: message,
      );
    }
    if (kIsWeb) {
      message = Container(width: widget.maxWidth, child: message);
    }
    var column = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        infoTitle,
        message,
      ],
    );

    return Scrollbar(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        scrollDirection: Axis.vertical,
        children: [column],
      ),
    );
  }
}
