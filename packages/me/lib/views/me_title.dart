import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';
import 'package:utils/utils.dart';

class MeTitle extends StatefulWidget {
  const MeTitle(
      {Key? key,
      required this.observerKey,
      required this.sectionFontSize,
      required this.animation3})
      : super(key: key);
  final GlobalKey observerKey;
  final double sectionFontSize;
  final Animation<double> animation3;

  @override
  State<StatefulWidget> createState() {
    return MeTitleState();
  }
}

class MeTitleState extends State<MeTitle> {
  @override
  Widget build(BuildContext context) {
    return buildHelloTitle(
        widget.animation3, widget.observerKey, widget.sectionFontSize);
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

  AnimatedBuilder buildHelloTitle(Animation<double> animation3,
      GlobalKey observeKey, double sectionFontSize) {
    return AnimatedBuilder(
        animation: animation3,
        builder: (context, child) {
          double curveValue = Curves.easeInOut.transform(animation3.value);
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
