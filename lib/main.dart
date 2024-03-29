import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:localize/localize.dart';
import 'package:personal_website/pages/splash.dart';
import 'package:personal_website/views/menu.dart';
import 'package:uikit/uikit.dart';

void main() {
  runApp(MyApp());
}

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
          color: Colors.black,
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
