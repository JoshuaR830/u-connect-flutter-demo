import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.oAuthToken});

  final String oAuthToken;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

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

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserInfo> userInfo;

  @override
  ProfilePage get widget => super.widget;

  Future<UserInfo> getUserInfo(String oAuthToken) async {
    final response = await http.get(
      Uri.parse(dotenv.get('USER_INFO_ENDPOINT', fallback: '')),
      headers: {'Authorization': 'Bearer $oAuthToken'},
    );

    if (response.statusCode == 200) {
      return UserInfo.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to load user data');
  }

  @override
  void initState() {
    super.initState();
    userInfo = getUserInfo(widget.oAuthToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: FutureBuilder<UserInfo>(
            future: userInfo,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // https://www.flutterbeads.com/circular-image-in-flutter/
                    CircleAvatar(
                      backgroundColor: Colors.lightBlue.shade900,
                      radius: 120,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://images.unidays.world/i/self-serve/customer/logo/placeholder/placeholder-logo-${snapshot.data!.name[0].toLowerCase()}.png'),
                        radius: 110,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(snapshot.data!.name),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            }),
      ),
    );
  }
}