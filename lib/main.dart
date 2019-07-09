import 'package:flutter/material.dart';
import 'maze.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
        body: MazeRoom().build(),
      ),
    );
  }
}

class MazeRoom {
  Card makeRoom(String name, IconData icon) {
    return Card(
      elevation: 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Center(
            child: Icon(icon),
          ),
          Center(child: Text(name)),
        ],
      ),
    );
  }

  GridView build() {
    Maze maze = Maze(8, 8);
    maze.carveLabyrinth();

    return GridView.count(
      primary: true,
      padding: EdgeInsets.all(1.0),
      crossAxisCount: maze.maxCol,
      childAspectRatio: 1.0,
      mainAxisSpacing: 1.0,
      crossAxisSpacing: 1.0,
      children: List.from(maze.myLabyrinth.entries
          .map((el) => makeRoom(
              el.value.x.toString() + '_' + el.value.y.toString(), Icons.adb))
          .toList()),
    );
  }
}
