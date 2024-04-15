import 'dart:convert';
import 'dart:ui';

import 'package:get/get_rx/get_rx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'steam_game.dart';
import 'steam_profile.dart';

const _proxyKey = 'proxy';
const _accountsKey = 'account';
const _themeKey = 'theme';
const _gamesKey = 'games';
const _localeKey = 'locale';
const _gameCacheKey = 'game_cache';
const _profileCacheKey = 'profile_cache';

class Data {
  static late SharedPreferences _core;

  static Future<void> init([bool test = false]) async {
    _core = await SharedPreferences.getInstance();
    _proxy = _core.getString(_proxyKey);
    _darkTheme = _core.getBool(_themeKey) ?? true;

    if (_core.containsKey(_accountsKey)) {
      accounts.addAll(_core
          .getStringList(_accountsKey)!
          .map((e) => SteamProfile.fromJson(jsonDecode(e))));
    }
    accounts.listen((v) {
      _core.setStringList(
          _accountsKey, v.map((e) => jsonEncode(e.toJson())).toList());
    });

    followingGames = RxSet();
    if (_core.containsKey(_gamesKey)) {
      followingGames.addAll(_core.getStringList(_gamesKey)!);
    }
    followingGames.listen((v) {
      _core.setStringList(_gamesKey, followingGames.toList());
    });

    gameCaches = RxMap();
    if (_core.containsKey(_gameCacheKey)) {
      final list =
          _core.getStringList(_gameCacheKey)!.map(SteamGame.fromString);
      gameCaches.addAll(Map.fromEntries(list.map((e) => MapEntry(e.id, e))));
      print('加载游戏缓存 ${gameCaches.length} 个');
    }
    gameCaches.listen(saveGameCaches);
  }

  static String? _proxy;

  static String? get proxy => _proxy;

  static set proxy(String? value) {
    _proxy = value;
    if (value == null) {
      _core.remove(_proxyKey);
    } else {
      _core.setString(_proxyKey, value);
    }
  }

  static final RxList<SteamProfile> accounts = RxList();

  static late bool _darkTheme;

  static bool get darkTheme => _darkTheme;

  static set darkTheme(bool value) {
    _darkTheme = value;
    _core.setBool(_themeKey, value);
  }

  static late final RxSet<String> followingGames;

  static Locale get locale {
    final locale = _core.getString(_localeKey);
    print('语言 $locale');

    /// todo
    if (locale != null
        // && UI.languages.keys.contains(locale)
        ) {
      return Locale(locale);
    }
    return PlatformDispatcher.instance.locale;
  }

  static set locale(Locale locale) =>
      _core.setString(_localeKey, locale.toString());

  static late RxMap<String, SteamGame> gameCaches;

  static saveGameCaches([Map<String, SteamGame>? data]) {
    data ??= gameCaches;
    _core.setStringList(
        _gameCacheKey, data.keys.map((key) => data![key]!.toString()).toList());
  }
}
