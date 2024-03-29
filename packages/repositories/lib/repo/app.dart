import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:repositories/models/experience.dart';
import 'package:repositories/models/me.dart';
import 'package:repositories/models/showcase.dart';

class AppRepo {
  static final AppRepo instance = AppRepo._();
  Me? me;
  List<Showcase>? showcases;
  List<Experience>? experiences;
  AppRepo._();

  Future<Me> getMe() async {
    if (me != null) return me!;
    final data = await rootBundle.loadString('assets/data/me.json');

    try {
      final json = jsonDecode(data);
      return me = Me.fromJson(json);
    } catch (e) {
      return Me();
    }
  }

  Future<List<Showcase>> getShowcases() async {
    if (showcases != null) return showcases!;

    final data = await rootBundle.loadString('assets/data/showcase.json');
    try {
      final json = jsonDecode(data);
      return showcases = List<Map<String, dynamic>>.from(json)
          .map((e) => Showcase.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Experience>> getExperience() async {
    if (experiences != null) return experiences!;

    final data = await rootBundle.loadString('assets/data/experience.json');
    try {
      final json = jsonDecode(data);
      return experiences = List<Map<String, dynamic>>.from(json)
          .map((e) => Experience.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
