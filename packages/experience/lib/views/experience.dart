import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:localize/generated/l10n.dart';
import 'package:repositories/models/experience.dart';
import 'package:repositories/repositories.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:uikit/uikit.dart';
import 'package:utils/utils.dart';

// Define a consistent line color/style
const lineStyle = LineStyle(color: lineColor, thickness: 2);

// Colorful palette for cards
final List<Color> cardPalette = [
  Color(0xFF5C6BC0), // Indigo
  Color(0xFFEC407A), // Pink
  Color(0xFFFFA726), // Orange
  Color(0xFF26A69A), // Teal
  Color(0xFF7E57C2), // Deep Purple
  Color(0xFFEF5350), // Red
  Color(0xFF42A5F5), // Blue
  Color(0xFF66BB6A), // Green
];

TextStyle primaryTextStyle(BuildContext context) {
  final textTheme = Theme.of(context).textTheme;
  return (context.isXs ? textTheme.titleMedium : textTheme.titleLarge) ??
      TextStyle();
}

TextStyle secondaryTextStyle(BuildContext context) {
  final textTheme = Theme.of(context).textTheme;
  return (context.isXs ? textTheme.bodyMedium : textTheme.bodyLarge) ??
      TextStyle();
}

class ExperienceView extends StatefulWidget {
  const ExperienceView({Key? key}) : super(key: key);

  @override
  State<ExperienceView> createState() => _ExperienceViewState();
}

class _ExperienceViewState extends State<ExperienceView> {
  final options = LiveOptions(
    delay: Duration(seconds: 0),
    showItemInterval: Duration(milliseconds: 100),
    showItemDuration: Duration(milliseconds: 300),
    visibleFraction: 0.05,
    reAnimateOnVisibility: false,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: sectionFontSize(context)),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000),
            child: FutureBuilder<List<Experience>>(
              future: AppRepo.instance.getExperience(),
              builder: (context, snapshot) {
                List<Experience> experiences = normaliseData(
                  snapshot.data ?? [],
                );

                if (experiences.isEmpty &&
                    snapshot.connectionState == ConnectionState.done) {
                  return Center(
                    child: Text(
                      "No experience listed.",
                      style: secondaryTextStyle(context),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      if (experiences.isNotEmpty)
                        ExperienceStartTile(experience: experiences.first),

                      LiveList.options(
                        options: options,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index, animation) {
                          final experience = experiences[index];
                          return ExperienceDetailTile(
                            experience: experience,
                            animation: animation,
                            index: index,
                            isLast: index == experiences.length - 1,
                          );
                        },
                        itemCount: experiences.length,
                      ),

                      ExperienceStartTile(experience: null),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 64),
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

    if (previous.endDate != null) {
      final previousDate = previous.endDate!.toDateTime();
      final currentDate = current.startDate.toDateTime();

      // If gap is significant (> 30 days), insert a gap entry
      if (currentDate.difference(previousDate).inDays > 30) {
        newList.add(
          Experience(
            startDate: previous.endDate!,
            endDate: current.startDate,
            position: "Freelancer",
          ),
        );
      }
    }
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
      alignment: TimelineAlign.center, // Centered for Journey effect
      isFirst: experience != null,
      isLast: experience == null,
      beforeLineStyle: lineStyle,
      afterLineStyle: lineStyle,
      indicatorStyle: IndicatorStyle(
        width: 20,
        height: 20,
        indicator: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
      // Minimal spacing anchors
    );
  }
}

class ExperienceDetailTile extends StatelessWidget {
  const ExperienceDetailTile({
    Key? key,
    required this.experience,
    required this.animation,
    required this.index,
    this.isLast = false,
  }) : super(key: key);

  final Experience experience;
  final Animation<double> animation;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isGap =
        experience.position == "Freelancer" && experience.company == null;

    // Select color from palette based on index
    final color = cardPalette[index % cardPalette.length];

    // Determine Zigzag side:
    // Index Even: Card Right, Date Left
    // Index Odd: Card Left, Date Right
    final isCardOnRight = index % 2 == 0;

    return TimelineTile(
      alignment: TimelineAlign.center,
      isLast: false,
      beforeLineStyle: isGap
          ? LineStyle(color: lineColor.withOpacity(0.3), thickness: 2)
          : lineStyle,
      afterLineStyle: isGap
          ? LineStyle(color: lineColor.withOpacity(0.3), thickness: 2)
          : lineStyle,
      indicatorStyle: IndicatorStyle(
        width: 24,
        height: 24,
        indicator: _buildIndicator(context, isGap, color),
        drawGap: true,
      ),
      startChild: isCardOnRight
          ? _buildDateSection(context, animation, alignRight: true)
          : _buildCardSection(
              context,
              animation,
              isGap,
              color,
              isRightSide: false,
            ),
      endChild: isCardOnRight
          ? _buildCardSection(
              context,
              animation,
              isGap,
              color,
              isRightSide: true,
            )
          : _buildDateSection(context, animation, alignRight: false),
    );
  }

  Widget _buildIndicator(BuildContext context, bool isGap, Color color) {
    if (isGap) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: lineColor.withOpacity(0.3), width: 2),
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: lineColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }

  // Wrapper to handle padding and animation direction for the Card
  Widget _buildCardSection(
    BuildContext context,
    Animation<double> animation,
    bool isGap,
    Color color, {
    required bool isRightSide,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: isRightSide ? 24.0 : 0,
        right: isRightSide ? 0 : 24.0,
        bottom: 40.0,
      ),
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          // If on right, slide from right (0.1). If on left, slide from left (-0.1).
          position: Tween<Offset>(
            begin: Offset(isRightSide ? 0.1 : -0.1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: _buildCard(context, isGap, color),
        ),
      ),
    );
  }

  // Wrapper to handle alignment and padding for Date
  Widget _buildDateSection(
    BuildContext context,
    Animation<double> animation, {
    required bool alignRight,
  }) {
    return Container(
      padding: EdgeInsets.only(
        left: alignRight ? 0 : 24.0,
        right: alignRight ? 24.0 : 0,
      ),
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(alignRight ? -0.1 : 0.1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: Column(
            crossAxisAlignment: alignRight
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDateText(
                context,
                experience.startDate.toDateTime(),
                alignRight: alignRight,
              ),
              if (experience.endDate != null) ...[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  height: 12,
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
                _buildDateText(
                  context,
                  experience.endDate!.toDateTime(),
                  isSecondary: true,
                  alignRight: alignRight,
                ),
              ] else ...[
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Present",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateText(
    BuildContext context,
    DateTime date, {
    bool isSecondary = false,
    required bool alignRight,
  }) {
    final year = date.year.toString();
    final month = _monthName(date.month);

    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          month,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSecondary
                ? Theme.of(context).disabledColor
                : Theme.of(context).textTheme.bodySmall?.color,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          year,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: isSecondary
                ? Theme.of(context).disabledColor
                : Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  Widget _buildCard(BuildContext context, bool isGap, Color color) {
    if (isGap) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.more_horiz,
              size: 24,
              color: Theme.of(context).disabledColor,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Freelance / Transition",
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        // Vibrant Gradient background
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.9), color],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Decorative shapes in background
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experience.position ?? "Position",
                    style: primaryTextStyle(context).copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                      color: Colors.white, // High contrast
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.business_rounded,
                        size: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          experience.company?.name ?? "Company",
                          style: secondaryTextStyle(context).copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // White Pill Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 12, color: color),
                        SizedBox(width: 6),
                        Text(
                          _durationString(experience),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _durationString(Experience exp) {
    final start = exp.startDate.toDateTime();
    final end = exp.endDate?.toDateTime() ?? DateTime.now();
    final days = end.difference(start).inDays;
    final years = days ~/ 365;
    final months = (days % 365) ~/ 30;

    final parts = <String>[];
    if (years > 0) parts.add("$years yr");
    if (months > 0) parts.add("$months mos");
    if (parts.isEmpty) return "1 mo";
    return parts.join(" ");
  }
}
