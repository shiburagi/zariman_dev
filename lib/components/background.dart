import 'package:flutter/material.dart';

Widget AppBackground(Animation<double> opacityAnimation,
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
