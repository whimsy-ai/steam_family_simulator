import 'dart:convert';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'steam_profile.dart';

const _proxyKey = 'proxy';
const _accountsKey = 'account';
const _themeKey = 'theme';
const _gamesKey = 'games';
const _localeKey = 'locale';

class Data {
  static late SharedPreferences _core;

  static Future<void> init() async {
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

    if (_core.containsKey(_gamesKey)) {
      final list = _core.getStringList(_gamesKey)!.map(SteamGame.fromString);
      followingGames.addAll({for (var d in list) d.id: d});
    }
    followingGames.listen((v) {
      _core.setStringList(
          _gamesKey, v.values.map((e) => e.toString()).toList());
    });
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

  static final RxMap<String, SteamGame> followingGames = RxMap();

  static Locale get locale {
    final locale = _core.getString(_localeKey);
    print('语言 $locale');

    /// todo
    if (locale != null
        // && UI.languages.keys.contains(locale)
        ) {
      return Locale(locale);
    }
    return Get.deviceLocale!;
  }

  static set locale(Locale locale) =>
      _core.setString(_localeKey, locale.toString());
}
