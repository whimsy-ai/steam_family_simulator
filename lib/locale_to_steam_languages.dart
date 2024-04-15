import 'dart:ui';

const _steamLanguages = {
  'arabic': 'ar',
  'bulgarian': 'bg',
  'schinese': 'zh-CN',
  'tchinese': 'zh-TW',
  'czech': 'cs',
  'danish': 'da',
  'dutch': 'nl',
  'english': 'en',
  'finnish': 'fi',
  'french': 'fr',
  'german': 'de',
  'greek': 'el',
  'hungarian': 'hu',
  'indonesian': 'id',
  'italian': 'it',
  'japanese': 'ja',
  'korean': 'ko',
  'norwegian': 'no',
  'polish': 'pl',
  'portuguese': 'pt',
  'brazilian': 'pt-BR',
  'romanian': 'ro',
  'russian': 'ru',
  'spanish': 'es',
  'latam': 'es-419',
  'swedish': 'sv',
  'thai': 'th',
  'turkish': 'tr',
  'ukrainian': 'uk',
  'vietnamese': 'vn'
};

const _tchineseList = ['TW', 'HK', 'MO'];

String localeToSteamLanguages(Locale locale) {
  /// 区分简繁
  if (locale.languageCode == 'zh') {
    if (_tchineseList.contains(locale.countryCode)) {
      return 'tchinese';
    }
    return 'schinese';
  } else if (locale.languageCode == 'en') {
    return 'english';
  } else {
    final v = _steamLanguages.values.toList();
    final index = v.indexOf(locale.languageCode);
    if (index != 0) {
      return _steamLanguages.keys.elementAt(index);
    }
  }

  /// 兜底
  return 'english';
}
