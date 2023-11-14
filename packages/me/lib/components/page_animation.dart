import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

class PageAnimation extends StatefulWidget {
  const PageAnimation(
      {Key? key,
      required this.observerKey,
      required this.scrollController,
      required this.builder})
      : super(key: key);

  final GlobalKey observerKey;
  final ScrollController scrollController;
  final WidgetBuilder builder;

  @override
  State<PageAnimation> createState() => _PageAnimationState();
}

class _PageAnimationState extends State<PageAnimation>
    with TickerProviderStateMixin {
  late final AnimationController animationController;

  late final Animation<double> translationAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      upperBound: 1,
    );

    translationAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.0, 1.0),
    ));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      double height = MediaQuery.of(context).size.height;

      widget.scrollController.addListener(() {
        final offset = this.offset;
        if (offset == null) {
          animationController.value = 0;
        } else {
          final y =
              widget.scrollController.offset.clamp(0, boxHeight).toDouble();
          final maxTo = boxHeight - height * 0.4;
          if (offset >= -maxTo) {
            final percent = (y / height);
            animationController.value = percent.clamp(0, 1);
          }
        }
      });
    });
  }

  double? get offset {
    try {
      final obj = widget.observerKey.currentContext?.findRenderObject();
      RenderBox? box = obj == null ? null : obj as RenderBox;
      final position = box?.localToGlobal(Offset.zero);
      return position?.dy;
    } catch (e) {
      return null;
    }
  }

  double _height = 0;
  double get boxHeight {
    try {
      double height = MediaQuery.of(context).size.height;

      final obj = widget.observerKey.currentContext?.findRenderObject();
      RenderBox? box = obj == null ? null : obj as RenderBox;

      _height = box?.size.height ?? _height;
      if (_height == 0) _height = height;
      return _height;
    } catch (e) {
      return _height;
    }
  }

  @override
  Widget build(BuildContext context) {
    return mePageAnimationBuider();
  }

  Widget mePageAnimationBuider() {
    return AnimatedBuilder(
      animation: translationAnimation,
      builder: (context, child) {
        final size = getSize(widget.observerKey);
        final width = size?.width ?? 0;
        final height = size?.height ?? 0;
        double dx =
            (-Curves.fastOutSlowIn.transform(translationAnimation.value) *
                    width)
                .clamp(-width, 0.0);

        double dy = translationAnimation.value * height;
        if (height - pagesPadding(context) >
            MediaQuery.of(context).size.height) {
          dx = 0;
          dy = 0;
        }
        return Transform.translate(
          offset: Offset(dx, dy),
          child: widget.builder(context),
        );
      },
    );
  }
}
