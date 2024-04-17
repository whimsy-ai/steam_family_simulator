import 'dart:async';

import 'package:get/get.dart';

import '../data.dart';
import '../http.dart';
import '../steam_game.dart';
import '../steam_profile.dart';

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
    updateGames();
  }

  String? _search;
  Timer? _searchTimer;

  /// 隐藏不允许家庭共享的游戏
  bool _showExfgls = false;
  int exfgls = 0;

  bool get showExfgls => _showExfgls;

  set showExfgls(bool value) {
    _showExfgls = value;
    updateGames();
  }

  String? get search => _search;

  set search(String? value) {
    _search = value;
    _searchTimer?.cancel();
    _searchTimer = Timer(Duration(milliseconds: 200), () {
      updateGames();
    });
  }

  bool isSelected(SteamProfile v) => selected.contains(v);

  void select(SteamProfile v) {
    if (selected.contains(v)) {
      if (_sorted == v) _sorted = null;
      selected.remove(v);
      if (!hasMineAccount) _mode = DisplayMode.all;
      _apply();
      Get.offAllNamed('/content', id: 1);
      update(['content']);
    } else {
      if (v.mine) {
        selected.insert(0, v);
      } else {
        selected.add(v);
      }
      update(['content']);
      v.loadGames().then((_) {
        _apply();
        update(['content']);
        return Http.loadGames(v, Data.locale);
      }).then((_) {
        update(['content']);
      });
    }
    if (selected.isEmpty) {
      Get.offAllNamed('/home', id: 1);
    } else {
      Get.offAllNamed('/content', id: 1);
    }
    update(['sideBar', 'content']);
  }

  bool get hasMineAccount => selected.any((element) => element.mine);

  final _games = <String, SteamGame>{};

  Map<String, SteamGame> get games => _games;

  SteamProfile? _sorted;
  bool ascending = true;

  void _apply() {
    _games.clear();
    for (var acc in selected) {
      _games.addAll(acc.games);
    }

    Set<String> keys;

    /// 显示模式
    if (mode == DisplayMode.notOwn) {
      keys = _games.keys.toSet().difference(selected
          .where((element) => element.mine)
          .map((e) => e.games.keys)
          .expand((element) => element)
          .toSet());
    } else if (mode == DisplayMode.following) {
      print('排首位 ${Data.followingGames}');
      keys = Data.followingGames.keys.toSet();
    } else {
      keys = _games.keys.toSet();
    }
    print('显示器模式 ${keys.length}');

    /// 排序
    if (selected.length > 1 && _sorted != null) {
      print('sort ${_sorted!.name} $ascending');
      // print('copy ${_games.length}, keys ${keys.length}');
      final copy = <String>{};
      Set<String> other = _sorted!.games.keys.toSet().intersection(keys);
      print('重复 ${other.length}');
      if (ascending) {
        copy.addAll(other);
        copy.addAll(keys);
      } else {
        copy.addAll(keys.difference(other));
        copy.addAll(other);
      }
      keys = copy;
      // print('keys1 $keys');
      // keys.addAll(_sorted!.games.keys);
      // keys.addAll(_games.keys);
      // print('keys2 ${_games.keys}');
    }
    print('排序 ${keys.length}');
    final copy = Map.from(_games);
    _games.clear();
    for (var key in keys) {
      _games[key] =
          Data.followingGames[key] ?? Data.gameCaches[key] ?? copy[key];
    }

    /// 搜索
    if (_search != null) {
      _games.removeWhere((key, value) =>
          !value.name.toLowerCase().contains(_search!.toLowerCase()));
    }

    final exfgls = _games.keys.where((key) => _games[key]!.exfgls).toSet();
    this.exfgls = exfgls.length;

    if (showExfgls == false) {
      for (var k in exfgls) {
        _games.remove(k);
      }
    }
  }

  SteamProfile? get sorted => _sorted;

  void sort(SteamProfile account) {
    if (selected.contains(account) == false) return;
    if (_sorted == account) {
      ascending = !ascending;
    } else {
      ascending = true;
    }
    _sorted = account;
    updateGames();
  }

  void updateGames() {
    _apply();
    update(['content']);
  }
}
