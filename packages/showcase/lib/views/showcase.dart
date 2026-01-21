import 'dart:math';

import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:repositories/repositories.dart';
import 'package:uikit/components/theme.dart';
import 'package:url_launcher/url_launcher.dart';

// Vibrant palette for a "poster" art look
final List<Color> showcasePalette = [
  Color(0xFF5C6BC0), // Indigo
  Color(0xFFEC407A), // Pink
  Color(0xFFFFA726), // Orange
  Color(0xFF26A69A), // Teal
  Color(0xFF7E57C2), // Deep Purple
  Color(0xFFEF5350), // Red
  Color(0xFF42A5F5), // Blue
  Color(0xFF66BB6A), // Green
];

class ShowcaseView extends StatefulWidget {
  const ShowcaseView({Key? key}) : super(key: key);

  @override
  State<ShowcaseView> createState() => _ShowcaseViewState();
}

class _ShowcaseViewState extends State<ShowcaseView> {
  final options = LiveOptions(
    delay: Duration(seconds: 0),
    showItemInterval: Duration(milliseconds: 100),
    showItemDuration: Duration(milliseconds: 300),
    visibleFraction: 0.05,
    reAnimateOnVisibility: false,
  );

  @override
  Widget build(BuildContext context) {
    // Determine column count based on width
    final width = MediaQuery.of(context).size.width;
    final column = max(1, (min(width, 1200) / 300).floor());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: sectionFontSize(context)),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            constraints: BoxConstraints(maxWidth: 1200),
            child: FutureBuilder<List<Showcase>>(
              future: AppRepo.instance.getShowcases(),
              builder: (context, snapshot) {
                List<Showcase> showcases = snapshot.data ?? [];
                if (showcases.isEmpty &&
                    snapshot.connectionState == ConnectionState.done) {
                  return Center(child: Text("No showcases found."));
                }

                return LiveGrid.options(
                  options: options,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 0.7, // Taller, poster-like ratio
                    mainAxisSpacing: 32,
                    crossAxisSpacing: 32,
                    crossAxisCount: column,
                  ),
                  itemBuilder: (context, index, animation) {
                    if (index >= showcases.length) {
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          "END",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    }
                    final showcase = showcases[index];

                    return FadeTransition(
                      opacity: Tween<double>(
                        begin: 0,
                        end: 1,
                      ).animate(animation),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: ShowcaseItemView(
                          showcase: showcase,
                          index: index,
                        ),
                      ),
                    );
                  },
                  itemCount: showcases.length,
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

class ShowcaseItemView extends StatefulWidget {
  const ShowcaseItemView({
    Key? key,
    required this.showcase,
    required this.index,
  }) : super(key: key);

  final Showcase showcase;
  final int index;

  @override
  _ShowcaseItemViewState createState() => _ShowcaseItemViewState();
}

class _ShowcaseItemViewState extends State<ShowcaseItemView> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = showcasePalette[widget.index % showcasePalette.length];

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0.0, isHovered ? -12.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withAlpha((0.9 * 255).toInt()), color],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((0.4 * 255).toInt()),
              blurRadius: isHovered ? 24 : 12,
              offset: Offset(0, isHovered ? 12 : 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Section - "Framed" look
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: AspectRatio(
                aspectRatio: 1.4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (widget.showcase.preview != null)
                        Image.network(
                          widget.showcase.preview!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.white24),
                        )
                      else
                        Container(color: Colors.white24),

                      // Inner shadow for depth
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withAlpha((0.2 * 255).toInt()),
                            width: 1,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha((0.1 * 255).toInt()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Title & Platforms
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.showcase.title ?? "Untitled",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        if (widget.showcase.platforms != null)
                          Row(
                            children: widget.showcase.platforms!.take(2).map((
                              e,
                            ) {
                              final code =
                                  int.tryParse(e.icon ?? "", radix: 16) ?? 0;
                              return Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(
                                  IconData(
                                    code,
                                    fontFamily: e.family,
                                    fontPackage: e.package,
                                  ),
                                  size: 16,
                                  color: Colors.white.withAlpha(
                                    (0.8 * 255).toInt(),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Description
                    Expanded(
                      child: Linkify(
                        text: widget.showcase.description ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        onOpen: (link) async {
                          if (await canLaunchUrl(Uri.parse(link.url))) {
                            await launchUrl(Uri.parse(link.url));
                          }
                        },
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withAlpha((0.85 * 255).toInt()),
                          height: 1.4,
                        ),
                        linkStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Tags as semi-transparent white pills
                    if (widget.showcase.tags != null &&
                        widget.showcase.tags!.isNotEmpty)
                      SizedBox(
                        height: 24,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: widget.showcase.tags!
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(
                                        (0.2 * 255).toInt(),
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withAlpha(
                                          (0.1 * 255).toInt(),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      e.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),

                    SizedBox(height: 20),

                    // Actions
                    ShowcaseItemAction(
                      showcase: widget.showcase,
                      accentColor: color,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShowcaseItemAction extends StatelessWidget {
  const ShowcaseItemAction({
    Key? key,
    required this.showcase,
    required this.accentColor,
  }) : super(key: key);

  final Showcase showcase;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    if (showcase.actions == null || showcase.actions!.isEmpty) {
      return SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: showcase.actions!.length,
        separatorBuilder: (c, i) => SizedBox(width: 12),
        itemBuilder: (context, index) {
          final e = showcase.actions![index];

          return InkWell(
            onTap: () async {
              if (await canLaunchUrl(Uri.parse(e.url ?? ""))) {
                await launchUrl(Uri.parse(e.url ?? ""));
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).toInt()),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Text(
                    e.label?.toUpperCase() ?? "VIEW",
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 12,
                    color: accentColor,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
