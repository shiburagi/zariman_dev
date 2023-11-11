class Experience {
  Company? company;
  String? startDate;
  String? endDate;
  String? position;
  List<String>? summary;

  Experience(
      {this.company,
      this.startDate,
      this.endDate,
      this.position,
      this.summary});

  Experience.fromJson(Map<String, dynamic> json) {
    if (json["company"] is Map) {
      company =
          json["company"] == null ? null : Company.fromJson(json["company"]);
    }
    if (json["startDate"] is String) {
      startDate = json["startDate"];
    }
    if (json["endDate"] is String) {
      endDate = json["endDate"];
    }
    if (json["position"] is String) {
      position = json["position"];
    }
    if (json["summary"] is List) {
      summary =
          json["summary"] == null ? null : List<String>.from(json["summary"]);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    if (company != null) {
      _data["company"] = company?.toJson();
    }
    _data["startDate"] = startDate;
    _data["endDate"] = endDate;
    _data["position"] = position;
    if (summary != null) {
      _data["summary"] = summary;
    }
    return _data;
  }
}

class Company {
  String? name;

  Company({this.name});

  Company.fromJson(Map<String, dynamic> json) {
    if (json["name"] is String) {
      name = json["name"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["name"] = name;
    return _data;
  }
}
