import 'dart:convert';

class SteamGame {
  final String id;
  String name;
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
