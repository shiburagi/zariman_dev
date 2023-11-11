import 'package:flutter/material.dart';
import 'package:uikit/uikit.dart';

class ExperienceTitle extends StatelessWidget {
  const ExperienceTitle(
      {Key? key,
      required this.observerKey,
      required this.sectionFontSize,
      required this.scrollController})
      : super(key: key);
  final GlobalKey observerKey;
  final double sectionFontSize;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return TitleAnimation(
        observerKey: observerKey,
        sectionFontSize: sectionFontSize,
        scrollController: scrollController,
        child: Text.rich(
          TextSpan(children: [
            TextSpan(
              text: ">Work\n".toUpperCase(),
            ),
            TextSpan(
                text: "+Xperience".toUpperCase(),
                style: TextStyle(color: Theme.of(context).hintColor)),
          ]),
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: sectionFontSize, height: 1),
        ));
  }
}
