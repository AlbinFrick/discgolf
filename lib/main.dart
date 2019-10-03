import 'package:discgolf/screens/home.dart';
import 'package:discgolf/screens/signin.dart';
import 'package:discgolf/screens/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(Main());
var routes = {'home': (context) => Home(), 'main': (context) => Main()};

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiscGolf',
      theme: ThemeData(),
      home: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data.displayname != null ? Home() : SignInScreen();
          }
          print(snapshot);
          return Container(
            color: Colors.yellow,
          );
        },
      ),
      routes: routes,
    );
  }
}
