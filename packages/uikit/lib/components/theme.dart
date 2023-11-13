import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

final theme = ThemeData(
  fontFamily: "Barlow",
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green, brightness: Brightness.light)
      .copyWith(secondary: Color(0xffE74C3C)),
);
final darkTheme = ThemeData(
  fontFamily: "Barlow",
  brightness: Brightness.dark,
  canvasColor: Colors.black,
  cardColor: Colors.blueGrey.shade900,
  colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green, brightness: Brightness.dark)
      .copyWith(secondary: Color(0xffE74C3C)),
);

double pagesPadding(BuildContext context) {
  return context.isMd
      ? 160
      : context.isXs
          ? 60
          : 80;
}

double sectionFontSize(BuildContext context) => context.isMd
    ? 120
    : context.isXs
        ? 48
        : 80;
