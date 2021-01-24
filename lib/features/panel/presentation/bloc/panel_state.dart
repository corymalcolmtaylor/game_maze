part of 'panel_bloc.dart';

abstract class PanelState extends Equatable {
  const PanelState();
}

class DishPanel extends PanelState {
  const DishPanel();

  @override
  List<Object> get props => [Utils.dish];
}

class SettingsPanel extends PanelState {
  const SettingsPanel();

  @override
  List<Object> get props => [Utils.settings];
}

class RulesPanel extends PanelState {
  const RulesPanel();

  @override
  List<Object> get props => [Utils.rules];
}

class AboutPanel extends PanelState {
  const AboutPanel({this.version});
  final String version;
  @override
  List<Object> get props => [version];
}

class ErrorPanel extends PanelState {
  const ErrorPanel(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
