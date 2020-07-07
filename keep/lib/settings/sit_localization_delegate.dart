import 'dart:async';

import 'package:flutter/material.dart';

import 'sit_localization.dart';

class SitLocalizationsDelegate extends LocalizationsDelegate<SitLocalizations> {
  const SitLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['zh', 'en'].contains(locale.languageCode);

  @override
  Future<SitLocalizations> load(Locale locale) => SitLocalizations.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<SitLocalizations> old) => false;
}