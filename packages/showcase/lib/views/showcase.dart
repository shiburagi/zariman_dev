import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:repositories/models/showcase.dart';
import 'package:repositories/repositories.dart';
import 'package:url_launcher/url_launcher.dart';

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
            child: FutureBuilder<List<Showcase>>(
                future: AppRepo.instance.getShowcases(),
                builder: (context, snapshot) {
                  List<Showcase> showcases = snapshot.data ?? [];
                  return GridView.builder(
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
                  );
                }),
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
              bottom: 48,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                child: Image.network(
                  widget.showcase.preview ?? "",
                  fit: BoxFit.cover,
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
                          border: Border(
                              top: BorderSide(
                                  color: Theme.of(context).dividerColor))),
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
            final color = e.color == null
                ? Colors.blueGrey
                : Color(int.parse(e.color!, radix: 16));
            return InkWell(
              onTap: () => launch(e.url ?? ""),
              child: Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: color, width: 4),
                    borderRadius: BorderRadius.circular(8)),
                color: Colors.white,
                child: Container(
                  color: color.withOpacity(0.1),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text(
                    e.label?.toUpperCase() ?? "",
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }).toList() ??
          [],
    );
  }
}