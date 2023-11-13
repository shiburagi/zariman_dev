import 'dart:math';
import 'dart:ui';

import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:repositories/repositories.dart';
import 'package:uikit/components/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowcaseView extends StatefulWidget {
  const ShowcaseView({
    Key? key,
  }) : super(key: key);

  @override
  State<ShowcaseView> createState() => _ShowcaseViewState();
}

class _ShowcaseViewState extends State<ShowcaseView> {
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
    final column =
        max(1, (min(MediaQuery.of(context).size.width, 1000) / 350).floor());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: sectionFontSize(context),
        ),
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 1000),
              child: FutureBuilder<List<Showcase>>(
                  future: AppRepo.instance.getShowcases(),
                  builder: (context, snapshot) {
                    List<Showcase> showcases = snapshot.data ?? [];
                    return LiveGrid.options(
                      options: options,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1.2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        crossAxisCount: column,
                      ),
                      itemBuilder: (context, index, animation) {
                        if (index >= showcases.length) {
                          return Container(
                            alignment: Alignment.center,
                            color: Theme.of(context).canvasColor,
                            child: Text(
                              "404".toUpperCase(),
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                          );
                        }
                        final showcase = showcases[index];

                        final grid = index % column.toDouble();
                        final mid = (column - 1) / 2.0;

                        double x = grid < mid
                            ? -0.3
                            : grid > mid
                                ? 0.3
                                : 0;
                        double y = grid == mid ? -0.1 : 0;
                        return FadeTransition(
                            opacity: Tween<double>(
                              begin: 0,
                              end: 1,
                            ).animate(animation),
                            // And slide transition
                            child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(x, y),
                                  end: Offset.zero,
                                ).animate(animation),
                                // Paste you Widget
                                child: ShowcaseItemView(showcase: showcase)));
                      },
                      itemCount: (showcases.length / column).ceil() * column,
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

class ShowcaseItemView extends StatefulWidget {
  const ShowcaseItemView({
    Key? key,
    required this.showcase,
  }) : super(key: key);

  final Showcase showcase;

  @override
  _ShowcaseItemViewState createState() => _ShowcaseItemViewState();
}

class _ShowcaseItemViewState extends State<ShowcaseItemView>
    with TickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;
  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        controller.forward();
      },
      onExit: (event) {
        controller.reverse();
      },
      child: InkWell(
        onTap: widget.showcase.actions?.isNotEmpty != true
            ? null
            : () => controller.forward(),
        child: buildCard(context),
      ),
    );
  }

  // bool isHover = false;

  Widget buildCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          // side: BorderSide(color: Theme.of(context).hintColor.withOpacity(1)),
          ),
      margin: EdgeInsets.zero,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Stack(
          children: [
            Positioned(
              left: -48 * animation.value,
              right: -48 * animation.value,
              top: -24 * animation.value,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                child: Image.network(
                  widget.showcase.preview ?? "",
                ),
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Expanded(
                    child: Visibility(
                      visible: animation.value > 0,
                      child: Opacity(
                        opacity: animation.value,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                          child: Container(
                            color: Colors.white54,
                            child: Center(
                              child:
                                  ShowcaseItemAction(showcase: widget.showcase),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(),
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.white))),
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            widget.showcase.title ?? "-",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Linkify(
                            text: widget.showcase.description ?? "",
                            onOpen: (link) async {
                              if (await canLaunch(link.url)) {
                                await launch(link.url);
                              } else {}
                            },
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: Theme.of(context).hintColor),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                spacing: 4,
                                children: widget.showcase.tags
                                        ?.map((e) => Chip(
                                              backgroundColor: Colors.green,
                                              padding: EdgeInsets.zero,
                                              label: Text(e),
                                            ))
                                        .toList() ??
                                    [],
                              ),
                              Wrap(
                                spacing: 4,
                                children: widget.showcase.platforms?.map((e) {
                                      final code = int.tryParse(e.icon ?? "",
                                              radix: 16) ??
                                          0;

                                      return Icon(IconData(code,
                                          fontFamily: e.family,
                                          fontPackage: e.package));
                                    }).toList() ??
                                    [],
                              ),
                            ],
                          ),
                        ],
                      ),
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
}

class ShowcaseItemAction extends StatelessWidget {
  const ShowcaseItemAction({
    Key? key,
    required this.showcase,
  }) : super(key: key);

  final Showcase showcase;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: showcase.actions?.map((e) {
            List<Color> colors =
                e.colors?.map((e) => Color(int.parse(e, radix: 16))).toList() ??
                    [defaultShowcaseButtonColor, defaultShowcaseButtonColor];

            if (colors.length == 1) {
              colors = [...colors, colors.first];
            }
            return InkWell(
              onTap: () => launchUrl(Uri.parse(e.url ?? "")),
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    // side: BorderSide(color: color, width: 4),
                    borderRadius: BorderRadius.circular(8)),
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    e.label?.toUpperCase() ?? "",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.first.computeLuminance() > 0.3
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }).toList() ??
          [],
    );
  }
}
