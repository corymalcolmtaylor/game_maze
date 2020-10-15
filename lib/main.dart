import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:universal_io/io.dart';

import 'generated/l10n.dart';
import 'maze.dart';
import 'w_StartNewGame.dart';
import 'w_MazeBackButton.dart';
import './utils.dart';
import 'theme.dart';

void main() => runApp(
      MyApp(),
    );
enum GameActions { options, rules, about, maze }

class MazeScaffold extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var strtitle = S.of(context).aliceAndTheHedgeMaze;
    print('****** MazeScaffold build OS: ${Platform.operatingSystem}');

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.black,
        centerTitle: false,
        title: Text(strtitle, style: theme.textTheme.headline6),
        actions: <Widget>[
          PopupMenuButton<GameActions>(
            onSelected: (GameActions result) {
              if (result == GameActions.rules) {
                showRules(context);

                print('icon button, Show Rules');
              } else if (result == GameActions.about) {
                showInformation(context);
                print('icon button, Show about');
              }
            },
            color: Colors.black,
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<GameActions>>[
              PopupMenuItem<GameActions>(
                value: GameActions.rules,
                child: Text(
                  S.of(context).rules,
                  style: theme.textTheme.headline6,
                ),
              ),
              PopupMenuItem<GameActions>(
                value: GameActions.about,
                child: Text(
                  S.of(context).about,
                  style: theme.textTheme.headline6,
                ),
              ),
            ],
          ),
        ],
      ),
      body: MazeArea(),
    );
  }

  Future<void> showRules(BuildContext context) async {
    var notoalice = TextStyle(
      fontSize: 22,
      color: Colors.orange[800],
      fontFamily: 'NotoEmoji',
      backgroundColor: Colors.green[200],
    );
    var notogoblin = TextStyle(
        fontSize: 22,
        color: Colors.red[800],
        fontFamily: 'NotoEmoji',
        backgroundColor: Colors.green[200]);
    RichText message = RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: S.of(context).rescueThem, //   swipeVerticallyOrH,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).alice,
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
            text: '👧',
            style: !Platform.isAndroid ? notoalice : theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).toTouchThem,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).goblin,
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
            text: '👺',
            style: !Platform.isAndroid ? notogoblin : theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).swipeVerticallyOrH,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).sheMovesOneStep,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).ifTheGoblinCap,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).difficultyModes,
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
            text: S.of(context).easy,
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
            text: S.of(context).modeIsTheDefault,
            style: theme.textTheme.bodyText2,
          ),
          TextSpan(
            text: S.of(context).hard,
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
              text: S.of(context).modeMeansThat,
              style: theme.textTheme.bodyText2),
          TextSpan(
            text: S.of(context).tough,
            style: theme.textTheme.bodyText1,
          ),
          TextSpan(
            text: S.of(context).modeIsLikeHard,
            style: theme.textTheme.bodyText2,
          ),
        ],
      ),
    );

    return showDialog<void>(
      context: context,

      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.black54,
            title: Center(
              child: Text(
                S.of(context).rules,
                style: theme.textTheme.headline2,
              ),
            ),
            content: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    message,
                    MazeBackButton(),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> showInformation(BuildContext context) {
    Text title = Text(
      S.of(context).aliceAndTheHedgeMaze,
      style: theme.textTheme.headline4,
    );
    Text message = Text(
      S.of(context).isASimpleMazeG,
      style: theme.textTheme.bodyText2,
    );
    Text emailText = Text(S.of(context).thesoftwaretaylorgmailcom,
        style: theme.textTheme.headline6.copyWith(color: Colors.cyanAccent));
    GestureDetector emaillink = GestureDetector(
      child: emailText,
      onTap: () {
        print('email tapped');
        _launchURL(context);
      },
    );
    var alert = AlertDialog(
      backgroundColor: Colors.black87,
      title: Center(
        child: Text(
          S.of(context).about,
          style: theme.textTheme.headline2,
        ),
      ),
      content: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              title,
              message,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: emaillink,
              ),
              MazeBackButton(),
            ],
          ),
        ),
      ),
    );
    return showDialog<void>(
      context: context,

      barrierDismissible: false, // user must tap button!
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return alert;
          },
        );
      },
    );
  }

  Future<void> _launchURL(BuildContext context) async {
    var url =
        'mailto:thesoftwaretaylor@gmail.com?subject=${S.of(context).aliceAndTheHedgeMaze}';
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
    if (!Platform.isAndroid) {
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
    return roomLength - (Utils.wallThickness * 3);
  }

  double whatIsTheTopOffsetOfThisPixie({Pixie pixie}) {
    var retval = ((pixie.y - 1) * roomLength);
    //retval += roomLength * 0.1;
    return retval + (2 * Utils.wallThickness);
  }

  double whatIsTheLeftOffsetOfThisPixie({Pixie pixie}) {
    var retval = ((pixie.x - 1) * roomLength);
    return retval + Utils.wallThickness;
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
            bottom: BorderSide(color: southColor, width: Utils.wallThickness),
            top: BorderSide(color: northColor, width: Utils.wallThickness),
            right: BorderSide(color: eastColor, width: Utils.wallThickness),
            left: BorderSide(color: westColor, width: Utils.wallThickness),
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
    var title = S.of(context).gameOver;
    var msg = maze.getGameOverMessage();

    if (!maze.gameIsOver()) {
      title = S.current.options;
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: theme.textTheme.headline2,
                    ),
                  ),
                  if (msg != '')
                    RichText(
                      text: TextSpan(children: <TextSpan>[
                        TextSpan(
                          text: msg,
                          style: theme.textTheme.bodyText1,
                        ),
                        TextSpan(
                          text: maze.getEogEmoji(),
                          style: emojiTextStyle,
                        ),
                      ]),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            S.of(context).mazeSize,
                            style: theme.textTheme.bodyText2,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              decoration: new BoxDecoration(
                                border: new Border.all(
                                    color: Colors.cyanAccent,
                                    width: Utils.borderWallThickness,
                                    style: BorderStyle.solid),
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
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
                                            style: theme.textTheme.bodyText2,
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
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            S.of(context).difficulty,
                            style: theme.textTheme.bodyText2,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              decoration: new BoxDecoration(
                                border: new Border.all(
                                    color: Colors.cyanAccent,
                                    width: Utils.borderWallThickness,
                                    style: BorderStyle.solid),
                                borderRadius: new BorderRadius.all(
                                    new Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
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
                                            style: theme.textTheme.bodyText2,
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
                  ),
                  if (MediaQuery.of(context).orientation ==
                      Orientation.landscape)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
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
                  if (title == S.of(context).gameOver) MazeBackButton(),
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
    roomLength = (((maxWidth.floor() - (Utils.wallThickness * (maze.maxRow))) /
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
              width: Utils.borderWallThickness),
          onPressed: () {
            setState(() {
              handleEndOfGame();
            });
          },
          child: Text(
            S.of(context).newGame,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyText2,
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
                S.of(context).aliceSaved,
                style: theme.textTheme.bodyText2,
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
                  child: Text(
                    maze.player.savedLambs.toString(),
                    style: theme.textTheme.bodyText2,
                  )),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                S.of(context).goblinCaptured,
                style: theme.textTheme.bodyText2,
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
                  child: Text(
                    maze.player.lostLambs.toString(),
                    style: theme.textTheme.bodyText2,
                  )),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                S.of(context).movesLeft,
                style: theme.textTheme.bodyText2,
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 20, 0),
                  child: Text(
                    '${maze.player.movesLeft}',
                    style: theme.textTheme.bodyText2,
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
