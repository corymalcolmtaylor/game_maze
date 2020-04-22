import 'package:flutter/material.dart';
import './utils.dart';

class StartNewGame extends StatelessWidget {
  final Function startgame;
  StartNewGame({this.startgame});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
      child: Container(
        child: OutlineButton(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
          borderSide: BorderSide(
              color: Colors.cyan,
              style: BorderStyle.solid,
              width: Utils.WALLTHICKNESS + 1),
          onPressed: () {
            Navigator.of(context).pop();
            startgame();
          },
          child: Text(
            'Start Game',
            style: TextStyle(fontSize: 24, color: Colors.cyanAccent),
          ),
        ),
      ),
    );
  }
}
