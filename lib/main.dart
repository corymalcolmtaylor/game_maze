import 'package:flutter/material.dart';
import 'maze.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final numRows = 8;
    final title = 'Mazes and Minotaurs';
    Maze maze = Maze(numRows);
    maze.carveLabyrinth();

    return MaterialApp(
      title: title,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: MazeArea(maze),
      ),
    );
  }
}

class MazeArea extends StatefulWidget {
  final Maze maze;

  MazeArea(this.maze);

  @override
  _MazeAreaState createState() => _MazeAreaState();
}

class _MazeAreaState extends State<MazeArea> {
  var pixies = <Widget>[];
  var wallThickness = 2.0;
  var roomLength = 0.0;
  var maxWidth = 0.0;

  Widget getRoomPixieIcon(Room room) {
    if (widget.maze.minotaur.location == 'b_${room.x}_${room.y}') {
      return Center(
        child: Icon(Icons.android),
      );
    }
    if (widget.maze.player.location == 'b_${room.x}_${room.y}') {
      return Center(
        child: Icon(Icons.directions_run),
      );
    }
    final lamb = widget.maze.lambs.firstWhere(
        (el) => el.location == 'b_${room.x}_${room.y}',
        orElse: () => null);

    if (lamb != null) {
      return Center(
        child: Icon(Icons.mood_bad),
      );
    }
    return null;
  }

  Widget makeRoom(Room room) {
    var floorColor = Colors.blueGrey;
    var northColor = (room.up == true) ? Colors.black : floorColor;
    var southColor = (room.down == true) ? Colors.black : floorColor;
    var westColor = (room.left == true) ? Colors.black : floorColor;
    var eastColor = (room.right == true) ? Colors.black : floorColor;

    TableCellVerticalAlignment val = TableCellVerticalAlignment.middle;

    return Table(
      border: TableBorder(
        top: BorderSide(width: 1.0, color: northColor),
        right: BorderSide(width: 1.0, color: eastColor),
        left: BorderSide(width: 1.0, color: westColor),
        bottom: BorderSide(width: 1.0, color: southColor),
      ),
      children: [
        TableRow(
          children: [
            TableCell(
              verticalAlignment: val,
              child: GestureDetector(
                onTap: () {
                  print('_MazeRoomState   b_${room.x}_${room.y} tapped');
                  widget.maze.player.x = widget.maze.player.x + 1;

                  widget.maze.player.location =
                      'b_${widget.maze.player.x}_${widget.maze.player.y}';
                },
                child: Container(
                  color: floorColor,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: roomLength,
                    height: roomLength,
                    child: getRoomPixieIcon(room),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    maxWidth = MediaQuery.of(context).size.width;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      maxWidth = MediaQuery.of(context).size.height * 0.75;
    }

    var trs = <TableRow>[];
    roomLength =
        ((maxWidth.floor() - (wallThickness * (widget.maze.maxRow + 1))) /
                widget.maze.maxRow)
            .floor()
            .toDouble();
    for (int i = 1; i <= widget.maze.maxRow; i++) {
      trs.add(
        TableRow(
          children: List.from(
            widget.maze.myLabyrinth.entries
                .where((elroom) => elroom.value.y == i)
                .map(
                  (el) => makeRoom(el.value),
                )
                .toList(),
          ),
        ),
      );
    }

    //print('pixies == ${pixies.length}');
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: FlatButton(
                    color: Colors.amber,
                    onPressed: () {
                      setState(() {
                        print('re carve pressed');
                        pixies.clear();
                        widget.maze.initMaze();
                        widget.maze.carveLabyrinth();
                      });
                    },
                    child: Text('Re-Carve'),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: maxWidth,
              height: maxWidth,
              child: Stack(overflow: Overflow.visible, children: [
                Table(children: trs),
                // ...pixies,
              ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Ink(
                          decoration: ShapeDecoration(
                            color: Colors.green,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            onPressed: () {
                              print('move north  pressed');
                              setState(() {
                                widget.maze.movePixie(
                                    widget.maze.player, Directions.up);

                                print(
                                    'newlocation ${widget.maze.player.x} ${widget.maze.player.y}');
                              });
                            },
                            icon: Icon(Icons.arrow_upward),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Ink(
                          decoration: ShapeDecoration(
                            color: Colors.green,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            onPressed: () {
                              print('move west pressed');
                              setState(() {
                                widget.maze.movePixie(
                                    widget.maze.player, Directions.left);

                                print(
                                    'newlocation ${widget.maze.player.x} ${widget.maze.player.y}');
                              });
                            },
                            icon: Icon(Icons.arrow_back),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Ink(
                            decoration: ShapeDecoration(
                              color: Colors.orange,
                              shape: CircleBorder(),
                            ),
                            child: IconButton(
                              onPressed: () {
                                print('stay  pressed');
                                setState(() {
                                  print('end turn ');
                                });
                              },
                              icon: Icon(Icons.pause),
                            ),
                          ),
                        ),
                        Ink(
                          decoration: ShapeDecoration(
                            color: Colors.green,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            onPressed: () {
                              print(' move east pressed');
                              setState(() {
                                widget.maze.movePixie(
                                    widget.maze.player, Directions.right);

                                print(
                                    'newlocation ${widget.maze.player.x} ${widget.maze.player.y}');
                              });
                            },
                            icon: Icon(Icons.arrow_forward),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Ink(
                          decoration: ShapeDecoration(
                            color: Colors.green,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            onPressed: () {
                              print('move south  pressed');
                              setState(() {
                                widget.maze.movePixie(
                                    widget.maze.player, Directions.down);

                                print(
                                    'newlocation ${widget.maze.player.x} ${widget.maze.player.y}');
                              });
                            },
                            icon: Icon(Icons.arrow_downward),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
