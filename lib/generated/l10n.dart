// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Start Game`
  String get startGame {
    return Intl.message(
      'Start Game',
      name: 'startGame',
      desc: '',
      args: [],
    );
  }

  /// `Alice and the Hedge Maze`
  String get aliceAndTheHedgeMaze {
    return Intl.message(
      'Alice and the Hedge Maze',
      name: 'aliceAndTheHedgeMaze',
      desc: '',
      args: [],
    );
  }

  /// `Tough`
  String get tough {
    return Intl.message(
      'Tough',
      name: 'tough',
      desc: '',
      args: [],
    );
  }

  /// `Hard`
  String get hard {
    return Intl.message(
      'Hard',
      name: 'hard',
      desc: '',
      args: [],
    );
  }

  /// `Easy`
  String get easy {
    return Intl.message(
      'Easy',
      name: 'easy',
      desc: '',
      args: [],
    );
  }

  /// `Rules`
  String get rules {
    return Intl.message(
      'Rules',
      name: 'rules',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Rescue the animals by getting `
  String get rescueThem {
    return Intl.message(
      'Rescue the animals by getting ',
      name: 'rescueThem',
      desc: '',
      args: [],
    );
  }

  /// ` captures them.\n\nSwipe vertically or horizontally on the maze to move Alice`
  String get swipeVerticallyOrH {
    return Intl.message(
      ' captures them.\n\nSwipe vertically or horizontally on the maze to move Alice',
      name: 'swipeVerticallyOrH',
      desc: '',
      args: [],
    );
  }

  /// `to touch them before the `
  String get toTouchThem {
    return Intl.message(
      'to touch them before the ',
      name: 'toTouchThem',
      desc: '',
      args: [],
    );
  }

  /// `Alice `
  String get alice {
    return Intl.message(
      'Alice ',
      name: 'alice',
      desc: '',
      args: [],
    );
  }

  /// `.  She moves one step at a time and gets three steps per turn.\n\nEnd her turn early by touching an animal or moving into a wall or double tapping on the Hedge Maze.`
  String get sheMovesOneStep {
    return Intl.message(
      '.  She moves one step at a time and gets three steps per turn.\n\nEnd her turn early by touching an animal or moving into a wall or double tapping on the Hedge Maze.',
      name: 'sheMovesOneStep',
      desc: '',
      args: [],
    );
  }

  /// `Goblin `
  String get goblin {
    return Intl.message(
      'Goblin ',
      name: 'goblin',
      desc: '',
      args: [],
    );
  }

  /// `\n\nIf the Goblin captures Alice the game ends in defeat but otherwise once all the animals are out of the maze you win if more animals have been freed than captured.`
  String get ifTheGoblinCap {
    return Intl.message(
      '\n\nIf the Goblin captures Alice the game ends in defeat but otherwise once all the animals are out of the maze you win if more animals have been freed than captured.',
      name: 'ifTheGoblinCap',
      desc: '',
      args: [],
    );
  }

  /// `\n\nDifficulty modes:`
  String get difficultyModes {
    return Intl.message(
      '\n\nDifficulty modes:',
      name: 'difficultyModes',
      desc: '',
      args: [],
    );
  }

  /// ` mode is the default mode, in Easy mode you can see everything.`
  String get modeIsTheDefault {
    return Intl.message(
      ' mode is the default mode, in Easy mode you can see everything.',
      name: 'modeIsTheDefault',
      desc: '',
      args: [],
    );
  }

  /// ` mode means that you cannot see the other characters until Alice can.`
  String get modeMeansThat {
    return Intl.message(
      ' mode means that you cannot see the other characters until Alice can.',
      name: 'modeMeansThat',
      desc: '',
      args: [],
    );
  }

  /// ` mode is like Hard mode but now the Goblin will not capture any animals if the Alice has already freed more than half of them so as to not hasten its own defeat and to have more time to catch Alice.`
  String get modeIsLikeHard {
    return Intl.message(
      ' mode is like Hard mode but now the Goblin will not capture any animals if the Alice has already freed more than half of them so as to not hasten its own defeat and to have more time to catch Alice.',
      name: 'modeIsLikeHard',
      desc: '',
      args: [],
    );
  }

  /// `is a simple maze game inspired by the works of Lewis Carroll.\nIf you have any suggestions or find a bug please send an email about it to...\nDeveloper email:`
  String get isASimpleMazeG {
    return Intl.message(
      'is a simple maze game inspired by the works of Lewis Carroll.\nIf you have any suggestions or find a bug please send an email about it to...\nDeveloper email:',
      name: 'isASimpleMazeG',
      desc: '',
      args: [],
    );
  }

  /// `thesoftwaretaylor@gmail.com`
  String get thesoftwaretaylorgmailcom {
    return Intl.message(
      'thesoftwaretaylor@gmail.com',
      name: 'thesoftwaretaylorgmailcom',
      desc: '',
      args: [],
    );
  }

  /// `Options`
  String get options {
    return Intl.message(
      'Options',
      name: 'options',
      desc: '',
      args: [],
    );
  }

  /// `Game Over!`
  String get gameOver {
    return Intl.message(
      'Game Over!',
      name: 'gameOver',
      desc: '',
      args: [],
    );
  }

  /// `Maze Size`
  String get mazeSize {
    return Intl.message(
      'Maze Size',
      name: 'mazeSize',
      desc: '',
      args: [],
    );
  }

  /// `Difficulty`
  String get difficulty {
    return Intl.message(
      'Difficulty',
      name: 'difficulty',
      desc: '',
      args: [],
    );
  }

  /// `New Game`
  String get newGame {
    return Intl.message(
      'New Game',
      name: 'newGame',
      desc: '',
      args: [],
    );
  }

  /// `Alice Saved:`
  String get aliceSaved {
    return Intl.message(
      'Alice Saved:',
      name: 'aliceSaved',
      desc: '',
      args: [],
    );
  }

  /// `Goblin Captured:`
  String get goblinCaptured {
    return Intl.message(
      'Goblin Captured:',
      name: 'goblinCaptured',
      desc: '',
      args: [],
    );
  }

  /// `Moves left:`
  String get movesLeft {
    return Intl.message(
      'Moves left:',
      name: 'movesLeft',
      desc: '',
      args: [],
    );
  }

  /// `of`
  String get xf {
    return Intl.message(
      'of',
      name: 'xf',
      desc: '',
      args: [],
    );
  }

  /// `mailto:thesoftwaretaylor@gmail.com?subject=`
  String get mailtothesoft {
    return Intl.message(
      'mailto:thesoftwaretaylor@gmail.com?subject=',
      name: 'mailtothesoft',
      desc: '',
      args: [],
    );
  }

  /// `Could not launch `
  String get couldNotLaunch {
    return Intl.message(
      'Could not launch ',
      name: 'couldNotLaunch',
      desc: '',
      args: [],
    );
  }

  /// `The Goblin got Alice`
  String get theGoblinGotAlice {
    return Intl.message(
      'The Goblin got Alice',
      name: 'theGoblinGotAlice',
      desc: '',
      args: [],
    );
  }

  /// `You rescued`
  String get youRescued {
    return Intl.message(
      'You rescued',
      name: 'youRescued',
      desc: '',
      args: [],
    );
  }

  /// `, so you WIN! `
  String get nyouWin {
    return Intl.message(
      ', so you WIN! ',
      name: 'nyouWin',
      desc: '',
      args: [],
    );
  }

  /// `rescued and captured`
  String get rescuedAndCaptured {
    return Intl.message(
      'rescued and captured',
      name: 'rescuedAndCaptured',
      desc: '',
      args: [],
    );
  }

  /// `, so game drawn.`
  String get draw {
    return Intl.message(
      ', so game drawn.',
      name: 'draw',
      desc: '',
      args: [],
    );
  }

  /// `Normal`
  String get normal {
    return Intl.message(
      'Normal',
      name: 'normal',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Maze`
  String get maze {
    return Intl.message(
      'Maze',
      name: 'maze',
      desc: '',
      args: [],
    );
  }

  /// `The Goblin captured `
  String get thegoblincaptured {
    return Intl.message(
      'The Goblin captured ',
      name: 'thegoblincaptured',
      desc: '',
      args: [],
    );
  }

  /// `, so it wins.`
  String get itWins {
    return Intl.message(
      ', so it wins.',
      name: 'itWins',
      desc: '',
      args: [],
    );
  }

  /// `The Game has hit a bug, please try to start a new game and sned us an email at `
  String get theGameHasHitABug {
    return Intl.message(
      'The Game has hit a bug, please try to start a new game and sned us an email at ',
      name: 'theGameHasHitABug',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}