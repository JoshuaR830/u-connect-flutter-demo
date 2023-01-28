class InstitutionInfo {
  String sub;
  String name;
  String country;

  InstitutionInfo(
      {required this.sub, required this.name, required this.country});

  factory InstitutionInfo.fromJson(Map<String, dynamic> data) {
    final sub = data['sub'] ?? '';
    final name = data['name'] ?? '';
    final country = data['country'] ?? '';

    return InstitutionInfo(sub: sub, name: name, country: country);
  }
}