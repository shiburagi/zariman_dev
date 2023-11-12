import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:localize/generated/l10n.dart';
import 'package:repositories/models/experience.dart';
import 'package:repositories/repositories.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:utils/utils.dart';

const dotColor = Color(0XFFFA8072);
const lineColor = Color(0xFFFFE4E1);
const lineStyle = LineStyle(color: lineColor, thickness: 2);

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
          height: 120,
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0x00C0392B), Color(0xffC0392B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
        ),
        Container(
          color: Color(0xffC0392B),
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
                              return FadeTransition(
                                  opacity: Tween<double>(
                                    begin: 0,
                                    end: 1,
                                  ).animate(animation),
                                  // And slide transition
                                  child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: Offset(0, -0.1),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      // Paste you Widget
                                      child: ExperienceDetailTile(
                                          experience: experience)));
                            },
                            itemCount: experiences.length),
                        ExperienceStartTile(experience: null),
                      ],
                    );
                  }),
            ),
          ),
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: lineColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white),
                ),
              ),
            )));
  }
}

class ExperienceDetailTile extends StatelessWidget {
  const ExperienceDetailTile({Key? key, required this.experience})
      : super(key: key);

  final Experience experience;
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
          startChild: Container(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              experience.startDate.toDateTime().toMonthYearText(),
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          endChild: Container(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  experience.company?.name ?? "<Undefined>",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  experience.position ?? "",
                  style: Theme.of(context).textTheme.titleLarge,
                )
              ],
            ),
          ),
        ),
        TimelineTile(
          alignment: TimelineAlign.center,
          beforeLineStyle: lineStyle,
          hasIndicator: false,
          afterLineStyle: lineStyle,
          endChild: ExperienceDetailView(
            experience: experience,
          ),
        ),
      ],
    );
  }
}

class ExperienceDetailView extends StatelessWidget {
  const ExperienceDetailView({Key? key, required this.experience})
      : super(key: key);

  final Experience experience;
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge;
    final startDate = experience.startDate.toDateTime();
    final endDate = experience.endDate.toDateTime();

    return Flexible(
      flex: 1,
      child: Container(
        padding: EdgeInsets.fromLTRB(26, 4, 16, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(TextSpan(children: [
              TextSpan(text: startDate.toMonthYearText(), style: textStyle),
              TextSpan(
                  text: " to ",
                  style:
                      textStyle!.copyWith(color: Theme.of(context).hintColor)),
              TextSpan(text: endDate.toMonthYearText(), style: textStyle),
            ])),
          ],
        ),
      ),
    );
  }
}
