import 'dart:html' as html;

void updateLocation(String route) {
  html.window.history.pushState({}, '', '$route');
}

String? get locationPath => html.window.location.pathname;
