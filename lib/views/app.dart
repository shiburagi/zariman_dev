import 'package:experience/experience.dart' as experienceClass;
import 'package:flutter/material.dart';
import 'package:me/me.dart' as meClass;
import 'package:personal_website/components/scaffold.dart';
import 'package:personal_website/views/menu.dart';
import 'package:repositories/repositories.dart';
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

  List<AppPageData> pages = [
    meClass.buildMePageData(),
    showcaseClass.buildShowcasePageData(),
    experienceClass.buillExperiencePageData()
  ];

  Widget buildMainBody(double width) {
    return ParallaxScaffold(
      menuController: widget.controller,
      scrollController: scrollController,
      pages: pages,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        buildMainBody(width),
        meClass.UpButton(
            observerKey: pages[0].key,
            scrollController: scrollController,
            onUpClicked: (e) {
              widget.controller.currentRoute = e;
            })
      ],
    );
  }
}
