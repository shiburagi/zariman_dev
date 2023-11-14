import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:localize/generated/l10n.dart';
import 'package:repositories/models/experience.dart';
import 'package:repositories/repositories.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:uikit/uikit.dart';
import 'package:utils/utils.dart';

const lineStyle = LineStyle(color: lineColor, thickness: 2);

TextStyle primaryTextStyle(BuildContext context) {
  final textTheme = Theme.of(context).textTheme;
  return (context.isXs ? textTheme.titleLarge : textTheme.headlineSmall) ??
      TextStyle();
}

TextStyle secondaryTextStyle(BuildContext context) {
  final textTheme = Theme.of(context).textTheme;
  return (context.isXs ? textTheme.titleMedium : textTheme.titleLarge) ??
      TextStyle();
}

class ExperienceView extends StatefulWidget {
  const ExperienceView({
    Key? key,
  }) : super(key: key);

  @override
  State<ExperienceView> createState() => _ExperienceViewState();
}

class _ExperienceViewState extends State<ExperienceView> {
  final options = LiveOptions(
    // Start animation after (default zero)
    delay: Duration(seconds: 0),

    // Show each item through (default 250)
    showItemInterval: Duration(milliseconds: 200),

    // Animation duration (default 250)
    showItemDuration: Duration(milliseconds: 200),

    // Animations starts at 0.05 visible
    // item fraction in sight (default 0.025)
    visibleFraction: 0.05,

    // Repeat the animation of the appearance
    // when scrolling in the opposite direction (default false)
    // To get the effect as in a showcase for ListView, set true
    reAnimateOnVisibility: false,
  );
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: sectionFontSize(context) * 1.2,
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            experienceBackgroundColor.withOpacity(0),
            experienceBackgroundColor
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        ),
        Container(
          color: experienceBackgroundColor,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1000),
              child: FutureBuilder<List<Experience>>(
                  future: AppRepo.instance.getExperience(),
                  builder: (context, snapshot) {
                    List<Experience> experiences =
                        normaliseData(snapshot.data ?? []);
                    return Column(
                      children: [
                        ExperienceStartTile(
                            experience: experiences.firstOrNull),
                        LiveList.options(
                            options: options,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index, animation) {
                              final experience = experiences[index];
                              return ExperienceDetailTile(
                                experience: experience,
                                animation: animation,
                              );
                            },
                            itemCount: experiences.length),
                        ExperienceStartTile(experience: null),
                      ],
                    );
                  }),
            ),
          ),
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            experienceBackgroundColor,
            experienceBackgroundColor.withOpacity(0),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        ),
        SizedBox(
          height: 48,
        )
      ],
    );
  }
}

List<Experience> normaliseData(List<Experience> experiences) {
  if (experiences.isEmpty) return experiences;
  final newList = <Experience>[];
  newList.add(experiences.first);

  for (var i = 1; i < experiences.length; i++) {
    final previous = experiences[i - 1];
    final current = experiences[i];
    final previousDate = previous.endDate.toDateTime();
    final currentDate = current.startDate.toDateTime();
    if (currentDate.difference(previousDate).inDays > 30)
      newList.add(Experience(
          startDate: previous.endDate,
          endDate: current.startDate,
          position: "Freelancer"));
    newList.add(current);
  }

  return newList;
}

class ExperienceStartTile extends StatelessWidget {
  const ExperienceStartTile({Key? key, required this.experience})
      : super(key: key);

  final Experience? experience;
  @override
  Widget build(BuildContext context) {
    return TimelineTile(
        alignment: TimelineAlign.center,
        isFirst: experience != null,
        isLast: experience == null,
        beforeLineStyle: lineStyle,
        afterLineStyle: lineStyle,
        indicatorStyle: IndicatorStyle(
            width: 200,
            height: 40,
            indicator: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                    color: lineColor, borderRadius: BorderRadius.circular(16)),
                child: Text(
                  (experience?.startDate)?.toDateTime().toYearText() ??
                      S.of(context).today,
                  style: secondaryTextStyle(context).copyWith(
                      color: lineColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white),
                ),
              ),
            )));
  }
}

class ExperienceDetailTile extends StatelessWidget {
  const ExperienceDetailTile(
      {Key? key, required this.experience, required this.animation})
      : super(key: key);

  final Experience experience;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TimelineTile(
          alignment: TimelineAlign.center,
          indicatorStyle: IndicatorStyle(
              color: dotColor, padding: EdgeInsets.symmetric(vertical: 2)),
          beforeLineStyle: lineStyle,
          afterLineStyle: lineStyle,
          startChild: buildAnimation(
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Text(
                experience.startDate.toDateTime().toMonthYearText(),
                textAlign: TextAlign.end,
                style: secondaryTextStyle(context),
              ),
            ),
          ),
          endChild: buildAnimation(
            xOffset: 0.2,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experience.company?.name ?? "[404]",
                    style: primaryTextStyle(context)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    experience.position ?? "",
                    style: secondaryTextStyle(context),
                  )
                ],
              ),
            ),
          ),
        ),
        TimelineTile(
          alignment: TimelineAlign.center,
          beforeLineStyle: lineStyle,
          hasIndicator: false,
          afterLineStyle: lineStyle,
          endChild: buildAnimation(
            xOffset: 0.2,
            child: buildTimeframe(context),
          ),
        ),
      ],
    );
  }

  Widget buildTimeframe(BuildContext context) {
    final textStyle = secondaryTextStyle(context);
    final startDate = experience.startDate.toDateTime();
    final endDate = experience.endDate?.toDateTime();

    return Container(
      padding: EdgeInsets.fromLTRB(26, 4, 16, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(TextSpan(children: [
            TextSpan(text: startDate.toMonthYearText(), style: textStyle),
            TextSpan(
                text: " to ",
                style: textStyle!.copyWith(color: Theme.of(context).hintColor)),
            TextSpan(
                text: endDate?.toMonthYearText() ?? S.of(context).today,
                style: textStyle),
          ])),
        ],
      ),
    );
  }

  Widget buildAnimation({required Widget child, double xOffset = -0.2}) {
    return FadeTransition(
        opacity: Tween<double>(
          begin: 0,
          end: 1,
        ).animate(animation),
        // And slide transition
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(xOffset, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ));
  }
}
