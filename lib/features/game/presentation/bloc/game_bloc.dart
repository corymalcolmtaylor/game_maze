import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:game_maze/core/maze.dart';
import 'package:game_maze/core/utils.dart';
import 'package:game_maze/features/panel/presentation/bloc/panel_bloc.dart';
import 'package:game_maze/generated/l10n.dart';
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
    } else if (event is EndTurnEvent) {
      print('move alice  event ');
      yield* _mapEndTurnToState(event);
    }
  }

  Stream<GameState> _mapInitializeNewMazeToState(
      InitializeNewGameEvent event) async* {
    try {
      Maze mz = Maze(event.numberOfRows, event.difficulty);
      mz.setPixiesVisibility();
      yield LoadedGame(maze: mz, rid: mz.randomid);
    } catch (_) {
      yield GameError('initialize game error');
    }
  }

  Stream<GameState> _mapMoveToState(MoveEvent event) async* {
    if (state is LoadedGame || state is InitialGame) {
      Maze mz = state.maze.copyThisMaze();
      try {
        print('1 _mapMoveToState id ${mz.randomid}');
        if (mz.getWhosTurnIsIt() == Ilk.player) {
          if (!mz.moveThisSpriteInThisDirection(mz.player, event.direction)) {
            mz.player.setMovesLeft(0);
          }
          mz.randomid++;

          yield LoadedGame(maze: mz, rid: mz.randomid); // Do something
          await Future.delayed(
              const Duration(milliseconds: Utils.animDurationMilliSeconds));
          mz.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
          mz.setPixiesVisibility();
          if (mz.player.getMovesLeft() <= 0) {
            mz.setWhosTurnItIs(Ilk.minotaur);
          }
        }
        if (mz.getWhosTurnIsIt() == Ilk.minotaur) {
          minotaurMove(delayMove: mz.player.delayComputerMove, maze: mz);
          mz.randomid++;
          print('2 _mapMoveToState id ${mz.randomid}');
          yield LoadedGame(maze: mz, rid: mz.randomid); // Do something
          await Future.delayed(
              const Duration(milliseconds: Utils.animDurationMilliSeconds));
          mz.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
          mz.setPixiesVisibility();
        }
        if (mz.getWhosTurnIsIt() == Ilk.lamb) {
          lambsMove(delayMove: mz.player.delayComputerMove, maze: mz);
          mz.randomid++;
          print('3 _mapMoveToState id ${mz.randomid}');
          yield LoadedGame(maze: mz, rid: mz.randomid);
          await Future.delayed(
              const Duration(milliseconds: Utils.animDurationMilliSeconds));
          mz.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
          mz.setPixiesVisibility();
        }
      } catch (_) {
        yield GameError('move player error');
      }
    }
  }

  Stream<GameState> _mapEndTurnToState(EndTurnEvent event) async* {
    Maze mz = state.maze.copyThisMaze();
    try {
      mz.player.setMovesLeft(0);
      mz.setWhosTurnItIs(Ilk.minotaur);
      if (mz.getWhosTurnIsIt() == Ilk.minotaur) {
        minotaurMove(delayMove: mz.player.delayComputerMove, maze: mz);
        mz.randomid++;
        print('2 _mapMoveToState id ${mz.randomid}');
        yield LoadedGame(maze: mz, rid: mz.randomid); // Do something
        await Future.delayed(
            const Duration(milliseconds: Utils.animDurationMilliSeconds));
        mz.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
        mz.setPixiesVisibility();
      }
      if (mz.getWhosTurnIsIt() == Ilk.lamb) {
        lambsMove(delayMove: mz.player.delayComputerMove, maze: mz);
        mz.randomid++;
        print('3 _mapMoveToState id ${mz.randomid}');
        yield LoadedGame(maze: mz, rid: mz.randomid);
        await Future.delayed(
            const Duration(milliseconds: Utils.animDurationMilliSeconds));
        mz.clearLocationsOfLambsInThisCondition(condition: Condition.dead);
        mz.setPixiesVisibility();
      }
    } catch (_) {
      yield GameError('move player error');
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    print('onError $error, $stackTrace');
    super.onError(error, stackTrace);
  }

  void handleEndOfGame(Maze maze) {
    String str = '${S.current.gameOver}';
    maze.setEogEmoji('');

    if (maze.player.condition == Condition.dead) {
      str += ' ${S.current.theGoblinGotAlice}${S.current.itWins}';
      maze.setEogEmoji('😞');
    } else {
      if (maze.player.savedLambs > maze.player.lostLambs) {
        str +=
            ' ${S.current.youRescued} ${maze.player.savedLambs}${S.current.nyouWin}';
        maze.setEogEmoji('😀');
      } else if (maze.player.savedLambs == maze.player.lostLambs) {
        str +=
            ' ${maze.player.savedLambs} ${S.current.rescuedAndCaptured}${S.current.draw}';
        maze.setEogEmoji('😐');
      } else {
        str +=
            ' ${S.current.thegoblincaptured} ${maze.player.lostLambs}${S.current.itWins}';
        maze.setEogEmoji('😞');
      }
    }
    maze.setGameOverMessage(str);
  }

  void minotaurMove({bool delayMove, Maze maze}) async {
    if (maze.gameIsOver() ||
        !maze.lambs.any((lamb) => lamb.condition == Condition.alive)) {
      maze.setGameIsOver(true);
      handleEndOfGame(maze);

      return;
    }

    if (maze.getWhosTurnIsIt() == Ilk.minotaur) {
      maze.moveMinotaur();
    }
    print(' fin minotaurMove');
    //var gameOver = maze.moveLambs();
    //maze.clearLocationsOfLambsInThisCondition(condition: Condition.dead);

    /*
    if (gameOver) {
      handleEndOfGame(maze);
    } else {
      maze.preparePlayerForATurn();
    }

    print('clear freed 2');
    maze.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
    */
  }

  void lambsMove({bool delayMove, Maze maze}) async {
    if (maze.gameIsOver() ||
        !maze.lambs.any((lamb) => lamb.condition == Condition.alive)) {
      maze.setGameIsOver(true);
      handleEndOfGame(maze);

      return;
    }
    /*
    if (maze.getWhosTurnIsIt() == Ilk.minotaur) {
      maze.moveMinotaur();
    }
    */

    var gameOver = maze.moveLambs();
    maze.setWhosTurnItIs(Ilk.player);
    maze.player.setMovesLeft(3);
    print('fin lambsMove');
    /*
    maze.clearLocationsOfLambsInThisCondition(condition: Condition.dead);

    if (gameOver) {
      handleEndOfGame(maze);
    } else {
      maze.preparePlayerForATurn();
    }

    print('clear freed 2');
    maze.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
    */
  }
}
