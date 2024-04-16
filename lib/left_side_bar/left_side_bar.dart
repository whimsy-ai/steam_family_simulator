import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui/ui.dart';

import '../main_controller.dart';
import '../steam_profile.dart';
import 'add_account_dialog.dart';

class SideBar extends GetView<MainController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
        id: 'sideBar',
        builder: (c) {
          return AnimatedContainer(
            width: controller.sideBarExpand ? 200 : 100,
            duration: Duration(milliseconds: 200),
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      /// 添加账号按钮
                      Expanded(
                        child: IconButton(
                          onPressed: () async {
                            final profile = await AddAccountDialog.show();
                            if (profile != null) {
                              controller.addAccount(profile);
                            }
                          },
                          icon: Icon(
                            Icons.add,
                          ),
                        ),
                      ),

                      /// 切换光暗
                      InkWell(
                        onTap: () async {
                          controller.darkMode = !controller.darkMode;
                        },
                        child: SizedBox(
                          width: 24,
                          height: double.infinity,
                          child: Icon(
                            Icons.light_mode_rounded,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),
                      ),

                      /// 展开侧边栏
                      InkWell(
                        onTap: () async {
                          controller.sideBarExpand = !controller.sideBarExpand;
                        },
                        child: SizedBox(
                          width: 24,
                          height: double.infinity,
                          child: Transform.rotate(
                            angle: 90 * math.pi / 180,
                            child: Icon(
                              Icons.import_export_rounded,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: controller.accounts.length,
                    itemBuilder: (context, index) {
                      final account = controller.accounts[index];
                      return _account(context, account);
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _account(BuildContext context, SteamProfile account) {
    Widget avatar = ClipOval(
      child: Image.network(
        account.avatar,
        errorBuilder: (_, __, ___) => CircleAvatar(),
      ),
    );
    if (controller.isSelected(account)) {
      avatar = Stack(
        children: [
          avatar,
          Positioned.fill(
            child: Center(
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }
    Widget widget = controller.sideBarExpand
        ? ListTile(
            selected: controller.isSelected(account),
            leading: CircleAvatar(
              radius: 20,
              child: avatar,
            ),
            title: Text(account.name, overflow: TextOverflow.ellipsis),
            onTap: () {
              controller.select(account);
            },
          )
        : InkWell(
            onTap: () {
              controller.select(account);
            },
            child: avatar,
          );

    return Tooltip(
      richMessage: TextSpan(text: '${account.name}\n', children: [
        WidgetSpan(
            child: ElevatedButton(
          onPressed: () async {
            final sure = await Get.dialog(AlertDialog(
              title: Text(
                UI.confirm_delete.tr.replaceFirst('%s', account.name),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  child: Text(UI.confirm.tr),
                ),
              ],
            ));
            if (sure == true) {
              controller.selected.remove(account);
              controller.removeAccount(account);
            }
          },
          child: Text(UI.delete.tr),
        )),
      ]),
      child: widget,
    );
  }
}
