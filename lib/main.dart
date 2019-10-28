import 'package:discgolf/screens/course.dart';
import 'package:discgolf/screens/home.dart';
import 'package:discgolf/screens/invite_friends.dart';
import 'package:discgolf/screens/map.dart';
import 'package:discgolf/screens/overview.dart';
import 'package:discgolf/screens/playScreen.dart';
import 'package:discgolf/screens/register.dart';
import 'package:discgolf/screens/signin.dart';
import 'package:discgolf/screens/test.dart';
import 'package:discgolf/screens/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(Main());

class Main extends StatelessWidget {
  var routes = {
    'home': (context) => Home(),
    'main': (context) => Main(),
    'register': (context) => RegisterScreen(),
    'play': (context) => PlayScreen(),
    'mapTest': (context) => MapTest(),
    'inviteFriends': (context) => InviteFriends(),
    'user': (context) => UserScreen(),
    'course': (context) => CourseScreen(),
    'overview': (context) => Overview(),
  };
  @override
  Widget build(BuildContext context) {
    print(routes);
    return MultiProvider(
      providers: [
        StreamProvider<FirebaseUser>.value(
          value: FirebaseAuth.instance.onAuthStateChanged,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DiscGolf',
        // home: Scaffold(body: Center(child: Test())),
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

ThemeData appTheme() {
  final ThemeData theme = ThemeData.dark();

  return theme.copyWith(
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.grey,
      secondaryHeaderColor: Colors.blue);
}
