import 'dart:async';

import 'package:get/get.dart';
import 'package:steam_family_simulator/data.dart';

import 'main_controller.dart';
import 'steam_profile.dart';

enum DisplayMode {
  all,
  notOwn,
  following,
}

mixin GameFilterController on GetxController {
  final selected = <SteamProfile>[];
  DisplayMode _mode = DisplayMode.all;

  DisplayMode get mode => _mode;

  set mode(DisplayMode value) {
    _mode = value;
    _allGames();
    update(['content']);
  }

  String? _search;
  Timer? _searchTimer;

  String? get search => _search;

  set search(String? value) {
    _search = value;
    _searchTimer?.cancel();
    _searchTimer = Timer(Duration(milliseconds: 200), () {
      _allGames();
      update(['content']);
    });
  }

  bool isSelected(SteamProfile v) => selected.contains(v);

  void select(SteamProfile v) {
    MainController main = (this as MainController);
    if (selected.contains(v)) {
      if (_sorted == v) _sorted = null;
      selected.remove(v);
      if (!hasMineAccount) _mode = DisplayMode.all;
      _allGames();
      Get.offAllNamed('/content', id: 1);
      update(['content']);
    } else {
      if (v.mine) {
        selected.insert(0, v);
      } else {
        selected.add(v);
      }
      update(['content']);
      v.loadGames().then((value) {
        _allGames();
        update(['content']);
      });
    }
    if (selected.isEmpty) {
      Get.offAllNamed('/home', id: 1);
    } else {
      Get.offAllNamed('/content', id: 1);
    }
    update(['sideBar']);
  }

  bool get hasMineAccount => selected.any((element) => element.mine);

  final _games = <String, SteamGame>{};

  Map<String, SteamGame> get games => _games;

  SteamProfile? _sorted;
  bool ascending = true;

  void _allGames() {
    _games.clear();
    for (var acc in selected) {
      if (acc == _sorted) continue;
      _games.addAll(acc.games);
    }
    if (_sorted != null) {
      final copy = Map<String, SteamGame>.from(_games);
      var keys = _sorted!.games.keys.toSet();
      print('copy ${copy.length}, keys ${keys.length}');
      _games.clear();
      if (ascending) {
        keys = copy.keys.toSet().difference(keys);
      } else {
        // keys = keys.intersection(copy.keys.toSet());
      }
      print('keys1 $keys');
      keys.addAll(_sorted!.games.keys);
      keys.addAll(copy.keys);
      for (var key in keys) {
        _games[key] = (_sorted!.games[key] ?? copy[key])!;
      }
      print('keys2 ${_games.keys}');
    }
    if (mode == DisplayMode.notOwn) {
      final ownGameKeys = selected
          .where((element) => element.mine)
          .map((e) => e.games.keys)
          .expand((element) => element)
          .toSet();
      _games.removeWhere((key, value) => ownGameKeys.contains(key));
    } else if (mode == DisplayMode.following) {
      print('排首位 ${Data.followingGames.values.map((e) => e.name)}');
      final copy = Map<String, SteamGame>.from(_games);
      _games
        ..clear()
        ..addAll(Map.from(Data.followingGames))
        ..addAll(copy);
    }
    if (_search != null) {
      _games.removeWhere((key, value) => !value.name.contains(_search!));
    }
  }

  int? get sortedIndex => _sorted == null ? null : selected.indexOf(_sorted!);

  void sort(int accountIndex, bool ascending) {
    _sorted = selected[accountIndex - 1];
    print('sort ${_sorted!.name} $ascending');
    this.ascending = ascending;
    _allGames();
    update(['content']);
  }
}
