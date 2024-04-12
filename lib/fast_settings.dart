import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FastSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text('其他作品'),
                  ),
                  ListTile(
                    title: Text('找起来！'),
                    subtitle: Text('小游戏'),
                    onTap: () {
                      launchUrlString(
                          'https://store.steampowered.com/app/2550370');
                    },
                    trailing: Icon(FontAwesomeIcons.squareSteam),
                  ),
                  ListTile(
                    title: Text('欢迎投喂'),
                  ),
                  if (kDebugMode || Get.locale!.toString().contains('zh'))
                    ListTile(
                      leading: Icon(
                        FontAwesomeIcons.boltLightning,
                        color: Colors.yellow,
                      ),
                      title: Text('爱发电'),
                      onTap: () {
                        launchUrlString('https://afdian.net/a/whimsy-ai');
                      },
                    ),
                  if (kDebugMode || Get.locale!.toString().contains('en'))
                    ListTile(
                      title: Image.asset('assets/images/kofi_button_red.webp'),
                      onTap: () {
                        launchUrlString('https://ko-fi.com/whimsy_ai');
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
