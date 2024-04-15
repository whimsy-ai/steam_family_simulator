import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dynamic_parallel_queue/dynamic_parallel_queue.dart';
import 'package:flutter/material.dart';

import 'data.dart';
import 'locale_to_steam_languages.dart';
import 'steam_game.dart';
import 'steam_profile.dart';

class Http {
  static Dio? _dio;
  static HttpClient? _httpClient;

  static Dio get dio => _dio!;

  static void init({String? proxy}) {
    _dio?.close(force: true);
    _httpClient?.close(force: true);
    print('http proxy $proxy');
    _httpClient = HttpClient();
    if (proxy != null) {
      _httpClient!.findProxy = (uri) => 'PROXY $proxy';
    }
    _dio = Dio(BaseOptions(headers: {'Connection': 'close'}));
    _dio!.httpClientAdapter =
        IOHttpClientAdapter(createHttpClient: () => _httpClient!);
  }

  static Future<Response<T>> get<T>(String url) => dio.get<T>(url);

  static Future<SteamProfile?> loadProfile(String id) async {
    try {
      final res = await Http.get<String>(
          'https://steam.gzlock88.workers.dev/info?id=$id');
      final data =
          jsonDecode(res.data!)['response']['players'] as Iterable<dynamic>;
      return SteamProfile.fromJson(data.first);
    } catch (e) {
      return null;
    }
  }

  static Future<List<SteamProfile>?> loadProfiles(List<String> id) async {
    final res = await Http.get<String>(
        'https://steam.gzlock88.workers.dev/info?id=${id.join(',')}');
    if (res.statusCode != 200) return null;
    final data =
        jsonDecode(res.data!)['response']['players'] as Iterable<dynamic>;
    return data.map((e) => SteamProfile.fromJson(e)).toList();
  }

  static Future<SteamGame?> loadGame(id, Locale locale) async {
    // print('url https://api.steamcmd.net/v1/info/$id');
    try {
      final res = await _dio!
          .get<Map>('https://api.steamcmd.net/v1/info/$id')
          .timeout(Duration(seconds: 15));
      final data = res.data!['data'][id.toString()]['common'] as Map;
      final name = data['name_localized']?[localeToSteamLanguages(locale)] ??
          data['name'];
      return SteamGame(
        id: id.toString(),
        name: name,
        imgHash: data['icon'] ?? '',
      );
    } catch (e) {
      return null;
    }
  }

  static final _queue = Queue();

  static Future<void> loadGames(SteamProfile account, Locale locale) async {
    final games = account.games.values.toList();
    final load = <SteamGame>[];
    for (var g in games) {
      if (Data.gameCaches.containsKey(g.id)) {
        g.name = Data.gameCaches[g.id]!.name;
        continue;
      }
      load.add(g);
    }
    return _queue.addAll(load.map((g) => () async {
          final game = await Http.loadGame(g.id, locale);
          if (game == null) return;
          Data.gameCaches[g.id] = game;
          g.name = game.name;
        }));
  }
}
