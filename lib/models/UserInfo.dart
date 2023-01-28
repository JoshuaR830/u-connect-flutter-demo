class UserInfo {
  final String sub;
  final String givenName;
  final String familyName;
  final String name;

  const UserInfo(
      {required this.sub,
      required this.givenName,
      required this.familyName,
      required this.name});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
        sub: json['sub'],
        givenName: json['given_name'],
        familyName: json['family_name'],
        name: json['name']);
  }
}