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

  Widget getIconOfPixie(Pixie pix) {
    Icon ic;
    if (pix.ilk == Ilk.player) {
      ic = Icon(Icons.directions_run);
    } else if (pix.ilk == Ilk.minotaur) {
      ic = Icon(Icons.android);
    } else {
      ic = Icon(Icons.mood_bad);
    }

    return Positioned(
      left: 0,
      top: 0,
      child: Transform.translate(
        key: Key(pix.location),
        offset: Offset(pix.dx, pix.dy),
        child: ic,
      ),
    );
  }

  setPixieXY(Pixie pix) {
    print(
        ' 1 setpixiexy ${wallThickness} ${roomLength}  ${pix.x} ${pix.y}  ${pix.dx} ${pix.dy}  ');
    pix.dx = (pix.x - 1) +
        wallThickness +
        ((pix.x - 1) * (roomLength + (wallThickness)));
    pix.dy = (pix.y - 1) +
        wallThickness +
        ((pix.y - 1) * (roomLength + (wallThickness)));
    print(
        ' 2 setpixiexy ${wallThickness} ${roomLength}  ${pix.x} ${pix.y}  ${pix.dx} ${pix.dy}  ');
  }

  void setPixies() {
    pixies.clear();
    setPixieXY(widget.maze.player);
    setPixieXY(widget.maze.minotaur);
    pixies.add(getIconOfPixie(widget.maze.player));
    pixies.add(getIconOfPixie(widget.maze.minotaur));
    widget.maze.lambs.forEach((p) {
      setPixieXY(p);
      pixies.add(getIconOfPixie(p));
    });
  }

  Widget getRoomPixieIcon(Room room) {
    if (widget.maze.minotaur.location == 'b_${room.x}_${room.y}') {
      return Positioned(
        left: 0,
        top: 0,
        child: Transform.translate(
          offset: Offset(widget.maze.minotaur.dx, widget.maze.minotaur.dy),
          child: Icon(Icons.android),
        ),
      );
    }
    if (widget.maze.player.location == 'b_${room.x}_${room.y}') {
      return Positioned(
        left: 0,
        top: 0,
        child: Transform.translate(
          offset: Offset(widget.maze.player.dx, widget.maze.player.dy),
          child: Icon(Icons.directions_run),
        ),
      );
    }
    final lamb = widget.maze.lambs.firstWhere(
        (el) => el.location == 'b_${room.x}_${room.y}',
        orElse: () => null);

    if (lamb != null) {
      return Positioned(
        left: 0,
        top: 0,
        child: Transform.translate(
          key: Key(lamb.location),
          offset: Offset(lamb.dx, lamb.dy),
          child: Icon(Icons.mood_bad),
        ),
      );
    }
    return null;
  }

  Widget makeRoom(Room room) {
    //print('makeroom');

    var floorColor = Colors.blueGrey;
    var northColor = (room.north == true) ? Colors.black : floorColor;
    var southColor = (room.south == true) ? Colors.black : floorColor;
    var westColor = (room.west == true) ? Colors.black : floorColor;
    var eastColor = (room.east == true) ? Colors.black : floorColor;
    var cornerColor = Colors.black;
    TableCellVerticalAlignment val = TableCellVerticalAlignment.middle;

    return Table(
        border: TableBorder(
            top: BorderSide.none,
            right: BorderSide.none,
            bottom: BorderSide.none,
            left: BorderSide.none,
            horizontalInside: BorderSide.none,
            verticalInside: BorderSide.none),
        columnWidths: {
          0: FixedColumnWidth(wallThickness),
          1: FixedColumnWidth(roomLength),
          2: FixedColumnWidth(wallThickness)
        },
        children: [
          TableRow(children: [
            TableCell(
              verticalAlignment: val,
              child: Container(
                color: cornerColor,
                child: SizedBox(
                  height: wallThickness,
                  width: wallThickness,
                ),
              ),
            ),
            TableCell(
              verticalAlignment: val,
              child: Container(
                color: northColor,
                child: SizedBox(
                  height: wallThickness,
                  width: double.infinity,
                ),
              ),
            ),
            TableCell(
              verticalAlignment: val,
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
                verticalAlignment: val,
                child: Container(
                  color: westColor,
                  child: SizedBox(
                    height: roomLength,
                    width: wallThickness,
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: val,
                child: GestureDetector(
                  onTap: () => {
                    print(
                        '_MazeRoomState makeRoom b_${room.x}_${room.y} tapped')
                  },
                  child: Container(
                    color: floorColor,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: roomLength,
                      height: roomLength,
                      //child: pixieIcon,
                    ),
                  ),
                ),
              ),
              TableCell(
                verticalAlignment: val,
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
              verticalAlignment: val,
              child: Container(
                color: cornerColor,
                child: SizedBox(
                  width: wallThickness,
                  height: wallThickness,
                ),
              ),
            ),
            TableCell(
              verticalAlignment: val,
              child: Container(
                color: southColor,
                child: SizedBox(
                  width: roomLength,
                  height: wallThickness,
                ),
              ),
            ),
            TableCell(
              verticalAlignment: val,
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
    maxWidth = MediaQuery.of(context).size.width;
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      maxWidth = MediaQuery.of(context).size.height * 0.75;
    }
    wallThickness = 2.0;
    roomLength =
        ((maxWidth.floor() - (wallThickness * (widget.maze.maxRow + 1))) /
                widget.maze.maxRow)
            .floor()
            .toDouble();
    setPixies();
    var trs = <TableRow>[];
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
        FlatButton(
          color: Colors.amber,
          onPressed: () {
            setState(() {
              print('re carve pressed');
              pixies.clear();
              widget.maze.initMaze();
              widget.maze.carveLabyrinth();
              setPixies();
            });
          },
          child: Text('Re-Carve'),
        ),
        FlatButton(
          color: Colors.amber,
          onPressed: () {
            print('move pressed');
            setState(() {
              widget.maze.player.x = widget.maze.player.x + 1;
              //widget.maze.player.y = 1;
              widget.maze.player.dx =
                  widget.maze.player.dx + roomLength + (2 * wallThickness);
              //widget.maze.player.dy = widget.maze.player.dy + 0.0;
              pixies[0] = getIconOfPixie(widget.maze.player);

              print(
                  'newlocation ${widget.maze.player.dx} ${widget.maze.player.dy}');
            });
          },
          child: Text('Move'),
        ),
        SizedBox(
          width: maxWidth,
          height: maxWidth,
          child: Stack(overflow: Overflow.visible, children: [
            Table(children: trs),
            ...pixies,
          ]),
        ),
      ],
    );
  }
}
