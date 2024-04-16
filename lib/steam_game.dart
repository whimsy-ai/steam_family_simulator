import 'dart:convert';

class SteamGame {
  final String id;
  String name;
  final String imgHash;
  final bool exfgls;

  SteamGame({
    required this.id,
    required this.name,
    required this.imgHash,
    this.exfgls = false,
  });

  String get avatar =>
      'http://media.steampowered.com/steamcommunity/public/images/apps/$id/$imgHash.jpg';

  /// from Http data
  factory SteamGame.fromJson(Map<String, dynamic> map) => SteamGame(
        id: map['appid'].toString(),
        name: map['name'],
        imgHash: map['img_icon_url'],
        exfgls: map['exfgls'] == '1',
      );

  factory SteamGame.fromString(String source) {
    final data = jsonDecode(source) as List;
    return SteamGame(
      id: data[0],
      name: data[1],
      imgHash: data[2],
      exfgls: data.length == 4,
    );
  }

  @override
  String toString() => jsonEncode([
        id,
        name,
        imgHash,
        if (exfgls) 1,
      ]);
}
