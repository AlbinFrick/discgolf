import 'package:discgolf/screens/course.dart';
import 'package:discgolf/screens/home.dart';
import 'package:discgolf/screens/invite_friends.dart';
import 'package:discgolf/screens/map.dart';
import 'package:discgolf/screens/register.dart';
import 'package:discgolf/screens/signin.dart';
import 'package:discgolf/screens/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(Main());
var routes = {
  'home': (context) => Home(),
  'main': (context) => Main(),
  'register': (context) => RegisterScreen(),
  'mapTest': (context) => MapTest(),
  'inviteFriends': (context) => InviteFriends(),
  'user': (context) => UserScreen(),
  'course': (context) => CourseScreen()
};

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(
          value: FirebaseAuth.instance.onAuthStateChanged,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DiscGolf',
        theme: ThemeData(),
        home: CheckLogin(),
        routes: routes,
      ),
    );
  }

  userLoggedIn(BuildContext context) async {
    print('working');
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      return user.uid;
    }
    return '';
  }
}

class CheckLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (Provider.of<FirebaseUser>(context) == null) return SignInScreen();
    return Home();
    // var user = Provider.of<FirebaseUser>(context);
    // return user.uid != null ? Home() : SignInScreen();
  }
}
