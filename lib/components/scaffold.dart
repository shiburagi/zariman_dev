import 'package:flutter/material.dart';
import 'package:personal_website/views/app.dart';
import 'package:personal_website/views/menu.dart';
import 'package:routes/routes.dart';
import 'package:utils/utils.dart';
import 'package:uikit/uikit.dart';

class ParallaxScaffold extends StatefulWidget {
  const ParallaxScaffold(
      {Key? key,
      required this.menuController,
      required this.scrollController,
      required this.pages,
      this.snapOnFirstPage = true})
      : super(key: key);

  final CardMenuController menuController;
  final List<AppPageData> pages;
  final ScrollController scrollController;
  final bool snapOnFirstPage;

  @override
  State<ParallaxScaffold> createState() => _ParallaxScaffoldState();
}

class _ParallaxScaffoldState extends State<ParallaxScaffold> {
  List<AppPageData> get pages => widget.pages;
  ScrollController get scrollController => widget.scrollController;

  @override
  void initState() {
    super.initState();

    initScrollListener();
    final urlPath = locationPath;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(Duration(milliseconds: 300), () {
        var page = pages.firstWhere(
          (element) => urlPath?.endsWith(element.path) == true,
          orElse: () => pages[0],
        );
        widget.menuController.currentRoute = page.path;
      });
    });
  }

  bool isAnimated = false;

  void initScrollListener() {
    widget.menuController.onChanged = (value) async {
      updateLocation(value);
      isAnimated = true;
      final page = pages.firstWhere(
        (element) => element.path == value,
      );
      final position = getPositionIndex(page.key);

      await scrollController.animateTo(
          value == RoutePath.me ? 0 : scrollController.offset + (position ?? 0),
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut);
      isAnimated = false;
    };
  }

  double firstItemHeight = 0;
  void scrollObserver(keys, offset, isStop) {
    firstItemHeight = getHeight(keys[0]) ?? firstItemHeight;

    if (isStop) {
      final pages = this.pages;
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
      if (widget.snapOnFirstPage) if (!isAnimated &&
          offset <= firstItemHeight) {
        final currentRoute = widget.menuController.currentRoute;

        Future(() async => {
              await scrollController.animateTo(
                  currentRoute == RoutePath.me ? 0 : firstItemHeight,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut)
            }).then((value) => {isAnimated = false});
      }
    }
  }

  void updater(e) {
    if (!isAnimated) widget.menuController.currentRoute = e;
  }

  @override
  Widget build(BuildContext context) {
    return AppPager(
        pages: pages,
        scrollController: scrollController,
        updater: updater,
        observer: scrollObserver);
  }
}
