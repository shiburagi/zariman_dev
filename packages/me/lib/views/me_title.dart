import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

class MeTitle extends StatefulWidget {
  const MeTitle(
      {Key? key, required this.observerKey, required this.scrollController})
      : super(key: key);

  final GlobalKey observerKey;
  final ScrollController scrollController;

  @override
  State<MeTitle> createState() => _MeTitleState();
}

class _MeTitleState extends State<MeTitle> with TickerProviderStateMixin {
  late final AnimationController animationController;

  late final Animation<double> opacityAnimation;
  late final Animation<double> progressAnimation;
  late final Animation<double> translationAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      upperBound: 1,
    );

    opacityAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: animationController, curve: Interval(0.6, 0.8)));
    progressAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: animationController, curve: Interval(0.0, 0.5)));
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
    return buildHelloTitle(sectionFontSize(context));
  }

  AnimatedBuilder buildHelloTitle(double sectionFontSize) {
    return AnimatedBuilder(
        animation: translationAnimation,
        builder: (context, child) {
          double curveValue =
              Curves.easeInOut.transform(translationAnimation.value);
          return Positioned(
            right: titleGap(context), // + width * curveValue * 0.2,
            top: -(sectionFontSize - 5) + curveValue * boxHeight,
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
}
