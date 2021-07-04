import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utils/utils.dart';

class SocialItem {
  final String? name;
  final IconData? icon;
  final String? url;

  SocialItem(this.name, this.icon, this.url);
}

final languages = [
  "Android",
  "Flutter",
  "Java",
  "Kotlin",
  "ReactJS",
];
final socials = [
  SocialItem("Github", FontAwesomeIcons.github, "https://github.com/shiburagi"),
  SocialItem("LinkedIn", FontAwesomeIcons.linkedin,
      "https://www.linkedin.com/in/zariman/"),
  SocialItem("E-mail", Icons.email, "mailto:zariman.razari@gmail.com"),
];

class MeView extends StatefulWidget {
  const MeView({
    Key? key,
  }) : super(key: key);

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

  TextStyle? get textStyle => Theme.of(context).textTheme.headline6?.copyWith(
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
                child: Container(
                  margin: EdgeInsets.only(left: 16),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Stack(
                            children: [
                              AnimatedBuilder(
                                  animation: _contoller,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, -70 * _contoller.value),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Card(
                                          // shape: RoundedRectangleBorder(),
                                          color: Colors.white,
                                          margin: EdgeInsets.fromLTRB(
                                              24, 12, 24, 50),
                                          elevation: 4,
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          child: Container(
                                            padding: EdgeInsets.only(top: 32),
                                            child: Image.asset(
                                              "assets/images/me4.png",
                                              fit: BoxFit.fitHeight,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                              Positioned(
                                left: 24,
                                right: 24,
                                bottom: 4,
                                height: 60,
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: Theme.of(context).shadowColor,
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
                                height: 60,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                  ),
                                  child: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: socials
                                        .map((e) => FutureBuilder<bool>(
                                            future: canLaunch(e.url ?? ""),
                                            builder: (context, snapshot) =>
                                                snapshot.data == true
                                                    ? InkWell(
                                                        onTap: () =>
                                                            launch(e.url ?? ""),
                                                        child: Card(
                                                          color:
                                                              Theme.of(context)
                                                                  .canvasColor,
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    4, 4, 4, 4),
                                                            child: Icon(e.icon),
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox()))
                                        .toList(),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: context.isMd ? 3 : 2,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(8, 48, 32, 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "Muhammad Norzariman Bin Razari",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: context.isMd ? 30 : 20,
                                          height: 1),
                                ),
                                Text("Mobile App Developer",
                                    style: textStyle?.copyWith(
                                        color: Theme.of(context)
                                            .hintColor
                                            .withOpacity(1))),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  "Selangor, MY",
                                  style: textStyle,
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Text.rich(
                                  TextSpan(children: [
                                    TextSpan(
                                      text:
                                          "Coding is my hobby, kill bug which I created is my expertise, coffee is my blood, and I do not know how to hack NASA with HTML, \n\nbut I can ",
                                    ),
                                    TextSpan(
                                      text: "develop a mobile app",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .hintColor
                                              .withOpacity(1)),
                                    ),
                                  ]),
                                  style: textStyle,
                                ),
                                SizedBox(
                                  height: 32,
                                ),
                                Expanded(child: Container()),
                                Wrap(
                                  children: languages
                                      .map((e) => Card(
                                            color: Colors.purple,
                                            child: Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  4, 2, 4, 2),
                                              child: Text(
                                                e,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
