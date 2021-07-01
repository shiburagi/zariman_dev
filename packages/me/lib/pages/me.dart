import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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

class MePage extends StatefulWidget {
  MePage({Key? key}) : super(key: key);

  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: Color(0xffCD5C5C),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(blurRadius: 10, color: Colors.black38)
                    ],
                    color: Color(0xffFFE4E1),
                  ),
                ),
              ),
            ],
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 700),
                    child: AspectRatio(
                      aspectRatio: 1.5,
                      child: Card(
                        elevation: 10,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Image.asset(
                                  "assets/images/me.jpg",
                                  fit: BoxFit.fitHeight,
                                  scale: 1.5,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(32, 32, 32, 32),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        "Muhammad Norzariman Bin Razari",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                      Text(
                                        "Mobile App Developer",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1
                                            ?.copyWith(
                                                color: Theme.of(context)
                                                    .hintColor),
                                      ),
                                      Wrap(
                                        children: languages
                                            .map((e) => Card(
                                                  color: Colors.purple,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            4, 2, 4, 2),
                                                    child: Text(e),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                      Expanded(child: Container()),
                                      Wrap(
                                        children: socials
                                            .map((e) => InkWell(
                                                  onTap: () =>
                                                      launch(e.url ?? ""),
                                                  child: Card(
                                                    color: Theme.of(context)
                                                        .canvasColor,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              4, 4, 4, 4),
                                                      child: Icon(e.icon),
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
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
