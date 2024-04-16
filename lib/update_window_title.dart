import 'package:get/get.dart';
import 'package:ui/ui.dart';
import 'package:window_manager/window_manager.dart';

import 'main.dart';

updateWindowTitle() async {
  // print('设置窗口标题 ${UI.findUp.tr} v${packageInfo.version}');
  windowManager.setTitle('${UI.s_f_s.tr} v${packageInfo!.version}');
}
