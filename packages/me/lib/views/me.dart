import 'package:flutter/material.dart';
import 'package:repositories/models/me.dart';
import 'package:repositories/repositories.dart';
import 'package:styled_text/styled_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utils/utils.dart';

const kDefaultProfileImage = "assets/images/me.png";

class MeView extends StatefulWidget {
  const MeView({Key? key, required this.me}) : super(key: key);
  final Me me;
  @override
  _MeViewState createState() => _MeViewState();
}

class _MeViewState extends State<MeView> with SingleTickerProviderStateMixin {
  late final AnimationController _contoller;
  @override
  void initState() {
    super.initState();
    _contoller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 100),
        lowerBound: 0,
        upperBound: 1);
  }

  TextStyle? get textStyle => Theme.of(context).textTheme.titleLarge?.copyWith(
      color: Theme.of(context).hintColor, fontSize: context.isMd ? 18 : 14);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800),
          child: Stack(
            children: [
              Positioned.fill(
                top: 32,
                bottom: 0,
                child: Card(
                  elevation: 10,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Container(),
                ),
              ),
              MouseRegion(
                  onEnter: (event) {
                    // _contoller.forward();
                  },
                  onExit: (event) {
                    // _contoller.reverse();
                  },
                  child: buildCard(context, widget.me)),
            ],
          ),
        )
      ],
    );
  }

  Widget buildCard(BuildContext context, Me? me) {
    final children = [
      context.isXs
          ? SizedBox()
          : Expanded(
              flex: 2,
              child: buildPhoto(context, me),
            ),
      Expanded(
        flex: context.isMd ? 3 : 2,
        child: Container(
          padding: context.isXs
              ? EdgeInsets.fromLTRB(16, 8, 16, 16)
              : EdgeInsets.fromLTRB(8, 48, 32, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                me?.name ?? "",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: context.isMd ? 30 : 20,
                    height: 1),
              ),
              Text(me?.expertise ?? "",
                  style: textStyle?.copyWith(
                      color: Theme.of(context).hintColor.withOpacity(1))),
              SizedBox(
                height: context.isXs ? 4 : 8,
              ),
              Text(
                me?.location ?? "",
                style: textStyle,
              ),
              SizedBox(
                height: context.isXs ? 8 : 16,
              ),
              StyledText(
                text: me?.summary ?? "",
                tags: {
                  "b": StyledTextTag(
                    style: textStyle?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).hintColor.withOpacity(1),
                    ),
                  )
                },
                style: textStyle,
              ),
              SizedBox(
                height: context.isXs ? 16 : 32,
              ),
              Expanded(child: Container()),
              Wrap(
                children: me?.languages
                        ?.map((e) => Card(
                              color: Colors.purple,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                                child: Text(
                                  e,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ))
                        .toList() ??
                    [],
              ),
            ],
          ),
        ),
      )
    ];
    return Container(
      margin: EdgeInsets.only(left: context.isXs ? 0 : 16),
      child: Column(
        children: [
          context.isXs ? buildPhoto(context, me) : SizedBox(),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPhoto(BuildContext context, Me? me) {
    double socialBlockHeight = context.isXs ? 48 : 60;
    return Container(
      margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Stack(
        children: [
          AnimatedBuilder(
              animation: _contoller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -70 * _contoller.value),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: Card(
                      // shape: RoundedRectangleBorder(),
                      color: Colors.white,
                      margin: EdgeInsets.fromLTRB(
                          24, 12, 24, context.isXs ? 8 : 50),
                      elevation: 2,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Container(
                        padding: EdgeInsets.only(top: 32),
                        child: me?.image == null
                            ? Image.asset(
                                kDefaultProfileImage,
                                fit: BoxFit.fitWidth,
                                width: context.isXs
                                    ? MediaQuery.of(context).size.width / 2
                                    : null,
                              )
                            : Image.network(
                                me!.image!,
                                fit: BoxFit.fitWidth,
                                width: context.isXs
                                    ? MediaQuery.of(context).size.width / 2
                                    : null,
                              ),
                      ),
                    ),
                  ),
                );
              }),
          Positioned(
            left: 24,
            right: 24,
            bottom: 30,
            height: socialBlockHeight - 30,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.5),
                      offset: Offset(0, 0),
                      blurRadius: 14,
                      spreadRadius: 2),
                ],
                color: Theme.of(context).cardColor,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 4,
            height: socialBlockHeight,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: context.isXs ? 8 : 24, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: me?.socials
                        ?.map((e) => FutureBuilder<bool>(
                            future: canLaunch(e.url ?? ""),
                            builder: (context, snapshot) =>
                                snapshot.data == true
                                    ? InkWell(
                                        onTap: () => launch(e.url ?? ""),
                                        child: Card(
                                          color: Theme.of(context).canvasColor,
                                          child: Container(
                                            padding:
                                                EdgeInsets.fromLTRB(4, 4, 4, 4),
                                            child: Icon(IconData(
                                              int.tryParse(e.icon ?? "",
                                                      radix: 16) ??
                                                  0,
                                              fontFamily: e.family,
                                              fontPackage: e.package,
                                            )),
                                          ),
                                        ),
                                      )
                                    : SizedBox()))
                        .toList() ??
                    [],
              ),
            ),
          )
        ],
      ),
    );
  }
}
