import 'dart:convert';

import 'http.dart';

class SteamProfile {
  final String id;
  final String name;
  final String avatar;
  final String profileUrl;
  final games = <String, SteamGame>{};
  bool mine;
  bool loadingInfo = false;
  bool loadingGames = false;
  bool gamesVisible = true;

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
    loadingGames = true;
    gamesVisible = true;
    games.clear();

    final res = await Http.get<String>(
        'https://steam.gzlock88.workers.dev/games?id=$id');
    if (res.statusCode == 200) {
      final data = jsonDecode(res.data!)['response'] as Map<String, dynamic>;
      gamesVisible = data.containsKey('games');
      if (gamesVisible) {
        final list = data['games'] as Iterable<dynamic>;
        for (var item in list) {
          final game = SteamGame.fromJson(item);
          games[game.id] = game;
        }
      }
    }
    loadingGames = false;
  }
}

class SteamGame {
  final String id;
  final String name;
  final String imgHash;

  SteamGame({
    required this.id,
    required this.name,
    required this.imgHash,
  });

  String get avatar =>
      'http://media.steampowered.com/steamcommunity/public/images/apps/$id/$imgHash.jpg';

  factory SteamGame.fromJson(Map<String, dynamic> map) => SteamGame(
        id: map['appid'].toString(),
        name: map['name'],
        imgHash: map['img_icon_url'],
      );

  factory SteamGame.fromString(String source) {
    final data = jsonDecode(source);
    return SteamGame(
        id: data[0],
        name: data[1],
        imgHash: data[2],
      );
  }

  @override
  String toString() => jsonEncode([id, name, imgHash]);


}
