part of 'game_bloc.dart';

@immutable
abstract class GameState extends Equatable {
  GameState();
  final Maze maze = null;
}

class InitialGame extends GameState {
  InitialGame();
  final int rid = 0;
  @override
  final Maze maze = Maze(8, GameDifficulty.normal);

  @override
  List<Object> get props => [rid];
}

class LoadedGame extends GameState {
  LoadedGame({this.maze, this.rid});
  final int rid;
  @override
  final Maze maze;

  @override
  List<Object> get props => [rid];
}

class GameError extends GameState {
  GameError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
