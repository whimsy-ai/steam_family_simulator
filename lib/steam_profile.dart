import 'dart:convert';

import 'data.dart';
import 'http.dart';
import 'steam_game.dart';

class SteamProfile {
  final String id;
  final String name;
  final String avatar;
  final String profileUrl;
  final games = <String, SteamGame>{};
  bool mine;
  bool loadingInfo = false;
  bool loadingGames = false;
  bool gamesVisible = false;
  String? loadError;

  SteamProfile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.profileUrl,
    this.mine = false,
  });

  Map<String, dynamic> toJson() => {
        'steamid': id,
        'personaname': name,
        'avatarfull': avatar,
        'mine': mine ? 1 : 0,
        'profileurl': profileUrl,
      };

  factory SteamProfile.fromJson(Map<String, dynamic> map) => SteamProfile(
        id: map['steamid'],
        name: map['personaname'],
        avatar: map['avatarfull'],
        profileUrl: map['profileurl'],
        mine: map['mine'] == 1,
      );

  Future<void> loadGames() async {
    if (loadingGames) return;
    gamesVisible = false;
    loadError = null;
    loadingGames = true;
    games.clear();

    try {
      final res = await Http.get<String>(
          'https://steam.gzlock88.workers.dev/games?id=$id');
      final data = jsonDecode(res.data!)['response'] as Map<String, dynamic>;
      gamesVisible = data.containsKey('games');
      if (gamesVisible) {
        final list = data['games'] as Iterable<dynamic>;
        for (var item in list) {
          final game = SteamGame.fromJson(item);
          if (Data.gameCaches.containsKey(game.id)) {
            games[game.id] = Data.gameCaches[game.id]!;
          }
          games[game.id] = game;
        }
      }
    } catch (e) {
      loadError = e.toString();
    }
    loadingGames = false;
  }

  @override
  toString() => jsonEncode([id, name, avatar, profileUrl]);

  factory SteamProfile.fromString(String source) {
    final data = jsonDecode(source);
    return SteamProfile(
      id: data[0],
      name: data[1],
      avatar: data[2],
      profileUrl: data[3],
    );
  }
}
