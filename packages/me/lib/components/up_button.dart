import 'package:flutter/material.dart';
import 'package:routes/routes.dart';
import 'package:uikit/uikit.dart';
import 'package:utils/utils.dart';

class UpButton extends StatefulWidget {
  const UpButton(
      {Key? key,
      required this.observerKey,
      required this.scrollController,
      required this.onUpClicked})
      : super(key: key);

  final GlobalKey observerKey;
  final ScrollController scrollController;
  final RouteUpdater onUpClicked;

  @override
  State<UpButton> createState() => _UpButtonState();
}

class _UpButtonState extends State<UpButton> with TickerProviderStateMixin {
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
    return buildUpButton();
  }

  AnimatedBuilder buildUpButton() {
    double height =
        getHeight(widget.observerKey) ?? MediaQuery.of(context).size.height;
    return AnimatedBuilder(
        animation: opacityAnimation,
        builder: (context, child) {
          double curveValue =
              Curves.easeInOut.transform(progressAnimation.value);
          return Positioned(
            right: 0,
            bottom: 0 + height * curveValue,
            child: Center(
              child: IgnorePointer(
                ignoring: opacityAnimation.value > 0.2,
                child: Opacity(
                  opacity: (1 - curveValue * 2).clamp(0, 1),
                  child: InkWell(
                    onTap: () => widget.onUpClicked(RoutePath.showcase),
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
}
