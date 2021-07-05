import 'package:flutter/material.dart';

class Breakpoints {
  static double md = 800;
  static double sm = 560;

  static bool isMd(double width) {
    return width >= md;
  }

  static bool isSm(double width) {
    return width >= sm;
  }

  static bool isXs(double width) {
    return width < sm;
  }
}

extension BoxConstraintsBreakpointExt on BoxConstraints {
  bool get isMd => Breakpoints.isMd(this.maxWidth);
  bool get isSm => Breakpoints.isSm(this.maxWidth);
  bool get isXs => Breakpoints.isXs(this.maxWidth);
}

extension SizeBreakpointExt on Size {
  bool get isMd => Breakpoints.isMd(width);
  bool get isSm => Breakpoints.isSm(width);
  bool get isXs => Breakpoints.isXs(width);
}

extension BuildContextBreakpointExt on BuildContext {
  bool get isMd => MediaQuery.of(this).size.isMd;
  bool get isSm => MediaQuery.of(this).size.isSm;
  bool get isXs => MediaQuery.of(this).size.isXs;
}
