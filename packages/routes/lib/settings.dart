import 'package:flutter/material.dart';

// Wrapper untuk kawalan laluan/muka surat
abstract class RouteControl {
  Map<String, bool?> get access;
  Page? createPage(AppRouteSettings configuration);
}

// Model untuk tetapan laluan
@immutable
class AppRouteSettings {
  const AppRouteSettings({
    this.name,
    this.arguments,
  });
  AppRouteSettings copyWith({
    String? name,
    Object? arguments,
  }) {
    return AppRouteSettings(
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
    );
  }

  final String? name;
  final Object? arguments;
}
