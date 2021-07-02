import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:localize/generated/l10n.dart';
import 'package:showcase/views/showcase.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowcasePage extends StatefulWidget {
  ShowcasePage({Key? key}) : super(key: key);

  @override
  _ShowcasePageState createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffCD5C5C),
      body: SingleChildScrollView(
        child: ShowcaseView(),
      ),
    );
  }
}
