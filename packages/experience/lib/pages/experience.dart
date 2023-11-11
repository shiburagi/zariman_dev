import 'package:experience/views/experience.dart';
import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

class ExperiencePage extends StatefulWidget {
  ExperiencePage({Key? key}) : super(key: key);

  @override
  _ExperiencePageState createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<ExperiencePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffCD5C5C),
      body: Theme(
        data: darkTheme,
        child: SingleChildScrollView(
          child: ExperienceView(),
        ),
      ),
    );
  }
}
