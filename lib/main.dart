import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

const FlutterAppAuth appAuth = FlutterAppAuth();
AuthorizationServiceConfiguration serviceConfiguration =
    AuthorizationServiceConfiguration(
        authorizationEndpoint:
            dotenv.get('OAUTH_AUTHORIZE_ENDPOINT', fallback: ''),
        tokenEndpoint: dotenv.get('OAUTH_TOKEN_ENDPOINT', fallback: ''));

Future<void> main() async {
  await dotenv.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

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

class _MyHomePageState extends State<MyHomePage> {
  Future<String> getOAuthToken() async {
    final clientId = dotenv.get('OAUTH_CLIENT_ID', fallback: '');
    final redirectUrl = dotenv.get('OAUTH_REDIRECT_URL', fallback: '');
    final String scopesString = dotenv.get('OAUTH_SCOPES', fallback: '');
    final List<String> scopes = scopesString.split(',');

    final authenticateRequest = AuthorizationRequest(clientId, redirectUrl,
        serviceConfiguration: serviceConfiguration, scopes: scopes);

    final AuthorizationResponse? authorizationResponse =
        await appAuth.authorize(authenticateRequest);

    final tokenRequest = TokenRequest(clientId, redirectUrl,
        serviceConfiguration: serviceConfiguration,
        scopes: scopes,
        grantType: 'authorization_code',
        codeVerifier: authorizationResponse?.codeVerifier,
        authorizationCode: authorizationResponse?.authorizationCode);

    final tokenResult = await appAuth.token(tokenRequest);

    return tokenResult?.accessToken ?? '';
  }

  Future<void> login() async {
    final String oAuthToken = await getOAuthToken();
    // final String userInfo = await getUserInfo(oAuthToken);

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProfilePage(oAuthToken: oAuthToken)));

    // log(userInfo);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text('Login with UNiDAYS'),
              onPressed: login,
              style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.lightBlue.shade900)),
            )
          ],
        ),
      ),
    );
  }
}
