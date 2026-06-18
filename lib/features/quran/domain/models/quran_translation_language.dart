enum QuranTranslationLanguage {
  enSaheeh,
  enClearQuran,
  urdu,
  french,
  turkish,
  indonesian,
}

extension QuranTranslationLanguageText on QuranTranslationLanguage {
  String get label {
    switch (this) {
      case QuranTranslationLanguage.enSaheeh:
        return 'English (Saheeh)';
      case QuranTranslationLanguage.enClearQuran:
        return 'English (Clear Quran)';
      case QuranTranslationLanguage.urdu:
        return 'Urdu';
      case QuranTranslationLanguage.french:
        return 'French';
      case QuranTranslationLanguage.turkish:
        return 'Turkish';
      case QuranTranslationLanguage.indonesian:
        return 'Indonesian';
    }
  }
}
