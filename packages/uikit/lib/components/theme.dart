import 'package:flutter/material.dart';

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
