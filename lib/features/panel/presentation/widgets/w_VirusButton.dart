import 'package:flutter/material.dart';
import '../../../../core/utils.dart';

class VirusButton extends StatefulWidget {
  VirusButton(
      {Key key, this.onclick, this.label, this.tstyle, this.radius = 30.0})
      : super(key: key);
  final Function onclick;
  final String label;
  final TextStyle tstyle;
  final double radius;
  @override
  _VirusButtonState createState() => _VirusButtonState();
}

class _VirusButtonState extends State<VirusButton> {
  @override
  Widget build(BuildContext context) {
    var tcolor = widget.onclick == null ? Colors.grey : Colors.white;
    return Container(
      child: OutlineButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        borderSide: const BorderSide(
            color: Colors.cyan,
            style: BorderStyle.solid,
            width: Utils.borderWallThickness),
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
