import 'package:experience/views/experience.dart';
import 'package:experience/views/experience_title.dart';
import 'package:flutter/material.dart';
import 'package:routes/routes.dart';
import 'package:uikit/uikit.dart';

export 'package:experience/pages/experience.dart';
export 'package:experience/views/experience.dart';
export 'package:experience/views/experience_title.dart';

AppPageData buillExperiencePageData() => AppPageData(
    path: RoutePath.experience,
    title: (context, key, scrollController) {
      return ExperienceTitle(
        scrollController: scrollController,
        observerKey: key,
        sectionFontSize: sectionFontSize(context),
      );
    },
    content: (context) => Container(
          padding: EdgeInsets.only(
              top: pagesPadding(context), bottom: pagesPadding(context)),
          alignment: Alignment.center,
          child: Theme(
            child: ExperienceView(),
            data: darkTheme,
          ),
        ),
    builder: (context, key, builder) => builder(context));
