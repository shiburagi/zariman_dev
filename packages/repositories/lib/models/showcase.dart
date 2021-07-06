class Showcase {
  String? preview;
  String? title;
  String? description;
  List<String>? tags;
  List<Actions>? actions;
  List<Platforms>? platforms;

  Showcase(
      {this.preview,
      this.title,
      this.description,
      this.tags,
      this.actions,
      this.platforms});

  Showcase.fromJson(Map<String, dynamic> json) {
    this.preview = json["preview"];
    this.title = json["title"];
    this.description = json["description"];
    this.tags = json["tags"] == null ? null : List<String>.from(json["tags"]);
    this.actions = json["actions"] == null
        ? null
        : (json["actions"] as List).map((e) => Actions.fromJson(e)).toList();
    this.platforms = json["platforms"] == null
        ? null
        : (json["platforms"] as List)
            .map((e) => Platforms.fromJson(e))
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["preview"] = this.preview;
    data["title"] = this.title;
    data["description"] = this.description;
    if (this.tags != null) data["tags"] = this.tags;
    if (this.actions != null)
      data["actions"] = this.actions?.map((e) => e.toJson()).toList();
    if (this.platforms != null)
      data["platforms"] = this.platforms?.map((e) => e.toJson()).toList();
    return data;
  }
}

class Platforms {
  String? icon;
  String? family;
  String? package;

  Platforms({this.icon, this.family, this.package});

  Platforms.fromJson(Map<String, dynamic> json) {
    this.icon = json["icon"];
    this.family = json["family"];
    this.package = json["package"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["icon"] = this.icon;
    data["family"] = this.family;
    data["package"] = this.package;
    return data;
  }
}

class Actions {
  String? label;
  String? url;
  String? color;

  Actions({this.label, this.url, this.color});

  Actions.fromJson(Map<String, dynamic> json) {
    this.label = json["label"];
    this.url = json["url"];
    this.color = json["color"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["label"] = this.label;
    data["url"] = this.url;
    data["color"] = this.color;
    return data;
  }
}
