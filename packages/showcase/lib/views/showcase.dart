import 'dart:math';
import 'dart:ui';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localize/localize.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowcaseAction {
  final String label;
  final String url;
  final Color? color;

  ShowcaseAction(this.label, this.url, {this.color});
}

class ShowcasePlatform {
  final IconData icon;

  ShowcasePlatform(this.icon);
}

class Showcase {
  final String image;
  final String title;
  final String description;
  final List<String> tags;
  final List<ShowcasePlatform> platforms;
  final List<ShowcaseAction> actions;

  Showcase(
    this.image,
    this.title,
    this.description, {
    this.tags = const [],
    this.actions = const [],
    this.platforms = const [],
  });
}

List<Showcase> get showcases => [
      Showcase(
        "https://raw.githubusercontent.com/shiburagi/payment_flow_challenge/master-v2/preview/images/preview-1.png",
        "Cinema Booking Ticket App",
        "A template for cinema app",
        tags: [
          "dart",
          "flutter",
        ],
        actions: [
          ShowcaseAction(
            S.current.buy,
            "https://www.uplabs.com/posts/cinema-flutter-app",
          )
        ],
        platforms: [
          ShowcasePlatform(FontAwesomeIcons.android),
          ShowcasePlatform(FontAwesomeIcons.apple),
        ],
      ),
      Showcase(
        "https://bankapp.zariman.dev/preview.png",
        "Flutter Payment Flow (Bank)",
        "A personal project to experiment with UI and Animation of Flutter by converting a design/prototype from Uplabs Website to code.\n" +
            "https://www.uplabs.com/posts/payment-flow-066c958e-af5b-4bd3-8fbd-e2fdce44d7b4",
        actions: [
          ShowcaseAction(
            S.current.demo,
            "https://bankapp.zariman.dev/",
          ),
          ShowcaseAction(
            S.current.download,
            "https://www.uplabs.com/posts/payment-flow-payment-flow-066c958e-af5b-4bd3-8fbd-e2fdce44d7b4",
            color: Colors.green,
          )
        ],
        tags: [
          "dart",
          "flutter",
        ],
        platforms: [
          ShowcasePlatform(Icons.language),
          ShowcasePlatform(FontAwesomeIcons.android),
          ShowcasePlatform(FontAwesomeIcons.apple),
        ],
      ),
      Showcase(
        "https://raw.githubusercontent.com/shiburagi/Calendar-View-Flutter-UI/master/preview/image1.jpg",
        "Calendar View - Flutter UI",
        "an expirement Calendar UI code with Flutter. The calendar UI 100% develop from scratch without third-party library. The code should be able run on both Android and IOS",
        tags: [
          "dart",
          "flutter",
        ],
        actions: [
          ShowcaseAction(
            S.current.buy,
            "https://www.uplabs.com/posts/calendar-view-flutter-ui",
          )
        ],
        platforms: [
          ShowcasePlatform(FontAwesomeIcons.android),
          ShowcasePlatform(FontAwesomeIcons.apple),
        ],
      ),
      Showcase(
        "https://outdemic.zariman.dev/images/preview.png",
        "Outdemic",
        "A pandemic simulation game, written with dart language and flutter",
        tags: [
          "dart",
          "flutter",
        ],
        actions: [
          ShowcaseAction(
            S.current.play,
            "https://outdemic.zariman.dev/",
          )
        ],
        platforms: [
          ShowcasePlatform(Icons.language),
        ],
      ),
      Showcase(
        "https://groceryapp.zariman.dev/preview.png",
        "Flutter Grocery App",
        "A template for grocecy app, written with dart language  and flutter",
        actions: [
          ShowcaseAction(
            S.current.demo,
            "https://groceryapp.zariman.dev/",
          )
        ],
        tags: [
          "dart",
          "flutter",
        ],
        platforms: [
          ShowcasePlatform(Icons.language),
          ShowcasePlatform(Icons.android),
          ShowcasePlatform(FontAwesomeIcons.apple),
        ],
      ),
    ];

class ShowcaseView extends StatelessWidget {
  const ShowcaseView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final column =
        max(1, (min(MediaQuery.of(context).size.width, 1000) / 350).floor());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 120,
        ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000),
            child: GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1.2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                crossAxisCount: column,
              ),
              itemBuilder: (context, index) {
                if (index >= showcases.length) {
                  return Container(
                    alignment: Alignment.center,
                    color: Theme.of(context).canvasColor,
                    child: Text(
                      "404".toUpperCase(),
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  );
                }
                final showcase = showcases[index];
                return ShowcaseItemView(showcase: showcase);
              },
              itemCount: (showcases.length / column).ceil() * column,
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
        onTap:
            widget.showcase.actions.isEmpty ? null : () => controller.forward(),
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
                  widget.showcase.image,
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
                          Text(widget.showcase.title),
                          Linkify(
                            text: widget.showcase.description,
                            onOpen: (link) async {
                              if (await canLaunch(link.url)) {
                                await launch(link.url);
                              } else {
                                throw 'Could not launch $link';
                              }
                            },
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2
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
                                    .map((e) => Chip(
                                          backgroundColor: Colors.green,
                                          padding: EdgeInsets.zero,
                                          label: Text(e),
                                        ))
                                    .toList(),
                              ),
                              Wrap(
                                spacing: 4,
                                children: widget.showcase.platforms
                                    .map((e) => Icon(e.icon))
                                    .toList(),
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
      children: showcase.actions.map((e) {
        final color = e.color ?? Theme.of(context).accentColor;
        return InkWell(
          onTap: () => launch(e.url),
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                side: BorderSide(color: color),
                borderRadius: BorderRadius.circular(32)),
            color: Colors.white,
            child: Container(
              color: color.withOpacity(0.1),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                e.label.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
