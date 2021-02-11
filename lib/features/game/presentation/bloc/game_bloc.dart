import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:game_maze/core/maze.dart';
import 'package:game_maze/core/utils.dart';
import 'package:game_maze/generated/l10n.dart';
import 'package:meta/meta.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc() : super(InitialGame(DateTime.now().millisecondsSinceEpoch));

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
      mz.randomid = DateTime.now().millisecondsSinceEpoch;
      yield LoadedGame(maze: mz, rid: mz.randomid);
    } catch (_) {
      yield GameError(
          '${S.current.theGameHasHitABug} ${S.current.thesoftwaretaylorgmailcom}');
    }
  }

  Stream<GameState> _mapMoveToState(MoveEvent event) async* {
    if (state is LoadedGame || state is InitialGame) {
      Maze mz = state.maze.copyThisMaze();
      try {
        print('_mapMoveToState  ');
        if (mz.getWhosTurnIsIt() == Ilk.player) {
          if (!mz.moveThisSpriteInThisDirection(mz.player, event.direction)) {
            mz.player.setMovesLeft(0);
          }
          mz.randomid++;
          print('1 player _mapMoveToState id ${mz.randomid}');
          yield LoadedGame(maze: mz, rid: mz.randomid);
          await Future.delayed(
              const Duration(milliseconds: Utils.animDurationMilliSeconds));
          mz.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
          mz.setPixiesVisibility();
          mz.randomid++;
          print('1b player _mapMoveToState id ${mz.randomid}');
          yield LoadedGame(maze: mz, rid: mz.randomid);
          if (mz.player.getMovesLeft() <= 0) {
            mz.player.setMovesLeft(mz.getMaxPlayerMoves());
            mz.setWhosTurnItIs(Ilk.minotaur);
          }
        }
        if (mz.getWhosTurnIsIt() == Ilk.minotaur) {
          minotaurMove(maze: mz);
          mz.randomid++;
          print('2 mino _mapMoveToState id ${mz.randomid}');
          yield LoadedGame(maze: mz, rid: mz.randomid);
          await Future.delayed(
              const Duration(milliseconds: Utils.animDurationMilliSeconds));
          mz.clearLocationsOfLambsInThisCondition(condition: Condition.dead);
          mz.setPixiesVisibility();
          mz.randomid++;
          print('2b mino _mapMoveToState id ${mz.randomid}');
          yield LoadedGame(maze: mz, rid: mz.randomid);
        }
        if (mz.getWhosTurnIsIt() == Ilk.lamb) {
          lambsMove(maze: mz);
          mz.randomid++;
          print('3 lambs _mapMoveToState id ${mz.randomid}');
          yield LoadedGame(maze: mz, rid: mz.randomid);
          await Future.delayed(
              const Duration(milliseconds: Utils.animDurationMilliSeconds));
          mz.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
          mz.setPixiesVisibility();
          mz.randomid++;
          print('3b lambs _mapMoveToState id ${mz.randomid}');
          yield LoadedGame(maze: mz, rid: mz.randomid);
        }
      } catch (_) {
        yield GameError(
            '${S.current.theGameHasHitABug} ${S.current.thesoftwaretaylorgmailcom}');
      }
    }
  }

  Stream<GameState> _mapEndTurnToState(EndTurnEvent event) async* {
    Maze mz = state.maze.copyThisMaze();
    try {
      mz.player.setMovesLeft(0);
      mz.setWhosTurnItIs(Ilk.minotaur);
      if (mz.getWhosTurnIsIt() == Ilk.minotaur) {
        minotaurMove(maze: mz);
        mz.randomid++;
        print('1 _mapEndTurnToState id ${mz.randomid}');
        yield LoadedGame(maze: mz, rid: mz.randomid);
        await Future.delayed(
            const Duration(milliseconds: Utils.animDurationMilliSeconds));
        mz.clearLocationsOfLambsInThisCondition(condition: Condition.freed);
        mz.setPixiesVisibility();
        mz.randomid++;
        print('1b _mapEndTurnToState id ${mz.randomid}');
        yield LoadedGame(maze: mz, rid: mz.randomid);
      }
      if (mz.getWhosTurnIsIt() == Ilk.lamb) {
        lambsMove(maze: mz);
        mz.randomid++;
        print('2 _mapEndTurnToState id ${mz.randomid}');
        yield LoadedGame(maze: mz, rid: mz.randomid);
        await Future.delayed(
            const Duration(milliseconds: Utils.animDurationMilliSeconds));
        mz.clearLocationsOfLambsInThisCondition(condition: Condition.dead);
        mz.setPixiesVisibility();
        mz.randomid++;
        print('2b _mapEndTurnToState id ${mz.randomid}');
        yield LoadedGame(maze: mz, rid: mz.randomid);
      }
    } catch (_) {
      yield GameError(
          '${S.current.theGameHasHitABug} ${S.current.thesoftwaretaylorgmailcom}');
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

  void minotaurMove({Maze maze}) async {
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
  }

  void lambsMove({Maze maze}) async {
    if (maze.gameIsOver() ||
        !maze.lambs.any((lamb) => lamb.condition == Condition.alive)) {
      maze.setGameIsOver(true);
      handleEndOfGame(maze);
      return;
    }

    maze.moveLambs();
    if (maze.gameIsOver() ||
        !maze.lambs.any((lamb) => lamb.condition == Condition.alive)) {
      maze.setGameIsOver(true);
      handleEndOfGame(maze);
      return;
    }
    maze.setWhosTurnItIs(Ilk.player);
    maze.player.setMovesLeft(maze.getMaxPlayerMoves());
    print('fin lambsMove');
  }
}
