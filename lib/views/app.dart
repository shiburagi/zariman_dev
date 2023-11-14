import 'package:experience/experience.dart' as experienceClass;
import 'package:flutter/material.dart';
import 'package:me/me.dart' as meClass;
import 'package:personal_website/views/menu.dart';
import 'package:repositories/repositories.dart';
import 'package:routes/routes.dart';
import 'package:showcase/showcase.dart' as showcaseClass;
import 'package:uikit/uikit.dart';
import 'package:utils/utils.dart';

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

class AppPage extends StatefulWidget {
  const AppPage({Key? key, required this.controller}) : super(key: key);
  final CardMenuController controller;

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();

  double meHeight = 0;
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      upperBound: 1,
    );
    initScrollListener();
    final urlPath = locationPath;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 300), () {
        var page = pages?.firstWhere(
          (element) => urlPath?.endsWith(element.path) == true,
          orElse: () => pages![0],
        );
        widget.controller.currentRoute = page?.path ?? RoutePath.me;
      });
    });
  }

  bool isAnimated = false;

  void initScrollListener() {
    widget.controller.onChanged = (value) async {
      updateLocation(value);
      isAnimated = true;
      final page = pages?.firstWhere(
        (element) => element.path == value,
      );
      if (page == null) return;
      final position = getPositionIndex(page.key);

      await scrollController.animateTo(
          value == RoutePath.me ? 0 : scrollController.offset + (position ?? 0),
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut);
      isAnimated = false;
    };
  }

  void scrollObserver(keys, offset, isStop) {
    meHeight = getHeight(keys[0]) ?? meHeight;

    if (isStop) {
      final currentRoute = widget.controller.currentRoute;
      final pages = this.pages;
      if (pages != null)
        for (var i = pages.length - 1; i > -0; i--) {
          final page = pages[i];
          final y = getPositionIndex(page.key) ?? 0;
          if (!isAnimated && y > 0 && y < sectionFontSize(context) * 3) {
            Future(() async => {
                  await scrollController.animateTo(y + offset,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut)
                }).then((value) => {isAnimated = false});
            return;
          }
        }
      if (!isAnimated && offset <= meHeight) {
        Future(() async => {
              await scrollController.animateTo(
                  currentRoute == RoutePath.me ? 0 : meHeight,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut)
            }).then((value) => {isAnimated = false});
      }
    } else {
      double percent = offset / meHeight;
      animationController.value = (percent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        buildMainBody(width),
        meClass.UpButton(
            observerKey: pages![0].key,
            scrollController: scrollController,
            onUpClicked: (e) {
              widget.controller.currentRoute = e;
            })
      ],
    );
  }

  List<AppPageData>? pages;
  Widget buildMainBody(double width) {
    pages ??= [
      meClass.buildMePageData(),
      showcaseClass.buildShowcasePageData(),
      experienceClass.buillExperiencePageData()
    ];
    return AppPager(
      scrollController: scrollController,
      updater: (p0) {
        if (!isAnimated) widget.controller.currentRoute = p0;
      },
      pages: pages ?? [],
      observer: scrollObserver,
    );
  }
}
