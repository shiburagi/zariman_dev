import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localize/generated/l10n.dart';
import 'package:personal_website/views/app.dart' deferred as appClass;
import 'package:personal_website/views/menu.dart';
import 'package:routes/routes.dart';

class Splashpage extends StatefulWidget {
  Splashpage({Key? key, required this.controller}) : super(key: key);
  final CardMenuController controller;

  @override
  _SplashpageState createState() => _SplashpageState();
}

class _SplashpageState extends State<Splashpage> {
  _loadClass() async {
    try {
      await appClass.loadLibrary();
      await appClass.loadDependentLibrary(context);
    } catch (e) {}
    return true;
  }

  final menu = {
    RoutePath.me: AppMenuItem(S.current.me, FontAwesomeIcons.faceMehBlank),
    RoutePath.showcase:
        AppMenuItem(S.current.showcase, FontAwesomeIcons.desktop),
    RoutePath.experience:
        AppMenuItem(S.current.experience, FontAwesomeIcons.briefcase),
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _loadClass(),
        builder: (context, snapshot) {
          final isLoad = snapshot.data == null;

          print("$isLoad  ${snapshot.data}");
          return Stack(
            children: [
              isLoad
                  ? Center()
                  : appClass.AppPage(
                      controller: widget.controller,
                    ),
              isLoad
                  ? Center()
                  : Positioned(
                      left: 8,
                      top: 8,
                      child: CardMenu(
                        menu: menu,
                        controller: widget.controller,
                      ),
                    ),
              Positioned.fill(
                child: LoadScreen(isLoad: isLoad),
              )
            ],
          );
        },
      ),
    );
  }
}

class LoadScreen extends StatefulWidget {
  const LoadScreen({
    Key? key,
    required this.isLoad,
  }) : super(key: key);

  final bool isLoad;

  @override
  _LoadScreenState createState() => _LoadScreenState();
}

class _LoadScreenState extends State<LoadScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LoadScreen oldWidget) {
    if (oldWidget.isLoad != widget.isLoad) {
      if (widget.isLoad)
        _controller.reverse();
      else
        _controller.forward();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Opacity(
        opacity: 1.0 - _controller.value,
        child: Visibility(
          visible: _controller.value < 1,
          child: Container(
            color: Theme.of(context).canvasColor,
            child: Center(
              child: SizedBox(
                width: min(MediaQuery.of(context).size.width,
                        MediaQuery.of(context).size.height) *
                    0.5,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Visibility(
                    visible: widget.isLoad,
                    child: CircularProgressIndicator(
                      strokeWidth: 0.5,
                      color: Theme.of(context).hintColor.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
