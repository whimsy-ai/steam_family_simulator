import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:oktoast/oktoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ui/ui.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

import 'data.dart';
import 'game_compare/game_compare_view.dart';
import 'home_widget.dart';
import 'http.dart';
import 'left_side_bar/left_side_bar.dart';
import 'main_controller.dart';
import 'settings.dart';
import 'steam_profile.dart';
import 'top_bar.dart';
import 'update_window_title.dart';

PackageInfo? packageInfo;
void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  print('缓存目录 ${(await getApplicationCacheDirectory()).path}');
  print('数据目录 ${(await getApplicationSupportDirectory()).path}');
  await Data.init();
  Http.init(proxy: Data.proxy);
  await hotKeyManager.unregisterAll();
  await WindowsSingleInstance.ensureSingleInstance(
    args,
    'gzlock.steam_family_simulator',
  );

  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    minimumSize: Size(800, 600),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  // todo
  // await windowManager.setIcon(assetPath(paths: ['assets', 'icon.ico']));
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    updateWindowTitle();
  });
  packageInfo ??= await PackageInfo.fromPlatform();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final _lightScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.blue,
  );

  static final _darkScheme = ColorScheme.fromSwatch(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
  );

  static final _tooltipTheme = TooltipThemeData(
    decoration: BoxDecoration(color: Colors.black45.withOpacity(0.5)), // 背景颜色
    textStyle: TextStyle(
      color: Colors.white, // 这里设置Tooltip文本颜色
      fontSize: 16.0,
    ),
  );

  bool _dark = Data.darkTheme;

  _themeChange(bool value) {
    setState(() {
      _dark = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return OKToast(
        child: GetMaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          translations: UI(),
          locale: Data.locale,
          fallbackLocale: Locale('en'),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme ?? _lightScheme,
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
            tooltipTheme: _tooltipTheme,
          ).useSystemChineseFont(Brightness.light),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme ?? _darkScheme,
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
            tooltipTheme: _tooltipTheme,
          ).useSystemChineseFont(Brightness.dark),
          initialRoute: '/main',
          transitionDuration: Duration.zero,
          themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
          getPages: [
            GetPage(
              name: '/main',
              page: () => MyHomePage(),
              binding: BindingsBuilder(() {
                Get.put(MainController(onThemeChange: _themeChange));
              }),
            ),
          ],
        ),
      );
    });
  }
}

class MyHomePage extends StatelessWidget {
  final accounts = RxList<SteamProfile>();

  MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VirtualWindowFrame(
        child: Column(
          children: [
            TopBar(),
            Divider(height: 1),
            Expanded(
              child: Row(children: [
                /// 左边栏
                SideBar(),
                VerticalDivider(width: 1),

                Expanded(
                  child: Navigator(
                    key: Get.nestedKey(1),
                    initialRoute: '/home',
                    onGenerateRoute: (RouteSettings settings) {
                      if (settings.name == '/home') {
                        return GetPageRoute(
                          settings: settings,
                          transitionDuration: Duration.zero,
                          page: () => FastSettings(),
                        );
                      } else if (settings.name == '/content') {
                        return GetPageRoute(
                          settings: settings,
                          transitionDuration: Duration.zero,
                          page: () => GameCompareView<MainController>(),
                        );
                      } else if (settings.name == '/settings') {
                        return GetPageRoute(
                          settings: settings,
                          transitionDuration: Duration.zero,
                          page: () => Settings(),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
