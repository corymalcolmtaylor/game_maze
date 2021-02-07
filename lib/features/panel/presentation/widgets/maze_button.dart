import 'package:flutter/material.dart';
import '../../../../core/utils.dart';

class MazeButton extends StatefulWidget {
  MazeButton(
      {Key key, this.onclick, this.label, this.tstyle, this.radius = 30.0})
      : super(key: key);
  final Function onclick;
  final String label;
  final TextStyle tstyle;
  final double radius;
  @override
  _MazeButtonState createState() => _MazeButtonState();
}

class _MazeButtonState extends State<MazeButton> {
  @override
  Widget build(BuildContext context) {
    var tcolor = widget.onclick == null ? Colors.grey : Colors.white;
    return Container(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          side: BorderSide(
              color: Colors.cyan,
              style: BorderStyle.solid,
              width: Utils.borderWallThickness),
        ),
        onPressed: widget.onclick,
        child: Text(
          widget.label,
          textAlign: TextAlign.center,
          textScaleFactor: 1.0,
          style: widget.tstyle.copyWith(color: tcolor),
        ),
      ),
    );
  }
}
