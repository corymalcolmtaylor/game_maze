import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:game_maze/core/maze.dart';
import 'package:game_maze/core/utils.dart';
import 'package:meta/meta.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(InitialGame());

  Maze oldMaze;

  @override
  Stream<GameState> mapEventToState(
    GameEvent event,
  ) async* {
    if (event is InitializeNewGameEvent) {
      print('initial by prefs event ');
      yield* _mapInitializeNewMazeToState(event);
    } else if (event is MoveEvent) {
      print('move alice  event ');
      yield* _mapMoveToState(event);
    }
  }

  Stream<GameState> _mapInitializeNewMazeToState(
      InitializeNewGameEvent event) async* {
    try {
      Maze mz = Maze(event.numberOfRows, event.difficulty);
      //  ..randomid = DateTime.now().millisecondsSinceEpoch;
      //mz.carveLabyrinth();
      yield LoadedGame(maze: mz, rid: mz.randomid);
    } catch (_) {
      yield GameError('initialize game error');
    }
  }

  Stream<GameState> _mapMoveToState(MoveEvent event) async* {
    if (state is LoadedGame || state is InitialGame) {
      Maze mz = state.maze.copyThisMaze();
      try {
        if (!mz.moveThisSpriteInThisDirection(mz.player, event.direction)) {
          mz.player.setMovesLeft(0);
        }
        if (mz.player.getMovesLeft() <= 0) {
          mz.setWhosTurnItIs(Ilk.minotaur);
        }
        if (mz.getWhosTurnIsIt() == Ilk.minotaur) {
          mz.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
          computerMove(delayMove: mz.player.delayComputerMove, maze: mz);
        }
        mz.setPixiesVisibility();
        print('_mapMoveToState id ${mz.randomid}');
        yield LoadedGame(maze: mz, rid: mz.randomid);
      } catch (_) {
        yield GameError('move player error');
      }
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('onError $error, $stackTrace');
    super.onError(error, stackTrace);
  }

  void computerMove({bool delayMove, Maze maze}) async {
    if (maze.gameIsOver() ||
        !maze.lambs.any((lamb) => lamb.condition == Condition.alive)) {
      maze.setGameIsOver(true);
      //handleEndOfGame();
      maze.setGameOverMessage('gameisover');
      return;
    }

    //int minoDelay = 0;
    //if (delayMove) {
    //  minoDelay = Utils.animDurationMilliSeconds;
    //}
    //var lambDelay = 0;
    if (maze.getWhosTurnIsIt() == Ilk.minotaur) {
      //lambDelay = Utils.animDurationMilliSeconds;
      //Future.delayed(Duration(milliseconds: minoDelay), () {
      maze.moveMinotaur();
      //});
    }

    //Future.delayed(Duration(milliseconds: minoDelay + lambDelay), () {
    var gameOver = maze.moveLambs();
    maze.clearLocationsOfLambsInThisCondition(condition: Condition.dead);

    if (gameOver) {
      //Future.delayed(
      //    Duration(milliseconds: 1 * Utils.animDurationMilliSeconds), () {
      //handleEndOfGame();
      maze.setGameOverMessage('gameisover');
      //});
    } else {
      maze.preparePlayerForATurn();
    }
    // }).then((_) {
    //Future.delayed(Duration(milliseconds: Utils.animDurationMilliSeconds),
    //  () {
    print('clear freed 2');
    maze.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
    //});
    //});
  }
}
