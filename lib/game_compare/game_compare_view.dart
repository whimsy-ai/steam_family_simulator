import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:steam_family_simulator/game_compare/my_table.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../compare_controller.dart';
import '../data.dart';
import '../main_controller.dart';
import '../my_chip.dart';
import '../steam_profile.dart';

class GameCompareView extends GetView<MainController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: GetBuilder<MainController>(
              id: 'content',
              builder: (c) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                children: [
                                  Text('游戏过滤器'),
                                  MyChip(
                                    label: '全部',
                                    selected:
                                        controller.mode == DisplayMode.all,
                                    onChanged: (v) {
                                      controller.mode = DisplayMode.all;
                                    },
                                  ),
                                  MyChip(
                                      label: '我没有的游戏',
                                      selected:
                                          controller.mode == DisplayMode.notOwn,
                                      onSelect: () {
                                        final mine = controller.selected
                                            .firstWhereOrNull(
                                                (acc) => acc.mine);
                                        if (mine == null) {
                                          showToast('请添加主账号');
                                        }
                                        return mine != null;
                                      },
                                      onChanged: (v) {
                                        controller.mode = controller.mode ==
                                                DisplayMode.notOwn
                                            ? DisplayMode.all
                                            : DisplayMode.notOwn;
                                      }),
                                  Obx(
                                    () => MyChip(
                                        label:
                                            '想要的游戏(${Data.followingGames.length})',
                                        selected: controller.mode ==
                                            DisplayMode.following,
                                        onSelect: () => true,
                                        onChanged: (v) {
                                          controller.mode =
                                              DisplayMode.following;
                                        }),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    height: kToolbarHeight,
                                    child: TextFormField(
                                      initialValue: controller.search,
                                      onChanged: (v) => controller.search = v,
                                      decoration: InputDecoration(
                                        alignLabelWithHint: true,
                                        floatingLabelAlignment:
                                            FloatingLabelAlignment.start,
                                        prefixIcon:
                                            Icon(Icons.search, size: 14),
                                        hintText: '关键字',
                                        label: Text('搜索'),
                                        contentPadding: EdgeInsets.zero,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.outlined(
                              onPressed: () {
                                controller.layout =
                                    controller.layout == Layout.list
                                        ? Layout.grid
                                        : Layout.list;
                              },
                              icon: Icon(
                                controller.layout == Layout.list
                                    ? Icons.apps_rounded
                                    : Icons.format_list_bulleted_rounded,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: _table(context)),
                    ],
                  )),
        ),
      ),
    );
  }

  Widget _table(BuildContext context) {
    final keys = controller.games.keys.toList();
    return LayoutBuilder(builder: (context, constrains) {
      final maxWidth = constrains.maxWidth;
      final realWidth = controller.selected.length * 260 + 200;
      double gameColumnWidth = realWidth >= maxWidth
          ? 200
          : maxWidth / (controller.selected.length + 1);
      print('max:$maxWidth  real:$realWidth, final $gameColumnWidth');
      return MyTable(
        headerColor: Theme.of(context).secondaryHeaderColor,
        firstColumnColor: Theme.of(context).secondaryHeaderColor,
        leftTopWidgetBuilder: (c, w, h) => CustomPaint(
          painter: _Painter(
            color: Theme.of(c).dividerColor,
            accountLength: controller.selected.length,
            gameLength: keys.length,
          ),
          size: Size(w, h),
        ),
        rowCount: controller.games.length,
        headerHeight: 50,
        columnCount: controller.selected.length,
        columnWidth: gameColumnWidth,

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!account.gamesVisible)
          Tooltip(
            message: '没有公开游戏库',
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
            ),
          ),
        CircleAvatar(
          backgroundImage: NetworkImage(account.avatar),
          radius: 10,
        ),
        Flexible(
          child: Text(
            account.name,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text('(${account.games.length})'),
      ],
    );
  }

  Widget _gameName(SteamGame game) {
    return Tooltip(
      preferBelow: true,
      enableTapToDismiss: false,
      richMessage: TextSpan(children: [
        TextSpan(children: [
          WidgetSpan(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  child: Text('在浏览器打开'),
                  onPressed: () {
                    launchUrlString(
                        'https://store.steampowered.com/app/${game.id}');
                  },
                ),
                IconButton(
                  icon: Icon(FontAwesomeIcons.heart),
                  onPressed: () {
                    Data.followingGames[game.id] = game;
                  },
                ),
              ],
            ),
          ),
        ]),
      ]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            game.avatar,
            errorBuilder: (BuildContext context, _, __) {
              return SizedBox.shrink();
            },
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
        text: '游戏($gameLength)',
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
        text: '账号($accountLength)',
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
