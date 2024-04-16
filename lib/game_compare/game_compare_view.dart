import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:oktoast/oktoast.dart';
import 'package:ui/ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../data.dart';
import '../http.dart';
import '../main_controller.dart';
import '../my_chip.dart';
import '../steam_game.dart';
import '../steam_profile.dart';
import 'compare_controller.dart';
import 'my_table.dart';

class GameCompareView<T extends MainController> extends GetView<T> {
  final LinkedScrollControllerGroup verticalScrolls =
      LinkedScrollControllerGroup();

  final RxBool _show = false.obs;

  GameCompareView({super.key}) {
    verticalScrolls.addOffsetChangedListener(_changed);
  }

  _changed() {
    _show.value = verticalScrolls.offset > 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: GetBuilder<T>(
              id: 'content',
              builder: (c) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            Text(UI.filter.tr),
                            MyChip(
                              label: UI.all.tr,
                              selected: controller.mode == DisplayMode.all,
                              onChanged: (v) {
                                controller.mode = DisplayMode.all;
                              },
                            ),
                            MyChip(
                                label: UI.no_games.tr,
                                selected: controller.mode == DisplayMode.notOwn,
                                onSelect: () {
                                  final mine = controller.selected
                                      .firstWhereOrNull((acc) => acc.mine);
                                  if (mine == null) {
                                    showToast(UI.add_mine_account.tr);
                                  }
                                  return mine != null;
                                },
                                onChanged: (v) {
                                  controller.mode =
                                      controller.mode == DisplayMode.notOwn
                                          ? DisplayMode.all
                                          : DisplayMode.notOwn;
                                }),
                            Obx(
                              () => MyChip(
                                  label:
                                      '${UI.want_games.tr}(${Data.followingGames.length})',
                                  selected:
                                      controller.mode == DisplayMode.following,
                                  onSelect: () => true,
                                  onChanged: (v) {
                                    controller.mode = DisplayMode.following;
                                  }),
                            ),
                            SizedBox(
                              width: 300,
                              height: kToolbarHeight,
                              child: TextFormField(
                                initialValue: controller.search,
                                onChanged: (v) => controller.search = v,
                                decoration: InputDecoration(
                                  alignLabelWithHint: true,
                                  floatingLabelAlignment:
                                      FloatingLabelAlignment.start,
                                  prefixIcon: Icon(Icons.search, size: 14),
                                  hintText: UI.input_something.tr,
                                  label: Text(UI.search.tr),
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            MyChip(
                              label: UI.show_exfgls.tr,
                              selected: controller.showExfgls,
                              onChanged: (v) {
                                controller.showExfgls = v;
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: _table(context)),
                    ],
                  )),
        ),
      ),
      floatingActionButton: Obx(
        () => AnimatedOpacity(
          opacity: _show.value ? 1 : 0,
          duration: Duration(milliseconds: 200),
          child: FloatingActionButton(
              child: Icon(Icons.vertical_align_top),
              onPressed: () {
                verticalScrolls.jumpTo(0);
              }),
        ),
      ),
    );
  }

  static const double columnMinWidth = 200;
  static const double firstColumnWidth = 200;

  Widget _table(BuildContext context) {
    final keys = controller.games.keys.toList();
    return LayoutBuilder(builder: (context, constrains) {
      final maxWidth = constrains.maxWidth;

      /// 计算真正的列宽
      /// 包括每列的分割线(1像素）
      double gameColumnWidth = math.max(
        columnMinWidth,
        (maxWidth - firstColumnWidth) / controller.selected.length -
            (controller.selected.length - 1),
      );
      print('max:$maxWidth  final $gameColumnWidth');
      return MyTable(
        verticalScrolls: verticalScrolls,
        headerColor: Theme.of(context).secondaryHeaderColor,
        firstColumnColor: Theme.of(context).secondaryHeaderColor,
        leftTopWidgetBuilder: (c) => CustomPaint(
          painter: _Painter(
            color: Theme.of(c).dividerColor,
            accountLength: controller.selected.length,
            gameLength: keys.length,
          ),
        ),
        rowHeight: 50,
        headerHeight: 70,
        firstColumnWidth: firstColumnWidth,
        columnWidth: gameColumnWidth,
        rowCount: controller.games.length,
        columnCount: controller.selected.length,

        /// 账号名
        headerCellBuilder: (c, column) {
          return _accountName(controller.selected[column]);
        },

        /// 游戏名
        firstColumnBuilder: (c, row) {
          return _gameName(controller.games.values.elementAt(row));
        },
        cellBuilder: (c, int row, int column) {
          final a = controller.selected[column];
          return a.games.containsKey(keys[row])
              ? Icon(Icons.check)
              : SizedBox.shrink();
        },
      );
    });
  }

  Widget _accountName(SteamProfile account) {
    final gamesVisible = account.gamesVisible;
    Widget child = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundImage: NetworkImage(account.avatar),
          ),
          SizedBox(width: 4),
          Flexible(
            child: Text(
              account.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 4),
          _accountState(account),
          if (controller.sorted == account)
            Icon(
              controller.ascending
                  ? Icons.arrow_drop_up_rounded
                  : Icons.arrow_drop_down_rounded,
            ),
        ],
      ),
    );
    if (gamesVisible || account.loadError != null) {
      child = InkWell(
        child: child,
        onTap: () {
          if (gamesVisible) {
            controller.sort(account);
          } else if (account.loadError != null) {
            account.loadGames().then((_) {
              controller.updateGames();
              return Http.loadGames(account, Data.locale);
            }).then((_) {
              controller.updateGames();
            });
          }
        },
      );
    }
    {
      String? msg;
      if (account.loadingGames) {
        msg = UI.loading_games.tr;
      } else if (account.loadError != null) {
        msg = account.loadError!;
      } else if (gamesVisible == false) {
        msg = UI.games_invisible.tr;
      }
      if (msg != null) {
        child = Tooltip(
          message: msg,
          child: child,
        );
      }
    }
    return child;
  }

  Widget _accountState(SteamProfile account) {
    if (account.loadingGames) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    } else if (account.loadError != null) {
      return Icon(Icons.error_outline_rounded, color: Colors.red);
    } else if (account.gamesVisible) {
      return Text('(${account.games.length})');
    } else if (account.gamesVisible == false) {
      return Icon(
        Icons.warning_amber_rounded,
        color: Colors.redAccent,
      );
    }
    return SizedBox.shrink();
  }

  Widget _gameName(SteamGame game) {
    return Tooltip(
      preferBelow: true,
      enableTapToDismiss: false,
      richMessage: TextSpan(children: [
        TextSpan(children: [
          if (game.exfgls) TextSpan(text: '${UI.exfgls.tr}\n'),
          WidgetSpan(
            child: Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              // mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  child: Text(UI.open.tr),
                  onPressed: () {
                    launchUrlString(
                        'https://store.steampowered.com/app/${game.id}');
                  },
                ),
                Obx(() {
                  final contains = Data.followingGames.keys.contains(game.id);
                  return IconButton(
                    icon: Icon(
                      contains ? Icons.heart_broken : FontAwesomeIcons.heart,
                      color: contains ? Colors.red : Colors.pinkAccent,
                    ),
                    onPressed: () {
                      if (contains) {
                        Data.followingGames.remove(game.id);
                      } else {
                        Data.followingGames[game.id] = game;
                      }
                      if (controller.mode == DisplayMode.following) {
                        controller.updateGames();
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ]),
      ]),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              game.avatar,
              errorBuilder: (BuildContext context, _, __) => SizedBox.shrink(),
            ),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                game.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final Color color;
  final int accountLength, gameLength;

  _Painter(
      {super.repaint,
      required this.color,
      required this.accountLength,
      required this.gameLength});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawLine(
      Offset.zero,
      Offset(size.width, size.height),
      Paint()
        ..color = color
        ..strokeWidth = 1
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high,
    );
    var pt = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: '${UI.game.tr}($gameLength)',
        style: TextStyle(fontSize: 14, color: color),
      ),
    )..layout();
    pt.paint(
        canvas,
        Offset(
          10,
          size.height - pt.height - 10,
        ));

    pt = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: '${UI.account.tr}($accountLength)',
        style: TextStyle(fontSize: 14, color: color),
      ),
    )..layout();
    pt.paint(
        canvas,
        Offset(
          size.width - pt.width - 10,
          10,
        ));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
