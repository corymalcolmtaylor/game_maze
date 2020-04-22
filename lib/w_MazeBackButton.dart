import 'package:flutter/material.dart';
import './utils.dart';

class MazeBackButton extends StatelessWidget {
  final Function setstate;

  MazeBackButton({this.setstate});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 1, 6, 1),
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
            setstate();
          },
          child: Text('Back',
              style: TextStyle(fontSize: 24, color: Colors.cyanAccent)),
        ),
      ),
    );
  }
}
