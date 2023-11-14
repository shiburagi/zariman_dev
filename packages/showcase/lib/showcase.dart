import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routes/routes.dart';
import 'package:showcase/views/showcase.dart';
import 'package:showcase/views/showcase_title.dart';
import 'package:uikit/uikit.dart';

export 'package:showcase/views/showcase.dart';
export 'package:showcase/views/showcase_title.dart';

AppPageData buildShowcasePageData() => AppPageData(
    path: RoutePath.showcase,
    title: (context, key, scrollController) {
      return ShowcaseTitle(
        scrollController: scrollController,
        observerKey: key,
        sectionFontSize: sectionFontSize(context),
      );
    },
    background: (context, key, controller) => [
          BackgroundAnimation(
              observerKey: key,
              sectionFontSize: sectionFontSize(context),
              scrollController: controller,
              child: Container(
                color: showcaseBackgroundColor,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ))
        ],
    content: (context) => Container(
          padding: EdgeInsets.only(
              top: pagesPadding(context), bottom: pagesPadding(context)),
          alignment: Alignment.center,
          child: ShowcaseView(),
        ),
    builder: (context, key, scrollController, builder) => builder(context));
