import 'location_app.dart' if (dart.library.html) 'location_web.dart'
    as location;

void updateLocation(String route) {
  location.updateLocation(route);
}

String? get locationPath => location.locationPath;
