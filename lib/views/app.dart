import 'package:experience/experience.dart' as experienceClass;
import 'package:flutter/material.dart';
import 'package:me/me.dart' as meClass;
import 'package:personal_website/views/menu.dart';
import 'package:repositories/repositories.dart';
import 'package:routes/routes.dart';
import 'package:showcase/showcase.dart' as showcaseClass;
import 'package:uikit/uikit.dart';

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
  }

  bool isAnimated = false;

  void initScrollListener() {
    widget.controller.onChanged = (value) async {
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final body = buildMainBody(width);
    return Stack(
      children: [
        body,
      ],
    );
  }

  List<AppPageData>? pages;

  Widget buildMainBody(double width) {
    pages ??= [
      meClass.MeAppPage.create(animationController, (p0) {
        widget.controller.currentRoute = p0;
      }).build(),
      showcaseClass.buildShowcasePageData(),
      experienceClass.buillExperiencePageData()
    ];
    return AppPager(
      scrollController: scrollController,
      updater: (p0) {
        if (!isAnimated) widget.controller.currentRoute = p0;
      },
      pages: pages ?? [],
      observer: (keys, offset) {
        meHeight = getHeight(keys[0]) ?? meHeight;
        double percent = offset / meHeight;
        animationController.value = (percent);
      },
    );
  }
}
