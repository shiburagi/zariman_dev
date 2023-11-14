import 'dart:math';

import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

class Loader extends StatefulWidget {
  const Loader(
      {Key? key, required this.observerKey, required this.scrollController})
      : super(key: key);

  final GlobalKey observerKey;
  final ScrollController scrollController;

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with TickerProviderStateMixin {
  late final AnimationController animationController;

  late final Animation<double> opacityAnimation;
  late final Animation<double> progressAnimation;

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
    return buildLoader();
  }

  AnimatedBuilder buildLoader() {
    return AnimatedBuilder(
        animation: opacityAnimation,
        builder: (context, child) {
          double curveValue =
              Curves.easeInOut.transform(progressAnimation.value);
          return Positioned(
            left: 32,
            right: 32,
            bottom: 0,
            top: 0,
            child: Opacity(
              opacity: curveValue == 0 ? 0 : 1 - opacityAnimation.value,
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.height / 2,
                margin: EdgeInsets.only(bottom: opacityAnimation.value * 60),
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
                                ? Theme.of(context).textTheme.displayMedium
                                : Theme.of(context).textTheme.headlineMedium,
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
}
