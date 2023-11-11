import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localize/localize.dart';
import 'package:me/pages/me.dart';
import 'package:personal_website/views/menu.dart';
import 'package:personal_website/pages/splash.dart';
import 'package:routes/routes.dart';
import 'package:showcase/showcase.dart';

void main() {
  runApp(MyApp());
}

Map<String, WidgetBuilder> routes = {
  RoutePath.me: (context) => MePage(),
  RoutePath.showcase: (context) => ShowcasePage(),
};
final theme = ThemeData(
  fontFamily: "Barlow",
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green, brightness: Brightness.light)
      .copyWith(secondary: Color(0xffE74C3C)),
);
final darkTheme = ThemeData(
  fontFamily: "Barlow",
  brightness: Brightness.dark,
  canvasColor: Colors.black,
  cardColor: Colors.blueGrey.shade900,
  colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green, brightness: Brightness.dark)
      .copyWith(secondary: Color(0xffE74C3C)),
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
          home: Splashpage(controller: controller),
        ),
      ),
    );
  }
}
