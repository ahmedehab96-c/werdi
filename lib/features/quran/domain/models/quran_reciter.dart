enum QuranReciter {
  alafasy,
  husary,
  ahmedAjamy,
  hudhaify,
  maherMuaiqly,
  sudais,
  alzainMohammedAhmed,
  nureenMohamedSiddiq,
  muhammadAyyoub,
  muhammadJibreel,
  minshawi,
  shaatree,
}

extension QuranReciterText on QuranReciter {
  String get label {
    switch (this) {
      case QuranReciter.alafasy:
        return 'العفاسي';
      case QuranReciter.husary:
        return 'الحصري';
      case QuranReciter.ahmedAjamy:
        return 'أحمد العجمي';
      case QuranReciter.hudhaify:
        return 'الحذيفي';
      case QuranReciter.maherMuaiqly:
        return 'ماهر المعيقلي';
      case QuranReciter.sudais:
        return 'السديس';
      case QuranReciter.alzainMohammedAhmed:
        return 'الزين محمد أحمد';
      case QuranReciter.nureenMohamedSiddiq:
        return 'نورين محمد صديق';
      case QuranReciter.muhammadAyyoub:
        return 'محمد أيوب';
      case QuranReciter.muhammadJibreel:
        return 'محمد جبريل';
      case QuranReciter.minshawi:
        return 'المنشاوي';
      case QuranReciter.shaatree:
        return 'أبو بكر الشاطري';
    }
  }
}
