import 'package:discgolf/screens/home.dart';
import 'package:discgolf/screens/register.dart';
import 'package:discgolf/screens/signin.dart';
import 'package:discgolf/screens/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(Main());
var routes = {
  'home': (context) => Home(),
  'main': (context) => Main(),
  'register': (context) => RegisterScreen()
};

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiscGolf',
      theme: ThemeData(),
      home: FutureBuilder(
        future: userLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data ? Home() : SignInScreen();
          }
          return Container(
            //splash
            color: Colors.black,
          );
        },
      ),
      routes: routes,
    );
  }

  userLoggedIn() async {
    bool loggedIn = await FirebaseAuth.instance.currentUser() != null;
    return loggedIn;
  }
}
