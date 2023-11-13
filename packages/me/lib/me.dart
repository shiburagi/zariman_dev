import 'dart:math';

import 'package:flutter/material.dart';
import 'package:me/views/me.dart';
import 'package:me/views/me_title.dart';
import 'package:repositories/repo/app.dart';
import 'package:routes/routes.dart';
import 'package:uikit/uikit.dart';
import 'package:utils/utils.dart';

export 'package:me/views/me.dart';
export 'package:me/views/me_title.dart';

class MeAppPage {
  MeAppPage._(this.onUpClicked);

  MeAppPage.create(AnimationController animationController, this.onUpClicked) {
    animation1 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: animationController, curve: Interval(0.6, 0.8)));
    animation2 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: animationController, curve: Interval(0.0, 0.5)));
    animation3 = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.0, 1.0),
    ));
  }

  late final Animation<double> animation1;
  late final Animation<double> animation2;
  late final Animation<double> animation3;

  final RouteUpdater onUpClicked;

  AnimatedBuilder buildUpButton(double height) {
    return AnimatedBuilder(
        animation: animation3,
        builder: (context, child) {
          double curveValue = Curves.easeInOut.transform(animation2.value);
          return Positioned(
            right: 0,
            bottom: 0 + height * curveValue,
            child: Center(
              child: IgnorePointer(
                ignoring: animation3.value > 0.2,
                child: Opacity(
                  opacity: (1 - curveValue * 2).clamp(0, 1),
                  child: InkWell(
                    onTap: () => onUpClicked(RoutePath.showcase),
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

  Widget mePageAnimationBuider(BuildContext context, GlobalKey key,
      ScrollController scrollController, WidgetBuilder builder) {
    return AnimatedBuilder(
      animation: animation3,
      builder: (context, child) {
        final size = getSize(key);
        final width = size?.width ?? 0;
        final height = size?.height ?? 0;
        double dx = (-Curves.fastOutSlowIn.transform(animation3.value) * width)
            .clamp(-width, 0.0);

        double dy = animation3.value * height;
        if (height - pagesPadding(context) >
            MediaQuery.of(context).size.height) {
          dx = 0;
          dy = 0;
        }
        return Transform.translate(
          offset: Offset(dx, dy),
          child: builder(context),
        );
      },
    );
  }

  AppPageData build() {
    return AppPageData(
      path: RoutePath.me,
      title: (context, key, scrollController) {
        return MeTitle(
          animation3: animation3,
          observerKey: key,
          sectionFontSize: sectionFontSize(context),
        );
      },
      background: (context, key, controller) => [
        buildBackground(animation2, animation3, getHeight(key) ?? 0),
        buildLoader(animation1, animation2, animation3),
      ],
      content: (context) => Container(
        padding: EdgeInsets.only(
            top: pagesPadding(context), bottom: pagesPadding(context)),
        alignment: Alignment.center,
        child: MeView(me: AppRepo.instance.me!),
      ),
      builder: mePageAnimationBuider,
    );
  }
}

Widget buildBackground(Animation<double> opacityAnimation,
    Animation<double> positionAnimation, double height) {
  return AnimatedBuilder(
      animation: positionAnimation,
      builder: (context, child) {
        final value =
            Curves.easeInOut.transform((opacityAnimation.value).clamp(0, 1));
        final value1 = Curves.fastOutSlowIn
            .transform((positionAnimation.value).clamp(0, 1));
        return Positioned.fill(
          top: height - height * value1,
          bottom: -height + height * value1,
          child: Container(
            color: Color(0xffC0392B).withOpacity(
              value,
            ),
          ),
        );
      });
}

AnimatedBuilder buildLoader(Animation<double> opacityAnimation,
    Animation<double> curveAnimation, Animation<double> scaleAnimation) {
  return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        double curveValue = Curves.easeInOut.transform(curveAnimation.value);
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
