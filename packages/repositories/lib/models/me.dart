class Me {
  String? name;
  String? expertise;
  String? location;
  String? image;
  String? summary;
  List<String>? languages;
  List<Socials>? socials;

  Me(
      {this.name,
      this.expertise,
      this.location,
      this.image,
      this.summary,
      this.languages,
      this.socials});

  Me.fromJson(Map<String, dynamic> json) {
    this.name = json["name"];
    this.expertise = json["expertise"];
    this.location = json["location"];
    this.image = json["image"];
    this.summary = json["summary"];
    this.languages =
        json["languages"] == null ? null : List<String>.from(json["languages"]);
    this.socials = json["socials"] == null
        ? null
        : (json["socials"] as List).map((e) => Socials.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["name"] = this.name;
    data["expertise"] = this.expertise;
    data["location"] = this.location;
    data["image"] = this.image;
    data["summary"] = this.summary;
    if (this.languages != null) data["languages"] = this.languages;
    if (this.socials != null)
      data["socials"] = this.socials?.map((e) => e.toJson()).toList();
    return data;
  }
}

class Socials {
  String? label;
  String? url;
  String? icon;
  String? family;
  String? package;

  Socials({this.label, this.url, this.icon, this.family, this.package});

  Socials.fromJson(Map<String, dynamic> json) {
    this.label = json["label"];
    this.url = json["url"];
    this.icon = json["icon"];
    this.family = json["family"];
    this.package = json["package"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["label"] = this.label;
    data["url"] = this.url;
    data["icon"] = this.icon;
    data["family"] = this.family;
    data["package"] = this.package;
    return data;
  }
}
