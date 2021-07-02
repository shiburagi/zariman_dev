import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:me/me.dart';
import 'package:personal_website/main.dart';
import 'package:routes/routes.dart';
import 'package:showcase/showcase.dart';
import 'package:utils/utils.dart';

final List<WidgetBuilder> _pages = [
  (context) => Container(
        padding: EdgeInsets.only(top: 160, bottom: 160),
        alignment: Alignment.center,
        child: MeView(),
      ),
  (context) => Container(
        padding: EdgeInsets.only(top: 160),
        child: ShowcaseView(),
      ),
];

class AppPage extends StatefulWidget {
  const AppPage({Key? key, required this.controller}) : super(key: key);
  final CardMenuController controller;

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  late final AnimationController animationController;
  final List<AnimationController> animations = [];
  @override
  void initState() {
    super.initState();

    bool isAnimated = false;
    animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200),
        upperBound: double.maxFinite);
    animations.add(
      AnimationController(
          vsync: this, duration: Duration(milliseconds: 200), upperBound: 1),
    );
    animations.add(
      AnimationController(
          vsync: this, duration: Duration(milliseconds: 200), upperBound: 1),
    );
    scrollController.addListener(() {
      final height = MediaQuery.of(context).size.height;
      double percent = scrollController.offset / height;
      animationController.value = percent;
      animations[0].value = percent.clamp(0.0, 1.0);
      animations[1].value = percent.clamp(0, 0);
      if (!isAnimated) if (percent < 1) {
        widget.controller.currentRoute = RoutePath.me;
      } else {
        widget.controller.currentRoute = RoutePath.showcase;
      }
    });

    widget.controller.onChanged = (value) async {
      isAnimated = true;
      await scrollController.animateTo(
          value == RoutePath.me ? 0 : MediaQuery.of(context).size.height,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut);
      isAnimated = false;
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  double get sectionFontSize => context.isMd ? 120 : 80;
  List<Color> progressColor = [
    Colors.red.shade700,
    Colors.orange,
    Colors.yellow,
    Colors.green
  ];
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: AnimatedBuilder(
            animation: animations[0],
            builder: (context, child) => Container(
              color: Color(0xffC0392B).withOpacity(animations[0].value),
            ),
          )),
          AnimatedBuilder(
              animation: animations[0],
              builder: (context, child) {
                double curveValue =
                    Curves.easeInOut.transform(animations[0].value);
                return Positioned(
                  left: -60 - width * curveValue * 2,
                  bottom: -150 - curveValue * height * 2,
                  child: Opacity(
                    opacity: (1 - curveValue * 2).clamp(0, 1),
                    child: Image.network(
                      "https://cdn3.iconfinder.com/data/icons/ink-social-media/35/android-512.png",
                      color: Colors.white12,
                    ),
                  ),
                );
              }),
          AnimatedBuilder(
              animation: animations[0],
              builder: (context, child) {
                double curveValue =
                    Curves.easeInOut.transform(animations[0].value);
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: 0,
                  child: Opacity(
                    opacity: curveValue < 0.6
                        ? 1
                        : (1 - (curveValue - 0.6) * 4).clamp(0, 1),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Card(
                            elevation: 0,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                    color: Theme.of(context)
                                        .hintColor
                                        .withOpacity(1))),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 400),
                              child: Transform(
                                transform: Matrix4.diagonal3Values(
                                    (curveValue * 2).clamp(0, 1), 1.0, 1.0),
                                child: Container(
                                  height: 16,
                                  color: progressColor[
                                      (curveValue * 2 * progressColor.length)
                                          .floor()
                                          .clamp(0, progressColor.length - 1)],
                                ),
                              ),
                            ),
                          ),
                          Text(
                            curveValue >= 0.5
                                ? "Completed".toUpperCase()
                                : "${(curveValue * 200).clamp(0, 100).toStringAsFixed(1)}%",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          AnimatedBuilder(
              animation: animations[0],
              builder: (context, child) {
                double curveValue =
                    Curves.easeInOut.transform(animations[0].value);
                return Positioned(
                  right: 32, // + width * curveValue * 0.2,
                  top: -108 + curveValue * height,
                  child: Opacity(
                    opacity: (1 - curveValue * 2).clamp(0, 1),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: "World!:\n".toUpperCase(),
                          style: TextStyle(color: Theme.of(context).hintColor),
                        ),
                        TextSpan(
                          text: "_Hello".toUpperCase(),
                        ),
                      ]),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: sectionFontSize, height: 1),
                    ),
                  ),
                );
              }),
          AnimatedBuilder(
              animation: animations[0],
              builder: (context, child) {
                double curveValue =
                    Curves.easeInOut.transform(animations[0].value);
                return Positioned(
                  left: 0,
                  right: 32, //+ width * curveValue * 0.2,
                  top: -height + 24 + (curveValue * 1).clamp(0, 1) * height,
                  child: Opacity(
                    opacity: (curveValue * 2).clamp(0, 1),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: "_Show\n".toUpperCase(),
                        ),
                        TextSpan(
                            text: "#case".toUpperCase(),
                            style:
                                TextStyle(color: Theme.of(context).hintColor)),
                      ]),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: sectionFontSize, height: 1),
                    ),
                  ),
                );
              }),
          ListView.builder(
            controller: scrollController,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: animations[index],
                builder: (context, child) => Transform.translate(
                  offset: Offset(-animations[index].value * width,
                      animations[index].value * height),
                  child: Opacity(
                    opacity: 1, // - animations[index].value,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height),
                      child: _pages[index](context),
                    ),
                  ),
                ),
              );
            },
            itemCount: _pages.length,
          ),
          AnimatedBuilder(
              animation: animations[0],
              builder: (context, child) {
                double curveValue =
                    Curves.easeInOut.transform(animations[0].value);
                return Positioned(
                  left: 0,
                  right: 0,
                  bottom:
                      24 + height * curveValue, //+ width * curveValue * 0.2,
                  child: Center(
                    child: IgnorePointer(
                      ignoring: animations[0].value > 0.2,
                      child: Opacity(
                        opacity: (1 - curveValue * 2).clamp(0, 1),
                        child: InkWell(
                          onTap: () => widget.controller.currentRoute =
                              RoutePath.showcase,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border(
                              top: BorderSide(
                                  color: Theme.of(context).hintColor),
                              left: BorderSide(
                                  color: Theme.of(context)
                                      .hintColor
                                      .withOpacity(0.1)),
                            )),
                            child: Icon(
                              Icons.expand_less,
                              size: 60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
