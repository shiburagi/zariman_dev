import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:localize/localize.dart';
import 'package:me/pages/me.dart';
import 'package:personal_website/app.dart';
import 'package:routes/routes.dart';
import 'package:showcase/showcase.dart';
import 'package:utils/utils.dart';

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
final theme = ThemeData(
  fontFamily: "Barlow",
  brightness: Brightness.light,
  accentColor: Color(0xffE74C3C),
  primarySwatch: Colors.green,
);
final darkTheme = ThemeData(
  fontFamily: "Barlow",
  brightness: Brightness.dark,
  accentColor: Color(0xffE74C3C),
  primarySwatch: Colors.green,
  canvasColor: Colors.black,
  cardColor: Colors.blueGrey.shade900,
);

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final CardMenuController controller = CardMenuController();
  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> parentNavKey = GlobalKey();
    final GlobalKey<NavigatorState> key = GlobalKey();
    return BlocProvider(
      create: (context) => SettingsBloc(),
      child: BlocBuilder<SettingsBloc, ThemeMode>(
        builder: (context, state) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Muhammad Norzariman',
          themeMode: state,
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
              RoutePath.me:
                  AppMenuItem(S.current.me, FontAwesomeIcons.mehBlank),
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
        ),
      ),
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

class _CardMenuState extends State<CardMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double get size => context.isXs ? 20 : 24;
  double get space => context.isXs ? 16 : 32;
  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    widget.controller._setter = (f) {
      if (widget.controller._currentRoute == RoutePath.showcase) {
        _controller.reverse();
      } else
        _controller.forward();
      setState(f);
    };
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CardMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          elevation: 4,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => Positioned(
                    top: _controller.value * (size + space + 1),
                    left: 0,
                    right: 0,
                    height: size + space,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(colors: [
                            Colors.pink,
                            Colors.red,
                          ])),
                    )),
              ),
              Container(
                height: (size + space) * 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: widget.menu.entries.map((e) {
                    bool isActive = e.key == widget.controller.currentRoute;
                    return InkWell(
                        onTap: isActive
                            ? () {}
                            : () {
                                print(e.key);
                                widget.controller.currentRoute = (e.key);
                              },
                        child: Container(
                          width: size + space,
                          height: size + space,
                          child: Icon(
                            e.value.icon,
                            size: size,
                            // color:
                            //     isActive ? Theme.of(context).accentColor : null,
                          ),
                        ));
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          width: space / 2,
          height: 1,
          decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16)),
        ),
        Card(
          elevation: 4,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: AnimatedContainer(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.yellow.shade700
                : Colors.grey.shade900,
            duration: Duration(milliseconds: 200),
            child: InkWell(
                onTap: () {
                  context.read<SettingsBloc>().changeTheme(
                      Theme.of(context).brightness == Brightness.light
                          ? ThemeMode.dark
                          : ThemeMode.light);
                },
                child: Container(
                  width: size + space,
                  height: size + space,
                  child: Icon(
                    Theme.of(context).brightness == Brightness.light
                        ? FontAwesomeIcons.sun
                        : FontAwesomeIcons.moon,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.yellow.shade800,
                    size: size,
                  ),
                )),
          ),
        ),
      ],
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

class SettingsBloc extends Cubit<ThemeMode> {
  SettingsBloc() : super(ThemeMode.system);

  changeTheme(ThemeMode mode) {
    emit(mode);
  }
}
