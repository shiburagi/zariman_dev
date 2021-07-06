import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:me/me.dart';
import 'package:personal_website/main.dart';
import 'package:personal_website/smooth_scroll.dart';
import 'package:routes/routes.dart';
import 'package:showcase/showcase.dart';
import 'package:utils/utils.dart';

double pagesPadding(BuildContext context) {
  return context.isMd
      ? 160
      : context.isXs
          ? 60
          : 80;
}

final List<WidgetBuilder> _pages = [
  (context) => Container(
        padding: EdgeInsets.only(
            top: pagesPadding(context), bottom: pagesPadding(context)),
        alignment: Alignment.center,
        child: MeView(),
      ),
  (context) => Container(
        padding: EdgeInsets.only(
          top: pagesPadding(context),
        ),
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
  final List<GlobalKey> keys = [];

  late final Animation<double> animation1;
  late final Animation<double> animation2;
  late final Animation<double> animation3;
  double meHeight = 0;

  double get _meHeight {
    final obj = keys[0].currentContext?.findRenderObject();
    RenderBox? box = obj == null ? null : obj as RenderBox;

    return box?.size.height ?? meHeight;
  }

  @override
  void initState() {
    super.initState();

    keys.add(GlobalKey());
    keys.add(GlobalKey());

    bool isAnimated = false;
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      upperBound: 1,
    );

    animation1 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: animationController, curve: Interval(0.6, 0.8)));
    animation2 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: animationController, curve: Interval(0.0, 0.5)));
    animation3 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.0, 1.0),
    ));
    scrollController.addListener(() {
      meHeight = _meHeight;

      double percent = scrollController.offset / height;
      animationController.value = (percent);

      if (!isAnimated) if (percent < 0.8) {
        widget.controller.currentRoute = RoutePath.me;
      } else {
        widget.controller.currentRoute = RoutePath.showcase;
      }
    });

    widget.controller.onChanged = (value) async {
      isAnimated = true;
      await scrollController.animateTo(value == RoutePath.me ? 0 : _meHeight,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
      isAnimated = false;
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  double get sectionFontSize => context.isMd
      ? 120
      : context.isXs
          ? 60
          : 80;
  double get animation1Value => animation1.value;
  double get height => meHeight;
  double get width => MediaQuery.of(context).size.width;

  List<Color> progressColor = [
    Colors.red.shade700,
    Colors.orange,
    Colors.yellow,
    Colors.green
  ];
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          buildBackground(),
          buildLoader(),
          buildHelloTitle(),
          buildShowcaseTitle(),
          buildMainBody(width),
          buildUpButton(),
        ],
      ),
    );
  }

  AnimatedBuilder buildUpButton() {
    return AnimatedBuilder(
        animation: animation3,
        builder: (context, child) {
          double curveValue = Curves.easeInOut.transform(animation2.value);
          return Positioned(
            // left: context.isXs ? null : 0,
            right: 0,
            bottom: 0 + height * curveValue, //+ width * curveValue * 0.2,
            child: Center(
              child: IgnorePointer(
                ignoring: animation3.value > 0.2,
                child: Opacity(
                  opacity: (1 - curveValue * 2).clamp(0, 1),
                  child: InkWell(
                    onTap: () =>
                        widget.controller.currentRoute = RoutePath.showcase,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor.withOpacity(0.1),
                          border: Border(
                            top: BorderSide(color: Theme.of(context).hintColor),
                            left: BorderSide(
                                color:
                                    Theme.of(context).hintColor.withOpacity(1)),
                          )),
                      child: Icon(
                        Icons.expand_less,
                        size: context.isXs ? 40 : 48,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  AnimatedBuilder buildShowcaseTitle() {
    return AnimatedBuilder(
        animation: animation3,
        builder: (context, child) {
          double curveValue = Curves.easeInOut.transform(animation3.value);
          return Positioned(
            left: 0,
            right: 32, //+ width * curveValue * 0.2,
            top: -height + 4 + (curveValue).clamp(0, 1) * height,
            child: Opacity(
              opacity: (curveValue * 2).clamp(0, 1),
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: "_Show\n".toUpperCase(),
                  ),
                  TextSpan(
                      text: "#case".toUpperCase(),
                      style: TextStyle(color: Theme.of(context).hintColor)),
                ]),
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: sectionFontSize, height: 1),
              ),
            ),
          );
        });
  }

  AnimatedBuilder buildHelloTitle() {
    return AnimatedBuilder(
        animation: animation3,
        builder: (context, child) {
          double curveValue = Curves.easeInOut.transform(animation3.value);
          return Positioned(
            right: 32, // + width * curveValue * 0.2,
            top: -(context.isMd
                    ? 108
                    : context.isXs
                        ? 55
                        : 75) +
                curveValue * height,
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
        });
  }

  AnimatedBuilder buildLoader() {
    return AnimatedBuilder(
        animation: animation3,
        builder: (context, child) {
          double curveValue = Curves.easeInOut.transform(animation2.value);
          return Positioned(
            left: 32,
            right: 32,
            bottom: 0,
            top: 0,
            child: Opacity(
              opacity: curveValue == 0 ? 0 : 1 - animation1Value,
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.height / 2,
                margin: EdgeInsets.only(bottom: animation1Value * 60),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: max(
                        min(MediaQuery.of(context).size.height,
                                MediaQuery.of(context).size.width) *
                            0.7,
                        500),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(
                            child: CircularProgressIndicator(
                              value: curveValue,
                              strokeWidth: 1,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            curveValue >= 1
                                ? "Completed".toUpperCase()
                                : "${(curveValue * 100).clamp(0, 100).toStringAsFixed(1)}%",
                            style: context.isMd
                                ? Theme.of(context).textTheme.headline2
                                : Theme.of(context).textTheme.headline4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget buildBackground() {
    return AnimatedBuilder(
        animation: animation3,
        builder: (context, child) {
          final value =
              Curves.easeInOut.transform((animation2.value).clamp(0, 1));
          final value1 =
              Curves.fastOutSlowIn.transform((animation3.value).clamp(0, 1));
          return Positioned.fill(
            top: height - height * value1,
            bottom: -height + height * value1,
            child: Container(
              color: Color(0xffC0392B).withOpacity(
                value,
              ),
            ),
          );
        });
  }

  List<Widget Function(BuildContext, WidgetBuilder)> get childAnimation => [
        (context, builder) {
          return AnimatedBuilder(
            animation: animation3,
            builder: (context, child) {
              double dx =
                  (-Curves.fastOutSlowIn.transform(animation3.value) * width)
                      .clamp(-width, 0.0);

              double dy = animation3.value * meHeight;
              if (meHeight - pagesPadding(context) >
                  MediaQuery.of(context).size.height) {
                dx = 0;
                dy = 0;
              }
              return Transform.translate(
                offset: Offset(dx, dy),
                child: builder(context),
              );
            },
          );
        },
        (context, builder) => builder(context),
      ];

  Widget buildMainBody(double width) {
    return SmoothScrollWeb(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        itemBuilder: (context, index) {
          return childAnimation[index](
            context,
            (context) => ConstrainedBox(
              key: keys[index],
              constraints:
                  BoxConstraints(minHeight: MediaQuery.of(context).size.height),
              child: _pages[index](context),
            ),
          );
        },
        itemCount: _pages.length,
      ),
    );
  }
}

class LinearProgress extends StatelessWidget {
  const LinearProgress({Key? key, required this.value}) : super(key: key);

  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: Theme.of(context).hintColor.withOpacity(0.01),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                BorderSide(color: Theme.of(context).hintColor.withOpacity(0))),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Transform(
            transform: Matrix4.diagonal3Values(value.clamp(0, 1), 1.0, 1.0),
            child: Container(
              height: 8,
              color: Theme.of(context).hintColor.withOpacity(1),
            ),
          ),
        ),
      ),
    );
  }
}
