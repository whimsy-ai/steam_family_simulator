import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                      Widget avatar = Image.network(account.avatar);
                      if (controller.isSelected(account)) {
                        avatar = Stack(
                          children: [
                            avatar,
                            Positioned.fill(
                              child: Center(
                                child: CircleAvatar(
                                  child: Icon(Icons.check),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return controller.sideBarExpand
                          ? ListTile(
                              selected: controller.isSelected(account),
                              selectedTileColor: Theme.of(context).canvasColor,
                              leading: CircleAvatar(
                                radius: 20,
                                child: avatar,
                              ),
                              title: Text(account.name),
                              onTap: () {
                                controller.select(account);
                              },
                            )
                          : Tooltip(
                              verticalOffset: 50,
                              richMessage: TextSpan(
                                  text: '${account.name}\n',
                                  children: [
                                    WidgetSpan(
                                        child: TextButton(
                                      onPressed: () async {
                                        final sure =
                                            await Get.dialog(AlertDialog(
                                          title: Text('确认删除 ${account.name}?'),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Get.back(result: true),
                                              child: Text('确认'),
                                            ),
                                          ],
                                        ));
                                        if (sure == true) {
                                          controller.removeAccount(account);
                                        }
                                      },
                                      child: Text('删除'),
                                    )),
                                  ]),
                              exitDuration: Duration.zero,
                              child: InkWell(
                                onTap: () {
                                  controller.select(account);
                                },
                                child: avatar,
                              ),
                            );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _account(BuildContext context, SteamProfile account) {
    Widget avatar = Image.network(account.avatar);
    if (controller.isSelected(account)) {
      avatar = Stack(
        children: [
          avatar,
          Positioned.fill(
            child: Center(
              child: CircleAvatar(
                child: Icon(Icons.check),
              ),
            ),
          ),
        ],
      );
    }
    Widget widget = controller.sideBarExpand
        ? ListTile(
            selected: controller.isSelected(account),
            selectedTileColor: Theme.of(context).canvasColor,
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
      richMessage: TextSpan(
          text: '${account.name}\n',
          children: [
            WidgetSpan(
                child: ElevatedButton(
              onPressed: () async {
                final sure = await Get.dialog(AlertDialog(
                  title: Text('确认删除 ${account.name}?'),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      child: Text('确认'),
                    ),
                  ],
                ));
                if (sure == true) {
                  controller.selected.remove(account);
                  controller.removeAccount(account);
                }
              },
              child: Text('删除'),
            )),
          ]),
      child: widget,
    );
  }
}
