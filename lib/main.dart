import 'dart:developer';

import 'package:discgolf/screens/home.dart';
import 'package:discgolf/screens/map.dart';
import 'package:discgolf/screens/register.dart';
import 'package:discgolf/screens/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bloc/user_bloc.dart';

void main() => runApp(Main());
var routes = {
  'home': (context) => Home(),
  'main': (context) => Main(),
  'register': (context) => RegisterScreen(),
  'mapTest': (context) => MapTest()
};

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserBloc>.value(
      value: UserBloc(),
      child: MaterialApp(
        title: 'DiscGolf',
        theme: ThemeData(),
        home: FutureBuilder(
          future: userLoggedIn(context),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                addUserIDBloc(context, snapshot.data);
                return Home();
              }
              return SignInScreen();
            }
            return Container(
              //splash
              color: Colors.black,
            );
          },
        ),
        routes: routes,
      ),
    );
  }

  addUserIDBloc(BuildContext context, String uid) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    userBloc.setUserID(uid);
  }

  userLoggedIn(BuildContext context) async {
    print('working');
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      return user.uid;
    }
    return null;
    // bool loggedIn = user != null;
    // return loggedIn;
  }
}
