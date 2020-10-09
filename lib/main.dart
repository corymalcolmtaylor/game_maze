import 'package:flutter/material.dart';

import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

import 'maze.dart';
import 'w_StartNewGame.dart';
import 'w_MazeBackButton.dart';
import './utils.dart';

//void main() => runApp(MyApp());
void main() => runApp(
      MyApp(),
    );

class MazeScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var strtitle = Utils.TITLE;
    if (Platform.isIOS) {
      strtitle = Utils.TITLE_ios;
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.black,
        centerTitle: false,
        title: Text(strtitle,
            style: TextStyle(color: Colors.cyanAccent, fontSize: 14)),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: OutlineButton(
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0),
              ),
              color: Colors.cyanAccent,
              borderSide: BorderSide(
                  color: Colors.cyan,
                  style: BorderStyle.solid,
                  width: Utils.WALLTHICKNESS + 1),

              onPressed: () {
                showRules(context);
                print('icon cc button, Show Rules');
              },
              child: Text('Rules',
                  style: TextStyle(color: Colors.cyanAccent, fontSize: 18)),
              //shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: OutlineButton(
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(20.0),
              ),
              color: Colors.cyanAccent,
              borderSide: BorderSide(
                  color: Colors.cyan,
                  style: BorderStyle.solid,
                  width: Utils.WALLTHICKNESS + 1),
              textColor: Colors.white,
              onPressed: () {
                showInformation(context);
                print('icon button, Show info');
              },
              child: Text(
                'About',
                style: TextStyle(color: Colors.cyanAccent, fontSize: 18),
              ),
              //shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ),
        ],
      ),
      body: MazeArea(),
    );
  }

  Future<void> showRules(BuildContext context) async {
    const textstyle = TextStyle(
      fontSize: 22,
      color: Colors.cyanAccent,
    );
    var notoalice = TextStyle(
        fontSize: 22,
        color: Colors.orange[800],
        fontFamily: 'NotoEmoji',
        backgroundColor: Colors.green[200]);
    var notogoblin = TextStyle(
        fontSize: 22,
        color: Colors.red[800],
        fontFamily: 'NotoEmoji',
        backgroundColor: Colors.green[200]);
    RichText message = RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'Swipe verticaly or horizontally on the maze to move Alice ',
            style: textstyle,
          ),
          TextSpan(
            text: '👧..\n',
            style: Platform.isIOS ? notoalice : textstyle,
          ),
          TextSpan(
            text: 'She moves one step at a time and gets three per turn.\n' +
                'End her turn early by moving into a wall or double tapping.\n' +
                'Rescue the animals by getting Alice to them before they get ' +
                'captured by the goblin  ',
            style: textstyle,
          ),
          TextSpan(
            text: '👺.\n',
            style: Platform.isIOS ? notogoblin : textstyle,
          ),
          TextSpan(
            text: 'If the goblin captures Alice the game ends in defeat '
                'but otherwise if you save more animals than the goblin '
                'captures you win.\n'
                'Difficulty modes:\n'
                'Easy mode is the default mode, in Easy mode you can see '
                'everything.\n'
                'Hard mode means that you cannot see the other '
                'characters until Alice can.\n'
                'Tough mode is like Hard mode but now the Goblin will '
                'not capture any animals, in this way it wll not cause '
                'its own defeat by capturing the last animal after the '
                'player has already captured more than half and will '
                'have more time to catch Alice.',
            style: textstyle,
          ),
        ],
      ),
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black54,
          title: Center(
            child: Text(
              'Rules',
              style: TextStyle(fontSize: 24, color: Colors.cyanAccent),
            ),
          ),
          content: Scrollbar(
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[message],
              ),
            ),
          ),
          actions: <Widget>[
            OutlineButton(
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
              color: Colors.cyanAccent,
              borderSide: BorderSide(
                  color: Colors.cyan,
                  style: BorderStyle.solid,
                  width: Utils.WALLTHICKNESS + 1),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(fontSize: 24, color: Colors.cyanAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void showInformation(BuildContext context) {
    Text message = Text(
      'About ${Utils.TITLE} - \n' +
          'If you have any suggestions or find a bug please let us know.\n\n' +
          'Developer email:',
      style: TextStyle(fontSize: 22, color: Colors.cyanAccent),
    );
    Text emailText = Text(
      'thesoftwaretaylor@gmail.com',
      style: TextStyle(
          fontSize: 18,
          decoration: TextDecoration.underline,
          color: Colors.cyanAccent),
    );
    GestureDetector emaillink = GestureDetector(
      child: emailText,
      onTap: () {
        print('email tapped');
        _launchURL();
      },
    );
    var alert = AlertDialog(
      backgroundColor: Colors.black54,
      title: Center(
        child: Text(
          'Information',
          style: TextStyle(fontSize: 24, color: Colors.cyanAccent),
        ),
      ),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[message, emaillink],
          ),
        ),
      ),
      actions: <Widget>[
        OutlineButton(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
          color: Colors.cyanAccent,
          borderSide: BorderSide(
              color: Colors.cyan,
              style: BorderStyle.solid,
              width: Utils.WALLTHICKNESS + 1),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'OK',
            style: TextStyle(fontSize: 24, color: Colors.cyanAccent),
          ),
        ),
      ],
    );
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> _launchURL() async {
    const url =
        'mailto:thesoftwaretaylor@gmail.com?subject=HedgeMaze&body=Notes';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Utils.TITLE,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        textTheme: TextTheme(
          headline6: TextStyle(color: Colors.cyanAccent),
          bodyText2: TextStyle(color: Colors.cyanAccent),
        ),
      ),
      home: MazeScaffold(),
    );
  }
}

class MazeArea extends StatefulWidget {
  @override
  _MazeAreaState createState() {
    return _MazeAreaState();
  }
}

class _MazeAreaState extends State<MazeArea>
    with SingleTickerProviderStateMixin {
  Maze maze;
  int numRows = 8;

  final maximumMoveAttempts = 8;

  var sprites = <Widget>[];

  var roomLength = 0.0;
  var maxWidth = 0.0;
  var hDelta = 0.0;
  var vDelta = 0.0;

  @override
  void initState() {
    super.initState();
    maze = Maze(numRows);
    maze.carveLabyrinth();
  }

  void startNewGameAndSetState() {
    startNewGame();
    setState(() {
      print('started new game');
    });
  }

  void setMyState() {
    setState(() {
      print('started new game');
    });
  }

  AnimatedPositioned getAnimatedSpriteIconThisPixie({@required Pixie pixie}) {
    var endTop = 0.0;
    var endLeft = 0.0;

    var radians = 0.0;
    if (pixie.lastX > 0 && pixie.x < pixie.lastX) {
      radians = 3.0;
    }
    //if earlier versions of android the goblin needs to switch direction facing
    if (pixie.ilk == Ilk.minotaur) {
      //Platform.isAndroid &&
      if (radians == 3) {
        radians = 0.0;
      } else {
        radians = 3.0;
      }
    }

    endLeft = whatIsTheLeftOffsetOfThisPixie(pixie: pixie);
    endTop = whatIsTheTopOffsetOfThisPixie(pixie: pixie);

    return getAnimatedPositionedForThisPixie(
        pixie: pixie, endLeft: endLeft, endTop: endTop, radians: radians);
  }

  List<AnimatedPositioned> getAnimatedSpriteIconsForLambs(Room room) {
    var endTop = 0.0;
    var endLeft = 0.0;
    List<AnimatedPositioned> icons = [];

    var lambs = maze.lambs.where(
      (el) => el.location == 'b_${room.x}_${room.y}',
    );

    lambs.forEach((pixie) {
      var radians = 0.0;
      if (pixie.x != pixie.lastX) {
        if (pixie.x > pixie.lastX) {
          radians = 3.0;
          pixie.facing = Directions.right;
        } else {
          radians = 6.0;
          pixie.facing = Directions.left;
        }
      }

      if (pixie.condition == Condition.dead) {
        pixie.emoji = '💀';
      }

      endLeft = whatIsTheLeftOffsetOfThisPixie(pixie: pixie);
      endTop = whatIsTheTopOffsetOfThisPixie(pixie: pixie);

      icons.add(
        getAnimatedPositionedForThisPixie(
            pixie: pixie, endLeft: endLeft, endTop: endTop, radians: radians),
      );
    });
    return icons;
  }

  AnimatedPositioned getAnimatedPositionedForThisPixie(
      {Pixie pixie, double endLeft, double endTop, double radians}) {
    return AnimatedPositioned(
      width: roomLength,
      key: Key(pixie.key),
      left: endLeft,
      top: endTop,
      height: whatIsTheEmojiFontSizeOfThisPixie(pixie: pixie),
      curve: Curves.linear,
      duration: Duration(milliseconds: Utils.animDurationMilliSeconds),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(1, 1, 1) // perspective
            ..rotateX(0)
            ..rotateY(radians),
          alignment: FractionalOffset.center,
          child: getEmojiText(pixie),
        ),
      ),
    );
  }

  Widget getEmojiText(Pixie pixie) {
    if (Platform.isIOS) {
      return Text(
        pixie.emoji,
        textScaleFactor: 0.8,
        style: TextStyle(
          height: 1.0,
          fontFamily: 'NotoEmoji',
          color: maze.isEasy() || pixie.isVisible
              ? pixie.preferredColor
              : Colors.transparent,
          fontSize: whatIsTheEmojiFontSizeOfThisPixie(pixie: pixie),
        ),
      );
    } else {
      return Text(
        pixie.emoji,
        textScaleFactor: 0.8,
        style: TextStyle(
          height: 1.0,
          color: maze.isEasy() || pixie.isVisible
              ? Colors.black
              : Colors.transparent,
          fontSize: whatIsTheEmojiFontSizeOfThisPixie(pixie: pixie),
        ),
      );
    }
  }

  double whatIsTheEmojiFontSizeOfThisPixie({Pixie pixie}) {
    return roomLength - (Utils.WALLTHICKNESS * 3);
  }

  double whatIsTheTopOffsetOfThisPixie({Pixie pixie}) {
    var retval = ((pixie.y - 1) * roomLength);
    //retval += roomLength * 0.1;
    return retval + (2 * Utils.WALLTHICKNESS);
  }

  double whatIsTheLeftOffsetOfThisPixie({Pixie pixie}) {
    var retval = ((pixie.x - 1) * roomLength);
    return retval + Utils.WALLTHICKNESS;
  }

  void computerMove({bool delayMove}) async {
    if (maze.gameIsOver() ||
        !maze.lambs.any((lamb) => lamb.condition == Condition.alive)) {
      maze.setGameIsOver(true);
      handleEndOfGame();
      return;
    }

    int minoDelay = 0;
    if (delayMove) {
      minoDelay = Utils.animDurationMilliSeconds;
    }
    var lambDelay = 0;
    if (maze.getWhosTurnIsIt() == Ilk.minotaur) {
      lambDelay = Utils.animDurationMilliSeconds;
      Future.delayed(Duration(milliseconds: minoDelay), () {
        //maze.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
        maze.moveMinotaur();
        setState(() {
          // just force redraw
        });
      });
    }

    Future.delayed(Duration(milliseconds: minoDelay + lambDelay), () {
      var gameOver = maze.moveLambs();
      maze.clearLocationsOfLambsInThisCondition(condition: Condition.dead);

      setState(() {
        // just force redraw
      });

      if (gameOver) {
        Future.delayed(
            Duration(milliseconds: 1 * Utils.animDurationMilliSeconds), () {
          handleEndOfGame();
        });
      } else {
        maze.preparePlayerForATurn();
      }
    }).then((_) {
      Future.delayed(Duration(milliseconds: Utils.animDurationMilliSeconds),
          () {
        print('clear freed 2');
        maze.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
        setState(() {
          // just force redraw
        });
      });
    });
  }

  void handleEndOfGame() {
    String str = '';
    maze.eogEmoji = '';
    if (maze.player.condition == Condition.dead) {
      str = 'The Goblin got Alice! ️';
      maze.eogEmoji = '😞';
    } else {
      if (maze.player.savedLambs > maze.player.lostLambs) {
        str = 'You rescued ${maze.player.savedLambs}!\nYou WIN! ';
        maze.eogEmoji = '😀';
      } else if (maze.player.savedLambs == maze.player.lostLambs) {
        str =
            '${maze.player.savedLambs} rescued and captured.\nResult is a draw. ';
        maze.eogEmoji = '😐';
      } else {
        str = 'Goblin captured ${maze.player.lostLambs}. ';
        maze.eogEmoji = '😞';
      }
    }
    maze.gameOverMessage = str;

    showGameOverMessage();
  }

  Widget makeRoom(Room room) {
    /*  rooms shall be changed to square containers in rows of a set width */
    var floorColor = Colors.green[200];
    var northColor =
        (room.downWallIsUp == true) ? Colors.green[700] : floorColor;
    var southColor = (room.upWallIsUp == true) ? Colors.green[700] : floorColor;
    var westColor =
        (room.leftWallIsUp == true) ? Colors.green[700] : floorColor;
    var eastColor =
        (room.rightWallIsUp == true) ? Colors.green[700] : floorColor;

    var endLeft = ((room.x - 1) * roomLength);
    var endTop = ((room.y - 1) * roomLength);

    return Positioned(
      key: Key("room${room.x}_${room.y}"),
      left: endLeft,
      top: endTop,
      child: Container(
        width: roomLength,
        height: roomLength,
        decoration: BoxDecoration(
          color: floorColor,
          border: Border(
            bottom: BorderSide(color: southColor, width: Utils.WALLTHICKNESS),
            top: BorderSide(color: northColor, width: Utils.WALLTHICKNESS),
            right: BorderSide(color: eastColor, width: Utils.WALLTHICKNESS),
            left: BorderSide(color: westColor, width: Utils.WALLTHICKNESS),
          ),
        ),
      ),
    );
  }

  String getMazeDifficulty() {
    if (maze.difficulty == Difficulty.hard) return Utils.HARD;
    if (maze.difficulty == Difficulty.tough) return Utils.TOUGH;
    return Utils.EASY;
  }

  void setMazeDifficulty(newValue) {
    if (newValue == Utils.HARD)
      maze.difficulty = Difficulty.hard;
    else if (newValue == Utils.TOUGH)
      maze.difficulty = Difficulty.tough;
    else
      maze.difficulty = Difficulty.easy;
  }

  Future<void> showGameOverMessage() async {
    const NEWGAME = 'New Game';
    const GAMEOVER = 'Game Over';
    var title = GAMEOVER;
    var msg = maze.getGameOverMessage();
    const MAZEDIMENSIONS = 'Maze Size';

    if (!maze.gameIsOver()) {
      title = NEWGAME;
      msg = '';
    }

    var emojiTextStyle = TextStyle(
      fontSize: 22,
      color: Colors.yellow,
      fontFamily: 'NotoEmoji',
    );

    return showDialog<void>(
      context: context,

      barrierDismissible: false, // user must tap button!
      builder: (context) {
        var numRowsInner = numRows;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            contentPadding: EdgeInsets.all(2),
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(fontSize: 28, color: Colors.cyanAccent),
                  ),
                  if (msg != '')
                    RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                          text: msg,
                          style:
                              TextStyle(fontSize: 22, color: Colors.cyanAccent),
                        ),
                        TextSpan(
                          text: maze.getEogEmoji(),
                          style: emojiTextStyle,
                        ),
                      ]),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        MAZEDIMENSIONS,
                        style:
                            TextStyle(fontSize: 20, color: Colors.cyanAccent),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                            decoration: new BoxDecoration(
                              border: new Border.all(
                                  color: Colors.cyanAccent,
                                  width: Utils.WALLTHICKNESS + 1,
                                  style: BorderStyle.solid),
                              borderRadius: new BorderRadius.all(
                                  new Radius.circular(10.0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: DropdownButtonHideUnderline(
                                child: new Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Colors.black87,
                                  ),
                                  child: DropdownButton<String>(
                                    isDense: true,
                                    value: numRowsInner.toString(),
                                    onChanged: (String newValue) {
                                      numRowsInner = int.parse(newValue);
                                      numRows = numRowsInner;
                                      setState(() {
                                        print('new val == $numRowsInner');
                                      });
                                    },
                                    items: <String>['8', '10', '12', '14']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          '${value}x$value',
                                          textScaleFactor: 1.0,
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.cyanAccent),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Difficulty',
                        style:
                            TextStyle(fontSize: 20, color: Colors.cyanAccent),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                            decoration: new BoxDecoration(
                              border: new Border.all(
                                  color: Colors.cyanAccent,
                                  width: Utils.WALLTHICKNESS + 1,
                                  style: BorderStyle.solid),
                              borderRadius: new BorderRadius.all(
                                  new Radius.circular(10.0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: DropdownButtonHideUnderline(
                                child: new Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Colors.black87,
                                  ),
                                  child: DropdownButton<String>(
                                    isDense: true,
                                    value: getMazeDifficulty(),
                                    onChanged: (String newValue) {
                                      setMazeDifficulty(newValue);

                                      setState(() {
                                        print(' ');
                                      });
                                    },
                                    items: <String>[
                                      Utils.EASY,
                                      Utils.HARD,
                                      Utils.TOUGH
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          textScaleFactor: 1.0,
                                          overflow: TextOverflow.visible,
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.cyanAccent),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (MediaQuery.of(context).orientation ==
                          Orientation.landscape)
                        StartNewGame(
                          startgame: startNewGameAndSetState,
                        ),
                    ],
                  ),
                  if (MediaQuery.of(context).orientation ==
                      Orientation.portrait)
                    StartNewGame(
                      startgame: startNewGameAndSetState,
                    ),
                  if (title == NEWGAME) MazeBackButton(setstate: setMyState),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void setSizes() {
    maxWidth = MediaQuery.of(context).size.width;
    var maxHeight = MediaQuery.of(context).size.height;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      maxWidth = MediaQuery.of(context).size.height * 0.75;
    } else {
      if (maxWidth / maxHeight > 0.66) {
        maxWidth = maxWidth * 0.95;
      }
    }
    roomLength = (((maxWidth.floor() - (Utils.WALLTHICKNESS * (maze.maxRow))) /
            maze.maxRow))
        .floorToDouble();
  }

  Widget defineTopRow() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
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
            setState(() {
              handleEndOfGame();
            });
          },
          child: Text(
            'New Game',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 26, color: Colors.cyanAccent),
          ),
        ),
      ),
    );
  }

  Widget defineScoreRow() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: <Widget>[
              Text(
                'Alice Saved:',
                style: TextStyle(fontSize: 22),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
                  child: Text(
                    maze.player.savedLambs.toString(),
                    style: TextStyle(fontSize: 22),
                  )),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'Goblin Captured:',
                style: TextStyle(fontSize: 22),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
                  child: Text(
                    maze.player.lostLambs.toString(),
                    style: TextStyle(fontSize: 22),
                  )),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                'Moves left:',
                style: TextStyle(fontSize: 22),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
                  child: Text(
                    '${maze.player.movesLeft}',
                    style: TextStyle(fontSize: 22),
                  )),
            ],
          )
        ],
      ),
    );
  }

  Directions dir;
  @override
  Widget build(BuildContext context) {
    setSizes();
    var trs = <Widget>[];

    for (int i = 1; i <= maze.maxRow; i++) {
      trs.addAll(
        List.from(
          maze.myLabyrinth.entries
              .where((elroom) => elroom.value.y == i)
              .map(
                (el) => makeRoom(el.value),
              )
              .toList(),
        ),
      );
    }
    // add sprites
    maze.setPixiesVisibility();

    var llsprites = List.from(maze.myLabyrinth.entries.map(
      (el) => getAnimatedSpriteIconsForLambs(el.value),
    ));

    sprites.clear();
    llsprites.forEach((ll) {
      sprites.addAll(ll);
    });
    sprites.add(getAnimatedSpriteIconThisPixie(pixie: maze.player));

    sprites.add(getAnimatedSpriteIconThisPixie(pixie: maze.minotaur));

    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    defineTopRow(),
                    defineScoreRow(),
                  ],
                ),
              ),
              buildCenter(trs, maxWidth),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: Container(
          color: Colors.black,
          // margin: EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      defineTopRow(),
                      defineScoreRow(),
                    ],
                  ),
                ],
              ),
              Center(child: buildCenter(trs, roomLength * numRows)),
            ],
          ),
        ),
      );
    }
  }

  GestureDetector buildCenter(List<Widget> trs, double stackSize) {
    return GestureDetector(
      onHorizontalDragEnd: (dragDetails) {
        if (hDelta.abs() > 25) {
          moveThePlayer(direction: dir);
        }
        hDelta = 0;
      },
      onVerticalDragEnd: (dragDetails) {
        if (vDelta.abs() > 25) {
          moveThePlayer(direction: dir);
        }
        vDelta = 0;
      },
      onVerticalDragUpdate: (dragDetails) {
        vertaicalDragUpdate(dragDetails);
      },
      onHorizontalDragUpdate: (dragDetails) {
        horizontalDragUpdate(dragDetails);
      },
      onDoubleTap: () {
        handlePlayerHitAWall();
        maze.setWhosTurnItIs(Ilk.minotaur);
        computerMove(delayMove: maze.player.delayComputerMove);
      },
      child: SizedBox(
        width: stackSize,
        height: stackSize,
        child:
            Stack(overflow: Overflow.visible, children: [...trs, ...sprites]),
      ),
    );
  }

  void moveThePlayer({Directions direction}) {
    if (movePlayer(direction: direction)) {
      if (maze.getWhosTurnIsIt() == Ilk.minotaur) {
        computerMove(delayMove: maze.player.delayComputerMove);
      }
    }
  }

  void horizontalDragUpdate(DragUpdateDetails dragDetails) {
    hDelta += dragDetails.primaryDelta;
    if (dragDetails.primaryDelta > 0) {
      dir = Directions.right;
    } else {
      if (dragDetails.primaryDelta < 0) {
        dir = Directions.left;
      }
    }
  }

  void vertaicalDragUpdate(DragUpdateDetails dragDetails) {
    vDelta += dragDetails.primaryDelta;
    if (dragDetails.primaryDelta > 0) {
      dir = Directions.down;
    } else if (dragDetails.primaryDelta < 0) {
      dir = Directions.up;
    }
  }

  /*return true if the minotaur should move next, otherwise false */
  bool movePlayer({Directions direction}) {
    if (maze.gameIsOver()) return false;
    if (maze.getWhosTurnIsIt() != Ilk.player) return false;
    if (maze.player.movesLeft <= 0) return true;

    if (maze.moveThisSpriteInThisDirection(maze.player, direction)) {
      setState(() {
        //print('player moved  ' + direction.toString());
      });
    } else {
      handlePlayerHitAWall();
    }
    if (maze.player.movesLeft <= 0) {
      maze.setWhosTurnItIs(Ilk.minotaur);
    }
    if (maze.getWhosTurnIsIt() == Ilk.minotaur) {
      //maze.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
      Future.delayed(Duration(milliseconds: Utils.animDurationMilliSeconds),
          () {
        print('clear freed 1');
        maze.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
        setState(() {
          // just force redraw
        });
      });
      return true;
    }
    return false;
  }

  void handlePlayerHitAWall() {
    maze.player.movesLeft = 0;
  }

  void startNewGame() {
    sprites.clear();
    maze.maxRow = numRows;
    setSizes();
    maze.initMaze();
    maze.carveLabyrinth();
    maze.setGameIsOver(false);
    setState(() {});
  }
}
