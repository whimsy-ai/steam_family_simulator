import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../http.dart';
import '../my_chip.dart';
import '../steam_profile.dart';

class AddAccountDialog extends StatelessWidget {
  final controller = TextEditingController();
  final mine = RxBool(false);
  final loading = RxBool(false);
  static final linkStyle = TextStyle(
    color: Colors.blue,
  );

  AddAccountDialog._({super.key});

  static Future<SteamProfile?> show() => Get.dialog(AddAccountDialog._());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('添加账号'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            direction: Axis.vertical,
            spacing: 6,
            children: [
              Text('支持以下格式：'),
              Text('76561197999689957'),
              InkWell(
                onTap: () {
                  launchUrlString('https://steamcommunity.com/id/gzlock');
                },
                child: Text('https://steamcommunity.com/id/gzlock',
                    style: linkStyle),
              ),
              InkWell(
                onTap: () {
                  launchUrlString(
                      'https://steamcommunity.com/profiles/76561198390662912');
                },
                child: Text(
                    'https://steamcommunity.com/profiles/76561198390662912',
                    style: linkStyle),
              ),
            ],
          ),
          SizedBox(height: 10),
          TextField(
            autofocus: true,
            controller: controller,
            decoration: InputDecoration(
              label: Text('Steam id or Profile Url'),
            ),
          ),
        ],
      ),
      actions: [
        MyChip(
          selected: mine.value,
          label: '我的账号',
          onChanged: (v) => mine.value = v,
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: Text('取消'),
        ),
        Obx(
          () => ElevatedButton.icon(
            icon: loading.value
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            label: Text('Add'),
            onPressed: loading.value
                ? null
                : () async {
                    loading.value = true;
                    try {
                      final id = await _getSteamIdFromUrl(controller.text);
                      if (id != null) {
                        final acc = await Http.loadProfile(id);
                        acc?.mine = mine.value;
                        Get.back(result: acc);
                      }
                    } catch (e) {}
                    loading.value = false;
                  },
          ),
        ),
      ],
    );
  }

  Future<String?> _getSteamIdFromUrl(String input) async {
    if (input.isEmpty) {
      showToast('请输入内容');
      return null;
    }
    String? steamId;
    if (input.startsWith('https://steamcommunity.com')) {
      final res = (await Http.get<String>(input)).data!;
      final match = RegExp(r'steamid":"(\d+)').firstMatch(res)!;
      steamId = match.group(1);
    } else {
      steamId = input;
    }
    return steamId?.toString();
  }
}
