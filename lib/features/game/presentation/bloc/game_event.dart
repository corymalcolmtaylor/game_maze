part of 'game_bloc.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();
}

class BackupEvent extends GameEvent {
  const BackupEvent();
  // final String v;
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class MoveEvent extends GameEvent {
  const MoveEvent(this.v, this.direction);
  final String v;
  final Directions direction;
  @override
  List<Object> get props => [v, direction];

  @override
  bool get stringify => true;
}

class EndTurnEvent extends GameEvent {
  const EndTurnEvent(this.v);
  final String v;
  @override
  List<Object> get props => [v];

  @override
  bool get stringify => true;
}

class StepForwardEvent extends GameEvent {
  const StepForwardEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class StepBackwardEvent extends GameEvent {
  const StepBackwardEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class InitializeNewGameEvent extends GameEvent {
  const InitializeNewGameEvent(this.numberOfRows, this.difficulty);
  final int numberOfRows;
  final GameDifficulty difficulty;

  @override
  List<Object> get props => [numberOfRows, difficulty];

  @override
  bool get stringify => true;
}

class UpdateGameOverMessageEvent extends GameEvent {
  const UpdateGameOverMessageEvent(this.v);
  final String v;
  @override
  List<Object> get props => [v];

  @override
  bool get stringify => true;
}
