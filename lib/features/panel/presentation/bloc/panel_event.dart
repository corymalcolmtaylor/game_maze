part of 'panel_bloc.dart';

abstract class PanelEvent extends Equatable {
  const PanelEvent();
}

class ShowRulesPanel extends PanelEvent {
  const ShowRulesPanel();

  @override
  List<Object> get props => [Utils.rules];
}

class ShowAboutPanel extends PanelEvent {
  const ShowAboutPanel();

  @override
  List<Object> get props => [Utils.info];
}

class ShowSettingsPanel extends PanelEvent {
  const ShowSettingsPanel();

  @override
  List<Object> get props => [Utils.settings];
}

class ShowDishPanel extends PanelEvent {
  const ShowDishPanel();

  @override
  List<Object> get props => [Utils.dish];
}
