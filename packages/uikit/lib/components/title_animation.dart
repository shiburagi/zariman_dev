import 'package:flutter/material.dart';

class TitleAnimation extends StatefulWidget {
  const TitleAnimation({
    Key? key,
    required this.observerKey,
    required this.sectionFontSize,
    required this.scrollController,
    required this.child,
    this.offset = 0,
  }) : super(key: key);
  final GlobalKey observerKey;
  final double sectionFontSize;
  final ScrollController scrollController;
  final Widget child;
  final double offset;

  @override
  State<TitleAnimation> createState() => _TitleAnimationState();
}

class _TitleAnimationState extends State<TitleAnimation>
    with TickerProviderStateMixin {
  late final AnimationController animationController;
  late final AnimationController opacityController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      upperBound: 2,
    );

    opacityController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      upperBound: 1,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      double height = MediaQuery.of(context).size.height;

      widget.scrollController.addListener(() {
        final offset = this.offset;
        if (offset == null) {
          animationController.value = 0;
          opacityController.value = 0;
        } else {
          final y = (height - offset).clamp(0, height).toDouble();
          final maxTo = boxHeight - height * 0.4;
          if (offset >= -maxTo) {
            final percent = (y / height);
            animationController.value = percent;
            opacityController.value = percent;
          } else {
            final maxBound = height * 0.8;
            final y = (maxTo + offset).abs().clamp(0, maxBound).toDouble();
            final percent = y / maxBound;
            debugPrint("showCase: $boxHeight $offset $y $percent");
            animationController.value = 1.0 + percent;
            opacityController.value = 1.0 - (percent * 2).clamp(0, 1);
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
    return buildExperienceTitle(
        widget.observerKey, widget.scrollController, widget.sectionFontSize);
  }

  AnimatedBuilder buildExperienceTitle(
      GlobalKey key, ScrollController controller, double sectionFontSize) {
    return AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return AnimatedBuilder(
              animation: opacityController,
              builder: (context, child) {
                double curveValue = (animationController.value);
                return Positioned(
                  left: 0,
                  right: 32, //+ width * curveValue * 0.2,
                  top: widget.offset -
                      boxHeight +
                      4 +
                      (curveValue).clamp(0, 2) * boxHeight,
                  child: Opacity(
                    opacity: (opacityController.value).clamp(0, 1),
                    child: widget.child,
                  ),
                );
              });
        });
  }
}
