import 'package:flutter/material.dart';
import 'maze.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Maze maze = Maze(8, 8);
    maze.carveLabyrinth();
    return MaterialApp(
      title: 'my flutter app',
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
          title: Text('my flutter app'),
        ),
        body: MazeRoom(maze).build(),
      ),
    );
  }
}

class MazeRoom {
  final Maze maze;
  MazeRoom(this.maze);
  Widget makeRoom(String name, IconData icon) {
    /*  get right sizes */
    // MediaQuery.of(context)
    var wallThickness = 4.0;
    var roomLength = 65.0;
    var wallColor = Colors.red;
    var floorColor = Colors.blueGrey;

    return Table(columnWidths: {
      0: FixedColumnWidth(wallThickness),
      1: FixedColumnWidth(roomLength),
      2: FixedColumnWidth(wallThickness)
    }, children: [
      TableRow(children: [
        TableCell(
          child: Container(
            color: wallColor,
            child: SizedBox(
              height: wallThickness,
              width: wallThickness,
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: wallColor,
            child: SizedBox(
              height: wallThickness,
              width: double.infinity,
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: wallColor,
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
              color: wallColor,
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
              color: wallColor,
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
            color: wallColor,
            child: SizedBox(
              width: wallThickness,
              height: wallThickness,
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: wallColor,
            child: SizedBox(
              width: roomLength,
              height: wallThickness,
            ),
          ),
        ),
        TableCell(
          child: Container(
            color: wallColor,
            child: SizedBox(
              width: wallThickness,
              height: wallThickness,
            ),
          ),
        ),
      ]),
    ]);
  }

  Widget build() {
    //return makeRoom('_cccc', Icons.adb);
    var trs = <TableRow>[];
    for (int i = 1; i <= maze.maxRow; i++) {
      trs.add(TableRow(
          children: List.from(maze.myLabyrinth.entries
              .where((elroom) => elroom.value.y == i)
              .map((el) => makeRoom(
                  el.value.x.toString() + '_' + el.value.y.toString(),
                  Icons.adb))
              .toList())));
    }

    return Table(children: trs

        /*
        TableRow(
            children: List.from(maze.myLabyrinth.entries
                .where((elroom) => elroom.value.y == 2)
                .map((el) => makeRoom(
                    el.value.x.toString() + '_' + el.value.y.toString(),
                    Icons.adb))
                .toList())),
        TableRow(
            children: List.from(maze.myLabyrinth.entries
                .where((elroom) => elroom.value.y == 3)
                .map((el) => makeRoom(
                    el.value.x.toString() + '_' + el.value.y.toString(),
                    Icons.adb))
                .toList())),
        TableRow(
            children: List.from(maze.myLabyrinth.entries
                .where((elroom) => elroom.value.y == 4)
                .map((el) => makeRoom(
                    el.value.x.toString() + '_' + el.value.y.toString(),
                    Icons.adb))
                .toList())),
        TableRow(
            children: List.from(maze.myLabyrinth.entries
                .where((elroom) => elroom.value.y == 5)
                .map((el) => makeRoom(
                    el.value.x.toString() + '_' + el.value.y.toString(),
                    Icons.adb))
                .toList())),
        TableRow(
            children: List.from(maze.myLabyrinth.entries
                .where((elroom) => elroom.value.y == 6)
                .map((el) => makeRoom(
                    el.value.x.toString() + '_' + el.value.y.toString(),
                    Icons.adb))
                .toList())),
        TableRow(
            children: List.from(maze.myLabyrinth.entries
                .where((elroom) => elroom.value.y == 7)
                .map((el) => makeRoom(
                    el.value.x.toString() + '_' + el.value.y.toString(),
                    Icons.adb))
                .toList())),
        TableRow(
            children: List.from(maze.myLabyrinth.entries
                .where((elroom) => elroom.value.y == 8)
                .map((el) => makeRoom(
                    el.value.x.toString() + '_' + el.value.y.toString(),
                    Icons.adb))
                .toList())),
                */

        );

    return GridView.count(
      primary: true,
      padding: EdgeInsets.all(0.0),
      crossAxisCount: maze.maxCol,
      //childAspectRatio: 1.0,
      mainAxisSpacing: 0.0,
      crossAxisSpacing: 0.0,

      children: List.from(maze.myLabyrinth.entries
          .map((el) => makeRoom(
              el.value.x.toString() + '_' + el.value.y.toString(), Icons.adb))
          .toList()),
    );
  }
}
