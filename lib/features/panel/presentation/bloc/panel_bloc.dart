import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:game_maze/core/utils.dart';
import 'package:game_maze/generated/l10n.dart';
import 'package:package_info/package_info.dart';

part 'panel_event.dart';
part 'panel_state.dart';

class PanelBloc extends Bloc<PanelEvent, PanelState> {
  PanelBloc() : super(const SettingsPanel());

  @override
  Stream<PanelState> mapEventToState(PanelEvent event) async* {
    if (event is ShowDishPanel) {
      yield const DishPanel();
    } else if (event is ShowAboutPanel) {
      print('ShowAboutPanel 1');
      var version = '';
      if (!kIsWeb) {
        var packageInfo = await PackageInfo.fromPlatform();
        print('ShowAboutPanel 2');
        version =
            '\n\n${S.current.version}: ${packageInfo.version.toLowerCase()}';

        print('ShowAboutPanel version  $version');
      }

      yield AboutPanel(version: version);
    } else if (event is ShowRulesPanel) {
      yield const RulesPanel();
    } else {
      print('show settings panel state');
      yield const SettingsPanel();
    }
  }
}
