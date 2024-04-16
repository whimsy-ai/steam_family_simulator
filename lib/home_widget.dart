import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'change_language_tile.dart';
import 'data.dart';

class FastSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 300,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ChangeLanguageTile(),
                  Divider(),
                  ListTile(
                    title: Text(UI.other_applications.tr),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: ListTile(
                      leading: Icon(FontAwesomeIcons.squareSteam),
                      title: Text(UI.find_up.tr),
                      subtitle: Data.locale.languageCode == 'zh'
                          ? Text('鄙人开发的小游戏')
                          : null,
                      onTap: () async {
                        launchUrlString(
                            'https://store.steampowered.com/app/2550370');
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(UI.feed.tr),
                  ),
                  if (kDebugMode || Data.locale.languageCode == 'zh')
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
                  ListTile(
                    title: Image.asset('assets/images/kofi_button_red.webp'),
                    onTap: () {
                      launchUrlString('https://ko-fi.com/whimsy_ai');
                    },
                  ),
                  if (kDebugMode) Text('当前语言 ${Data.locale}'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
