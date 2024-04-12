import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:steam_family_simulator/main_controller.dart';
import 'package:window_manager/window_manager.dart';

class TopBar extends GetView<MainController> {
  final double iconSize;

  const TopBar({super.key, this.iconSize = 16});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: _maximize,
              onPanStart: (details) {
                windowManager.startDragging();
              },
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text('Steam家庭模拟器'),
              ),
            ),
          ),
          Row(
            children: [
              /// 设置
              InkWell(
                onTap: () {
                  Get.toNamed('/settings', id: 1);
                },
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    FontAwesomeIcons.gear,
                    size: iconSize,
                  ),
                ),
              ),

              /// Github
              InkWell(
                onTap: () {},
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    FontAwesomeIcons.github,
                    size: iconSize,
                  ),
                ),
              ),

              /// minimize
              InkWell(
                onTap: () => windowManager.minimize(),
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.minimize_rounded,
                    size: iconSize,
                  ),
                ),
              ),

              /// maximize
              InkWell(
                onTap: _maximize,
                child: Container(
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.photo_size_select_small_rounded,
                    size: iconSize,
                  ),
                ),
              ),

              /// close
              InkWell(
                onTap: () => exit(0),
                child: Container(
                  height: double.infinity,
                  color: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.close,
                    size: iconSize,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  static _maximize() async {
    (await windowManager.isMaximized())
        ? windowManager.unmaximize()
        : windowManager.maximize();
  }
}
