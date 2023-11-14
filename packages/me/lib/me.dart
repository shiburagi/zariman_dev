import 'package:flutter/material.dart';
import 'package:me/components/loader.dart';
import 'package:me/components/page_animation.dart';
import 'package:me/views/me_title.dart';
import 'package:me/views/me.dart';
import 'package:repositories/repo/app.dart';
import 'package:routes/routes.dart';
import 'package:uikit/uikit.dart';

export 'package:me/components/up_button.dart';
export 'package:me/views/me.dart';
export 'package:me/views/me_title.dart';

AppPageData buildMePageData() {
  return AppPageData(
    path: RoutePath.me,
    title: (context, key, scrollController) {
      return MeTitle(observerKey: key, scrollController: scrollController);
    },
    background: (context, key, scrollController) =>
        [Loader(observerKey: key, scrollController: scrollController)],
    content: (context) => Container(
      padding: EdgeInsets.only(
          top: pagesPadding(context), bottom: pagesPadding(context)),
      alignment: Alignment.center,
      child: MeView(me: AppRepo.instance.me!),
    ),
    builder: (context, key, scrollController, builder) => PageAnimation(
        observerKey: key, scrollController: scrollController, builder: builder),
  );
}
