import 'package:flutter/material.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';

class AppPager extends StatefulWidget {
  const AppPager({
    Key? key,
    required this.pages,
    required this.scrollController,
    required this.updater,
    required this.observer,
  }) : super(key: key);

  final List<AppPageData> pages;
  final ScrollController scrollController;
  final RouteUpdater updater;
  final ScrollObserver observer;

  @override
  State<AppPager> createState() => _AppPagerState();
}

class _AppPagerState extends State<AppPager> with TickerProviderStateMixin {
  late final AnimationController animationController;

  final Map<int, GlobalKey> keys = {};

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, upperBound: 1, duration: Duration(milliseconds: 200));
  }

  double? _getPositionIndex(int index) {
    return getPositionIndex(widget.pages[index].key);
  }

  bool isAnimated = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = List.generate(widget.pages.length, (index) {
      final page = widget.pages[index];
      AppPageAnimationBuider childAnimation = page.builder ??
          (context, key, scrollController, b) => page.content(context);
      final key = page.key;
      keys[index] = key;
      return childAnimation(
        context,
        key,
        widget.scrollController,
        (context) {
          final child = ConstrainedBox(
            key: key,
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: page.content(context),
          );
          return child;
        },
      );
    });

    return Stack(
      children: [
        for (int i = 0; i < widget.pages.length; i++)
          ...widget.pages[i].background
                  ?.call(context, keys[i]!, widget.scrollController) ??
              [],
        for (int i = 0; i < widget.pages.length; i++)
          widget.pages[i].title(context, keys[i]!, widget.scrollController),
        WebSmoothScroll(
          controller: widget.scrollController,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollStartNotification) {
              } else if (scrollNotification is ScrollUpdateNotification) {
                widget.observer(keys.values.toList(),
                    widget.scrollController.offset, false);
                if (!isAnimated) {
                  for (var i = keys.length - 1; i >= 0; i--) {
                    final path = widget.pages[i].path;
                    final height = MediaQuery.of(context).size.height;
                    final offset = _getPositionIndex(i);
                    if (offset != null && offset < height * 0.4) {
                      widget.updater(path);
                      break;
                    }
                  }
                }
              } else if (scrollNotification is ScrollEndNotification) {
                widget.observer(
                    keys.values.toList(), widget.scrollController.offset, true);
              }

              return true;
            },
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(children: children),
            ),
            // child: ListView(controller: scrollController, children: children),
          ),
        ),
      ],
    );
  }
}

class AppPageData {
  AppPageData(
      {required this.path,
      required this.title,
      required this.content,
      this.background,
      required this.builder});

  final String path;
  final GlobalKey key = GlobalKey();
  final AppPageTitleBuider title;
  final BackgroundBuilder? background;
  final WidgetBuilder content;
  final AppPageAnimationBuider? builder;
}

typedef AppPageTitleBuider = Widget Function(
    BuildContext context, GlobalKey key, ScrollController controller);

typedef BackgroundBuilder = List<Widget> Function(
    BuildContext context, GlobalKey key, ScrollController controller);
typedef AppPageAnimationBuider = Widget Function(BuildContext, GlobalKey key,
    ScrollController scrollController, WidgetBuilder);
typedef RouteUpdater = void Function(String);
typedef ScrollObserver = void Function(
    List<GlobalKey> keys, double offset, bool isStop);

double? getPositionIndex(GlobalKey? key, {Offset offset = Offset.zero}) {
  try {
    final obj = key?.currentContext?.findRenderObject();

    RenderBox? box = obj == null ? null : obj as RenderBox;
    Offset? position = box?.localToGlobal(offset); //this is global position

    return position?.dy;
  } catch (e) {
    return null;
  }
}

Size? getSize(GlobalKey? key) {
  try {
    final obj = key?.currentContext?.findRenderObject();

    RenderBox? box = obj == null ? null : obj as RenderBox;

    return box?.size;
  } catch (e) {
    return null;
  }
}

double? getHeight(GlobalKey? key) {
  return getSize(key)?.height;
}
