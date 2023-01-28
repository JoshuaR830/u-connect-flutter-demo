import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'models/InstitutionInfo.dart';
import 'models/ProfileInfo.dart';
import 'models/UserInfo.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.oAuthToken});

  final String oAuthToken;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<ProfileInfo> profileInfo;

  @override
  ProfilePage get widget => super.widget;

  Future<ProfileInfo> getProfileInfo(String oAuthToken) async {
    final userInfoResponse = await http.get(
      Uri.parse(dotenv.get('USER_INFO_ENDPOINT', fallback: '')),
      headers: {'Authorization': 'Bearer $oAuthToken'},
    );

    final institutionResponse = await http.get(
      Uri.parse(dotenv.get('INSTITUTION_INFO_ENDPOINT', fallback: '')),
      headers: {'Authorization': 'Bearer $oAuthToken'},
    );

    log(jsonDecode(userInfoResponse.body).toString());
    log(jsonDecode(institutionResponse.body).toString());

    if (userInfoResponse.statusCode == 200 &&
        institutionResponse.statusCode == 200) {
      final userInfo = UserInfo.fromJson(jsonDecode(userInfoResponse.body));
      final institutionInfo =
          InstitutionInfo.fromJson(jsonDecode(institutionResponse.body));
      return ProfileInfo(
          userSub: userInfo.sub,
          uniSub: institutionInfo.sub,
          country: institutionInfo.country,
          givenName: userInfo.givenName,
          familyName: userInfo.familyName,
          name: userInfo.name,
          institutionName: institutionInfo.name);
    }

    throw Exception('Failed to load user data');
  }

  @override
  void initState() {
    super.initState();
    profileInfo = getProfileInfo(widget.oAuthToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: FutureBuilder<ProfileInfo>(
            future: profileInfo,
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
                    Text('User: ${snapshot.data!.name}'),
                    const SizedBox(height: 10),
                    Text('Country: ${snapshot.data!.country}'),
                    const SizedBox(height: 10),
                    Text('Institution: ${snapshot.data!.institutionName}'),
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
