import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:steam_family_simulator/steam_profile.dart';

class Http {
  static Dio? _dio;
  static HttpClient? _httpClient;

  static void init({String? proxy}) {
    _dio?.close(force: true);
    _httpClient?.close(force: true);
    print('http proxy $proxy');
    _httpClient = HttpClient();
    if (proxy != null) {
      _httpClient!.findProxy = (uri) => 'PROXY $proxy';
    }
    _dio = Dio(BaseOptions());
    _dio!.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        return _httpClient!;
      },
    );
  }

  static Future<Response<T>> get<T>(String url) => _dio!.get<T>(url);

  static Future<List<SteamProfile>?> loadProfiles(List<String> id) async {
    final res = await Http.get<String>(
        'https://steam.gzlock88.workers.dev/info?id=${id.join(',')}');
    if (res.statusCode != 200) return null;
    final data =
        jsonDecode(res.data!)['response']['players'] as Iterable<dynamic>;
    return data.map((e) => SteamProfile.fromJson(e)).toList();
  }
}
