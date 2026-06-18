import 'package:flutter/material.dart';

final class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> softLight = [
    BoxShadow(color: Color(0x14081510), blurRadius: 16, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x0A081510), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> softDark = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 20, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x29000000), blurRadius: 8, offset: Offset(0, 3)),
  ];

  static List<BoxShadow> byBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? softDark : softLight;
  }
}
