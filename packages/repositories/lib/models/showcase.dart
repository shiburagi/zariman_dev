class Showcase {
  String? title;
  String? preview;
  String? description;
  List<String>? tags;
  List<Actions>? actions;
  List<Platforms>? platforms;

  Showcase(
      {this.title,
      this.preview,
      this.description,
      this.tags,
      this.actions,
      this.platforms});

  Showcase.fromJson(Map<String, dynamic> json) {
    if (json["title"] is String) {
      title = json["title"];
    }
    if (json["preview"] is String) {
      preview = json["preview"];
    }
    if (json["description"] is String) {
      description = json["description"];
    }
    if (json["tags"] is List) {
      tags = json["tags"] == null ? null : List<String>.from(json["tags"]);
    }
    if (json["actions"] is List) {
      actions = json["actions"] == null
          ? null
          : (json["actions"] as List).map((e) => Actions.fromJson(e)).toList();
    }
    if (json["platforms"] is List) {
      platforms = json["platforms"] == null
          ? null
          : (json["platforms"] as List)
              .map((e) => Platforms.fromJson(e))
              .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["title"] = title;
    _data["preview"] = preview;
    _data["description"] = description;
    if (tags != null) {
      _data["tags"] = tags;
    }
    if (actions != null) {
      _data["actions"] = actions?.map((e) => e.toJson()).toList();
    }
    if (platforms != null) {
      _data["platforms"] = platforms?.map((e) => e.toJson()).toList();
    }
    return _data;
  }
}

class Platforms {
  String? icon;
  String? family;
  String? package;

  Platforms({this.icon, this.family, this.package});

  Platforms.fromJson(Map<String, dynamic> json) {
    if (json["icon"] is String) {
      icon = json["icon"];
    }
    if (json["family"] is String) {
      family = json["family"];
    }
    if (json["package"] is String) {
      package = json["package"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["icon"] = icon;
    _data["family"] = family;
    _data["package"] = package;
    return _data;
  }
}

class Actions {
  String? label;
  String? url;
  List<String>? colors;

  Actions({this.label, this.url, this.colors});

  Actions.fromJson(Map<String, dynamic> json) {
    if (json["label"] is String) {
      label = json["label"];
    }
    if (json["url"] is String) {
      url = json["url"];
    }
    if (json["colors"] is List) {
      colors =
          json["colors"] == null ? null : List<String>.from(json["colors"]);
    }
  }

  static List<Actions> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => Actions.fromJson(map)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["label"] = label;
    _data["url"] = url;
    if (colors != null) {
      _data["colors"] = colors;
    }
    return _data;
  }

  Actions copyWith({
    String? label,
    String? url,
    List<String>? colors,
  }) =>
      Actions(
        label: label ?? this.label,
        url: url ?? this.url,
        colors: colors ?? this.colors,
      );
}
