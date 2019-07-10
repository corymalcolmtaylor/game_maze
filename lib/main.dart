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
      title: 'Mazes and Minotaurs',
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
          title: Text('Mazes and Minotaurs'),
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
    return Table(columnWidths: {
      1: FixedColumnWidth(10.0),
      2: FixedColumnWidth(50.0),
      3: FixedColumnWidth(10.0)
    }, children: [
      TableRow(children: [
        TableCell(
          child: SizedBox(
            width: 10.0,
            height: 10.0,
          ),
        ),
        TableCell(
          child: SizedBox(
            height: 10.0,
          ),
        ),
        TableCell(
          child: SizedBox(
            width: 10.0,
            height: 10.0,
          ),
        ),
      ]),
      TableRow(
        children: [
          TableCell(
            child: SizedBox(
              width: 10.0,
            ),
          ),
          TableCell(
            child: GestureDetector(
              onTap: () => print('pressed'),
              child: Container(
                color: Colors.amber,
                margin: EdgeInsets.all(0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  verticalDirection: VerticalDirection.down,
                  children: <Widget>[
                    Center(
                      child: Icon(icon),
                    ),
                    Center(child: Text(name)),
                  ],
                ),
              ),
            ),
          ),
          TableCell(
            child: SizedBox(
              width: 10.0,
            ),
          ),
        ],
      ),
      TableRow(children: [
        TableCell(
          child: SizedBox(
            width: 10.0,
            height: 10.0,
          ),
        ),
        TableCell(
          child: SizedBox(
            height: 10.0,
          ),
        ),
        TableCell(
          child: SizedBox(
            width: 10.0,
            height: 10.0,
          ),
        ),
      ]),
    ]);
  }

  GridView build() {
    return GridView.count(
      primary: true,
      padding: EdgeInsets.all(0.0),
      crossAxisCount: maze.maxCol,
      childAspectRatio: 1.0,
      mainAxisSpacing: 0.0,
      crossAxisSpacing: 0.0,
      children: List.from(maze.myLabyrinth.entries
          .map((el) => makeRoom(
              el.value.x.toString() + '_' + el.value.y.toString(), Icons.adb))
          .toList()),
    );
  }
}
