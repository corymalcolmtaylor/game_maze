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
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: MazeRoom(maze),
      ),
    );
  }
}

class MazeRoom extends StatefulWidget {
  final Maze maze;

  MazeRoom(this.maze);

  @override
  _MazeRoomState createState() => _MazeRoomState();
}

class _MazeRoomState extends State<MazeRoom> {
  Widget makeRoom(Room room, String name, IconData icon, double maxWidth) {
    /*  get right sizes */
    // MediaQuery.of(context)

    var wallThickness = 4.0;
    var roomLength =
        ((maxWidth.floor() - (wallThickness * (widget.maze.maxRow + 1))) /
                widget.maze.maxRow)
            .floor()
            .toDouble();
    var floorColor = Colors.blueGrey;
    var northColor = (room.north == true) ? Colors.black : floorColor;
    var eastColor = (room.east == true) ? Colors.black : floorColor;
    var southColor = (room.south == true) ? Colors.black : floorColor;
    var westColor = (room.west == true) ? Colors.black : floorColor;

    var cornerColor = Colors.black;

    return Table(columnWidths: {
      0: FixedColumnWidth(wallThickness),
      1: FixedColumnWidth(roomLength),
      2: FixedColumnWidth(wallThickness)
    }, children: [
      TableRow(children: [
        TableCell(
          child: Container(
            color: cornerColor,
            child: SizedBox(
              height: wallThickness,
              width: wallThickness,
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: northColor,
            child: SizedBox(
              height: wallThickness,
              width: double.infinity,
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: cornerColor,
            child: SizedBox(
              height: wallThickness,
              width: wallThickness,
            ),
          ),
        ),
      ]),
      TableRow(
        children: [
          TableCell(
            child: Container(
              color: westColor,
              child: SizedBox(
                height: roomLength,
                width: wallThickness,
              ),
            ),
          ),
          TableCell(
            child: GestureDetector(
              onTap: () => print('$name was tappped'),
              child: Container(
                color: floorColor,
                alignment: Alignment.center,
                child: SizedBox(
                  width: roomLength,
                  height: roomLength,
                  /*
                  child: Center(
                    child: Icon(
                      icon,
                    ),
                  ),
                  */
                ),
              ),
            ),
          ),
          TableCell(
            child: Container(
              color: eastColor,
              child: SizedBox(
                width: wallThickness,
                height: roomLength,
              ),
            ),
          ),
        ],
      ),
      TableRow(children: [
        TableCell(
          child: Container(
            color: cornerColor,
            child: SizedBox(
              width: wallThickness,
              height: wallThickness,
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: southColor,
            child: SizedBox(
              width: roomLength,
              height: wallThickness,
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: cornerColor,
            child: SizedBox(
              width: wallThickness,
              height: wallThickness,
            ),
          ),
        ),
      ]),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var maxWidth = MediaQuery.of(context).size.width;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      maxWidth = MediaQuery.of(context).size.height * 0.75;
    }

    var trs = <TableRow>[];
    for (int i = 1; i <= widget.maze.maxRow; i++) {
      trs.add(
        TableRow(
          children: List.from(
            widget.maze.myLabyrinth.entries
                .where((elroom) => elroom.value.y == i)
                .map(
                  (el) => makeRoom(
                      el.value,
                      el.value.x.toString() + '_' + el.value.y.toString(),
                      Icons.adb,
                      maxWidth),
                )
                .toList(),
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        Center(
          child: SizedBox(
              width: maxWidth, height: maxWidth, child: Table(children: trs)),
        ),
        SizedBox(
          height: 10,
        ),
        Center(
          child: FlatButton(
            color: Colors.amber,
            onPressed: () {
              setState(() {
                print('reinit maze');
                widget.maze.initMaze();
                widget.maze.carveLabyrinth();
              });
            },
            child: Text('Re-Carve'),
          ),
        )
      ],
    );
  }
}
