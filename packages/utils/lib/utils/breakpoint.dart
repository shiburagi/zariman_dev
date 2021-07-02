import 'package:flutter/material.dart';

class Breakpoints {
  static double md = 800;

  static bool isMd(double width) {
    return width >= md;
  }
}

extension BoxConstraintsBreakpointExt on BoxConstraints {
  bool get isMd => Breakpoints.isMd(this.maxWidth);
}

extension SizeBreakpointExt on Size {
  bool get isMd => Breakpoints.isMd(width);
}

extension BuildContextBreakpointExt on BuildContext {
  bool get isMd => MediaQuery.of(this).size.isMd;
}
