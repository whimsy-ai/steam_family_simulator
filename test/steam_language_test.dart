import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/locale_to_steam_languages.dart';

void main() {
  testWidgets('Steam languages test', (WidgetTester tester) async {
    expect(localeToSteamLanguages(Locale('en', 'US')), 'english');
    expect(localeToSteamLanguages(Locale('zh', 'CN')), 'schinese');
    expect(localeToSteamLanguages(Locale('zh', 'TW')), 'tchinese');
    expect(localeToSteamLanguages(Locale('ja', 'TW')), 'japanese');
    expect(localeToSteamLanguages(Locale('ko', 'TW')), 'korean');
  });
}
