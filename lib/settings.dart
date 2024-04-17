import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ui/ui.dart';

import 'change_language_tile.dart';
import 'data.dart';
import 'http.dart';
import 'main_controller.dart';

Timer? _lazyTimer;

class Settings extends GetView<MainController> {
  @override
  Widget build(BuildContext context) {
    final c = TextEditingController(text: Data.proxy);
    return Scaffold(
      appBar: AppBar(
        title: Text(UI.settings.tr),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                ChangeLanguageTile(),
                ListTile(
                  title: TextField(
                    controller: c,
                    decoration: InputDecoration(
                      labelText: UI.proxy.tr,
                      prefixText: 'http://',
                      suffix: IconButton(
                        iconSize: 14,
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          c.text = '';
                          Data.proxy = null;
                        },
                      ),
                    ),
                    onChanged: (v) {
                      _lazyTimer?.cancel();
                      _lazyTimer = Timer(Duration(milliseconds: 200), () {
                        print('设置代理 $v');
                        Data.proxy = v.isEmpty ? null : v;
                        Http.init(proxy: v);
                      });
                    },
                  ),
                  trailing: SizedBox(
                    height: kToolbarHeight,
                    child: ElevatedButton(
                      child: Text('测试\n可用性'),
                      onPressed: () async {
                        try {
                          final res =
                              await Http.dio.get<String>('https://google.com');
                          // print(res.data!.substring(0, 100));
                          showToast(UI.success.tr);
                        } catch (e) {
                          showToast(UI.failed.tr);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
