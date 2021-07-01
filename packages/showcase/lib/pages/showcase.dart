import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:localize/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class Showcase {
  final String image;
  final String title;
  final String description;
  final String demoUrl;
  final List<String> tags;

  Showcase(this.image, this.title, this.description, this.demoUrl, this.tags);
}

class ShowcasePage extends StatefulWidget {
  ShowcasePage({Key? key}) : super(key: key);

  @override
  _ShowcasePageState createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  final showcases = [
    Showcase(
      "http://outdemic.zariman.dev/images/preview.png",
      "Outdemic",
      "A pandemic simulation game, written with dart language and flutter",
      "http://outdemic.zariman.dev/",
      [
        "dart",
        "flutter",
      ],
    ),
    Showcase(
      "https://raw.githubusercontent.com/shiburagi/flutter_grocery_app/gh-pages/preview.png",
      "Flutter Grocery App Template",
      "A template for grocecy app, written with dart language  and flutter",
      "http://groceryapp.zariman.dev/",
      [
        "dart",
        "flutter",
      ],
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffCD5C5C),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 48,
            ),
            Text(
              S.of(context).showcase,
              style: Theme.of(context).textTheme.headline2,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 48,
            ),
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1000),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                    crossAxisCount:
                        min(MediaQuery.of(context).size.width / 500, 1000)
                            .floor(),
                  ),
                  itemBuilder: (context, index) {
                    final showcase = showcases[index];
                    return ShowcaseView(showcase: showcase);
                  },
                  itemCount: showcases.length,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ShowcaseView extends StatefulWidget {
  const ShowcaseView({
    Key? key,
    required this.showcase,
  }) : super(key: key);

  final Showcase showcase;

  @override
  _ShowcaseViewState createState() => _ShowcaseViewState();
}

class _ShowcaseViewState extends State<ShowcaseView>
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
        if (!controller.isAnimating) controller.forward();
      },
      onExit: (event) {
        if (!controller.isAnimating) controller.reverse();
      },
      child: InkWell(
        onTap: () => launch(widget.showcase.demoUrl),
        child: buildCard(context),
      ),
    );
  }

  // bool isHover = false;

  Widget buildCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).hintColor.withOpacity(1))),
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
            Positioned.fill(
              child: Opacity(
                opacity: animation.value,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                  child: Container(
                    color: Colors.white12,
                    child: Center(
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Theme.of(context).accentColor),
                            borderRadius: BorderRadius.circular(32)),
                        color: Colors.white,
                        child: Container(
                          color: Theme.of(context).accentColor.withOpacity(0.1),
                          padding:
                              EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Text(
                            "View Demo",
                            style:
                                TextStyle(color: Theme.of(context).accentColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(widget.showcase.title),
                      Text(
                        widget.showcase.description,
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2
                            ?.copyWith(color: Theme.of(context).hintColor),
                      ),
                      SizedBox(
                        height: 16,
                      ),
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
