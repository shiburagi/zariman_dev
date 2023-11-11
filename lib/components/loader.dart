import 'dart:math';

import 'package:flutter/material.dart';
import 'package:utils/utils.dart';

AnimatedBuilder AppLoader(Animation<double> opacityAnimation,
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
