import 'package:experience/experience.dart' as experienceClass;
import 'package:flutter/material.dart';
import 'package:me/me.dart' as meClass;
import 'package:personal_website/views/menu.dart';
import 'package:repositories/repositories.dart';
import 'package:routes/routes.dart';
import 'package:showcase/showcase.dart' as showcaseClass;
import 'package:utils/utils.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';

import '../components/background.dart';
import '../components/loader.dart';

Future loadDependentLibrary(BuildContext context) async {
  // await meClass.loadLibrary();
  // await showcaseClass.loadLibrary();
  Me me = await AppRepo.instance.getMe();
  await AppRepo.instance.getShowcases();

  if (me.image == null)
    await precacheImage(AssetImage(meClass.kDefaultProfileImage), context);
  else
    await precacheImage(NetworkImage(me.image!), context);
}

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
        child: meClass.MeView(me: AppRepo.instance.me!),
      ),
  (context) => Container(
        padding: EdgeInsets.only(
          top: pagesPadding(context),
        ),
        child: showcaseClass.ShowcaseView(),
      ),
  (context) => Container(
        padding: EdgeInsets.only(
          top: pagesPadding(context),
        ),
        child: experienceClass.ExperienceView(),
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

  GlobalKey meKey = GlobalKey();
  GlobalKey showcaseKey = GlobalKey();
  GlobalKey experienceKey = GlobalKey();

  List<GlobalKey> get keyMap => [meKey, showcaseKey, experienceKey];

  final List<String> paths = [
    RoutePath.me,
    RoutePath.showcase,
    RoutePath.experience
  ];

  late final Animation<double> animation1;
  late final Animation<double> animation2;
  late final Animation<double> animation3;
  double meHeight = 0;

  double get _meHeight {
    try {
      final obj = keyMap[0].currentContext?.findRenderObject();
      RenderBox? box = obj == null ? null : obj as RenderBox;

      return box?.size.height ?? meHeight;
    } catch (e) {
      return meHeight;
    }
  }

  double? getPositionIndex(int index) {
    try {
      final obj = keyMap[index].currentContext?.findRenderObject();

      RenderBox? box = obj == null ? null : obj as RenderBox;
      Offset? position =
          box?.localToGlobal(Offset.zero); //this is global position

      return position?.dy;
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

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

    initScrollListener();
  }

  bool isAnimated = false;

  void initScrollListener() {
    widget.controller.onChanged = (value) async {
      isAnimated = true;
      final index = paths.indexOf(value);
      await scrollController.animateTo(
          value == RoutePath.me
              ? 0
              : scrollController.offset + (getPositionIndex(index) ?? 0),
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut);
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
    final body = buildMainBody(width);
    return Stack(
      children: [
        AppBackground(animation2, animation3, height),
        AppLoader(animation1, animation2, animation3),
        meClass.MeTitle(
            observerKey: meKey,
            sectionFontSize: sectionFontSize,
            animation3: animation3),
        showcaseClass.ShowcaseTitle(
            observerKey: showcaseKey,
            sectionFontSize: sectionFontSize,
            scrollController: scrollController),
        experienceClass.ExperienceTitle(
            observerKey: experienceKey,
            sectionFontSize: sectionFontSize,
            scrollController: scrollController),
        body,
        buildUpButton(),
      ],
    );
  }

  AnimatedBuilder buildUpButton() {
    return AnimatedBuilder(
        animation: animation3,
        builder: (context, child) {
          double curveValue = Curves.easeInOut.transform(animation2.value);
          return Positioned(
            right: 0,
            bottom: 0 + height * curveValue,
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
        (context, builder) => builder(context),
      ];

  Widget buildMainBody(double width) {
    List<Widget> children = List.generate(_pages.length, (index) {
      return childAnimation[index](
        context,
        (context) {
          final child = ConstrainedBox(
            key: keyMap[index],
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: _pages[index](context),
          );
          return child;
        },
      );
    });

    return WebSmoothScroll(
      controller: scrollController,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollStartNotification) {
          } else if (scrollNotification is ScrollUpdateNotification) {
            meHeight = _meHeight;
            double percent = scrollController.offset / height;
            animationController.value = (percent);
            if (!isAnimated) {
              for (var i = keyMap.length - 1; i >= 0; i--) {
                debugPrint(
                    "getPositionIndex($i): ${getPositionIndex(i)} ${scrollController.offset}");

                final path = paths[i];
                final height = MediaQuery.of(context).size.height;
                final offset = getPositionIndex(i);
                if (offset != null && offset < height * 0.4) {
                  widget.controller.currentRoute = path;
                  break;
                }
              }
            }
          } else if (scrollNotification is ScrollEndNotification) {
            // final currentRoute = widget.controller.currentRoute;
            // if (!isAnimated &&
            //     [RoutePath.me, RoutePath.showcase].contains(currentRoute))
            //   Future(() async => {
            //         await scrollController.animateTo(
            //             currentRoute == RoutePath.me ? 0 : _meHeight,
            //             duration: Duration(milliseconds: 500),
            //             curve: Curves.easeInOut)
            //       }).then((value) => {isAnimated = false});
            // isAnimated = true;
          }

          return true;
        },
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(children: children),
        ),
        // child: ListView(controller: scrollController, children: children),
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
