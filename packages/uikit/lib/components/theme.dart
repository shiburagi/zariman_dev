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

const dotColor = Color(0XFFFA8072);
const lineColor = Color(0xFFFFE4E1);
const defaultShowcaseButtonColor = Color(0XFFFA8072);
const showcaseBackgroundColor = Color(0xffC0392B);
const experienceBackgroundColor = Color(0xFFD2691E);
