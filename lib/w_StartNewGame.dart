import 'package:flutter/material.dart';

class StartNewGame extends StatelessWidget {
  final Function startgame;
  StartNewGame({this.startgame});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
      child: Container(
        child: OutlineButton(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
          borderSide: BorderSide(
              color: Colors.cyan, style: BorderStyle.solid, width: 1),
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
