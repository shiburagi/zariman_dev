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
    background: (context, key, controller) => [
          BackgroundAnimation(
              observerKey: key,
              sectionFontSize: sectionFontSize(context),
              scrollController: controller,
              child: Container(
                color: experienceBackgroundColor,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ))
        ],
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
