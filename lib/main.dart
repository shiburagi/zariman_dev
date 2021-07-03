import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localize/localize.dart';
import 'package:me/pages/me.dart';
import 'package:personal_website/app.dart';
import 'package:routes/routes.dart';
import 'package:showcase/showcase.dart';

void main() {
  runApp(MyApp());
}

class AppMenuItem {
  final String name;
  final IconData icon;

  AppMenuItem(this.name, this.icon);
}

Map<String, WidgetBuilder> routes = {
  RoutePath.me: (context) => MePage(),
  RoutePath.showcase: (context) => ShowcasePage(),
};

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final CardMenuController controller = CardMenuController();
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      fontFamily: "Barlow",
      brightness: Brightness.light,
      accentColor: Color(0xffE74C3C),
      primarySwatch: Colors.blue,
    );
    final darkTheme = ThemeData(
      fontFamily: "Barlow",
      brightness: Brightness.dark,
      accentColor: Color(0xffE74C3C),
      primarySwatch: Colors.blue,
      canvasColor: Colors.black,
      cardColor: Colors.blueGrey.shade900,
    );
    final GlobalKey<NavigatorState> parentNavKey = GlobalKey();
    final GlobalKey<NavigatorState> key = GlobalKey();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Muhammad Norzariman',
      navigatorObservers: [NavigatorObserver()],
      navigatorKey: parentNavKey,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      theme: theme,
      darkTheme: darkTheme,
      home: Builder(builder: (context) {
        final menu = {
          RoutePath.me: AppMenuItem(S.current.me, FontAwesomeIcons.mehBlank),
          RoutePath.showcase:
              AppMenuItem(S.current.showcase, FontAwesomeIcons.briefcase),
        };
        return Stack(
          children: [
            AppPage(controller: controller),
            Positioned(
              left: 8,
              top: 8,
              child: CardMenu(
                menu: menu,
                navKey: key,
                controller: controller,
              ),
            )
          ],
        );
      }),
    );
  }
}

class CardMenu extends StatefulWidget {
  const CardMenu({
    Key? key,
    required this.menu,
    required this.navKey,
    required this.controller,
  }) : super(key: key);

  final Map<String, AppMenuItem> menu;
  final GlobalKey<NavigatorState> navKey;
  final CardMenuController controller;

  @override
  _CardMenuState createState() => _CardMenuState();
}

class _CardMenuState extends State<CardMenu> {
  @override
  void initState() {
    widget.controller._setter = setState;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          children: widget.menu.entries.map((e) {
            bool isActive = e.key == widget.controller.currentRoute;
            return IconButton(
                onPressed: isActive
                    ? null
                    : () {
                        print(e.key);
                        widget.controller.currentRoute = (e.key);
                      },
                icon: Icon(
                  e.value.icon,
                  color: isActive ? Theme.of(context).accentColor : null,
                ));
          }).toList(),
        ),
      ),
    );
  }
}

class CardMenuController {
  StateSetter? _setter;

  String _currentRoute = "/";
  String get currentRoute => _currentRoute;

  ValueChanged<String>? onChanged;

  set currentRoute(String currentRoute) {
    if (currentRoute != this._currentRoute)
      _setter?.call(() {
        onChanged?.call(currentRoute);
        this._currentRoute = currentRoute;
      });
  }
}
