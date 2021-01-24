import 'package:flutter/material.dart';

import 'utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pixie.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class Pixie {
  Pixie(this.ilk);
  factory Pixie.fromJson(Map<String, dynamic> json) => _$PixieFromJson(json);
  Map<String, dynamic> toJson() => _$PixieToJson(this);

  var key = (DateTime.now().millisecondsSinceEpoch + Utils.rand.nextInt(999999))
      .toString();
  var location = '';
  var lastLocation = '';
  var emoji = '';

  var _movesLeft = 1;
  var x = 0;
  var y = 0;
  var lastX = 0;
  var lastY = 0;
  var savedLambs = 0;
  var lostLambs = 0;

  var delayComputerMove = true;
  var recentlyMoved = false;
  var follow = false;
  var isVisible = true;

  Directions newDirection;
  Directions direction;
  var facing = Directions.left;
  var ilk = Ilk.player;
  var condition = Condition.alive;

  var preferredColor = Colors.blue[800].value;

  int getMovesLeft() {
    return _movesLeft;
  }

  void setMovesLeft(movesLeft) {
    _movesLeft = movesLeft;
  }
}
