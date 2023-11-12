import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:utils/utils.dart';

class AppMenuItem {
  final String name;
  final IconData icon;

  AppMenuItem(this.name, this.icon);
}

class CardMenu extends StatefulWidget {
  const CardMenu({
    Key? key,
    required this.menu,
    required this.controller,
  }) : super(key: key);

  final Map<String, AppMenuItem> menu;
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
    final size = widget.menu.length;
    final scale = 1.0 / (size - 1);
    widget.controller._setter = (f) {
      setState(f);
      final index =
          widget.menu.keys.toList().indexOf(widget.controller._currentRoute);
      dev.log(
          "widget.controller._currentRoute: ${widget.controller.currentRoute}");
      dev.log("indexL: $index");

      _controller.animateTo(index * scale);
    };
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CardMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final menuCount = widget.menu.length;
    final menuHeight = (size + space) * menuCount;
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
                    top: _controller.value *
                        (size + space + 1) *
                        (menuCount - 1),
                    left: 0,
                    right: 0,
                    height: size + space,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(colors: [
                            Colors.pink,
                            Colors.red,
                          ])),
                    )),
              ),
              Container(
                height: menuHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: widget.menu.entries.map((e) {
                    bool isActive = e.key == widget.controller.currentRoute;
                    return InkWell(
                        onTap: isActive
                            ? () {}
                            : () {
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
