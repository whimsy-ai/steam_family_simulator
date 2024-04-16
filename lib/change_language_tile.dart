import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui/ui.dart';

import 'data.dart';
import 'update_window_title.dart';

class ChangeLanguageTile extends StatelessWidget {
  final RxString _lang = Data.locale.toLanguageTag().obs;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(UI.change_language.tr),
      trailing: Obx(
        () => DropdownButton<String>(
          value: _lang.value,
          items: UI.languages.keys
              .map(
                (key) => DropdownMenuItem(
                  value: key,
                  child: Text(UI.languages[key]!),
                ),
              )
              .toList(),
          onChanged: (v) {
            _lang.value = v!;
            Data.locale = Locale(v);
            Get.updateLocale(Data.locale);
            updateWindowTitle();
          },
        ),
      ),
    );
  }
}
