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
    return GestureDetector(
      onTap: () => print('$name was tappped'),
      child: Table(
          /* columnWidths: {
        0: FixedColumnWidth(10.0),
        1: FixedColumnWidth(40.0),
        2: FixedColumnWidth(10.0)
      }, */
          children: [
            TableRow(children: [
              TableCell(
                child: Container(
                  color: Colors.black,
                  child: SizedBox.expand(),
                ),
              ),
              TableCell(
                child: Container(
                  color: Colors.blueGrey,
                  child: SizedBox.expand(),
                ),
              ),
              TableCell(
                child: Container(
                  color: Colors.brown,
                  child: SizedBox.expand(),
                ),
              ),
            ]),
            TableRow(
              children: [
                TableCell(
                  child: Container(
                    color: Colors.blueGrey,
                    child: SizedBox.expand(),
                  ),
                ),
                TableCell(
                  child: Container(
                    color: Colors.red,
                    alignment: Alignment.center,
                    child: Center(
                      child: Icon(
                        icon,
                      ),
                    ),
                  ),
                ),
                TableCell(
                  child: Container(
                    color: Colors.lightBlue,
                    child: SizedBox.expand(),
                  ),
                ),
              ],
            ),
            TableRow(children: [
              TableCell(
                child: Container(
                  color: Colors.greenAccent,
                  child: SizedBox.expand(),
                ),
              ),
              TableCell(
                child: Container(
                  color: Colors.green,
                  child: SizedBox.expand(),
                ),
              ),
              TableCell(
                child: Container(
                  color: Colors.lightGreen,
                  child: SizedBox.expand(),
                ),
              ),
            ]),
          ]),
    );
  }

  Widget build() {
    return makeRoom('_cccc', Icons.adb);

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
