import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:repositories/models/me.dart';
import 'package:repositories/models/showcase.dart';

class AppRepo {
  static final AppRepo instance = AppRepo._();

  AppRepo._();

  Future<Me> getMe() async {
    final data = await rootBundle.loadString('data/me.json');
    try {
      final json = jsonDecode(data);
      return Me.fromJson(json);
    } catch (e) {
      return Me();
    }
  }

  Future<List<Showcase>> getShowcases() async {
    final data = await rootBundle.loadString('data/showcase.json');
    try {
      final json = jsonDecode(data);
      return List<Map<String, dynamic>>.from(json)
          .map((e) => Showcase.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
