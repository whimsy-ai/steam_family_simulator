import 'package:get/get.dart';

import 'compare_controller.dart';
import 'data.dart';
import 'steam_profile.dart';

enum Layout {
  list,
  grid,
}

class MainController extends GetxController with GameFilterController {
  final List<SteamProfile> _accounts = Data.accounts.toList();
  bool _sideBarExpand = false;
  final void Function(bool light) onThemeChange;

  Layout _layout = Layout.list;

  Layout get layout => _layout;

  set layout(Layout value) {
    _layout = value;
    update(['content']);
  }

  MainController({
    required this.onThemeChange,
  }) {
    _sort();
  }

  bool get darkMode => Data.darkTheme;

  set darkMode(bool value) {
    Data.darkTheme = value;
    onThemeChange(Data.darkTheme);
  }

  bool get sideBarExpand => _sideBarExpand;

  set sideBarExpand(bool value) {
    _sideBarExpand = value;
    update(['sideBar']);
  }

  List<SteamProfile> get accounts => _accounts;

  void addAccount(SteamProfile a) {
    _accounts.add(a);
    _sort();
    Data.accounts
      ..clear()
      ..addAll(_accounts);
    update(['sideBar']);
  }

  void removeAccount(SteamProfile a) {
    _accounts.remove(a);
    selected.remove(a);
    _sort();
    Data.accounts
      ..clear()
      ..addAll(_accounts);
    update(['sideBar', 'content']);
  }

  void _sort() {
    _accounts.sort((a, b) {
      var a1 = a.mine ? 0 : 1;
      var b1 = b.mine ? 0 : 1;
      return a1.compareTo(b1);
    });
  }
}
