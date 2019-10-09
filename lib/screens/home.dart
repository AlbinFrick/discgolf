import 'dart:developer';

import 'package:discgolf/screens/courses.dart';
import 'package:discgolf/screens/feed.dart';
import 'package:discgolf/screens/user.dart';
import 'package:discgolf/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool dialogDismissed = false;
  bool registerDialog = false;
  int bodyIndex = 1;

  changeHomeIndex(int index) {
    setState(() {
      bodyIndex = index;
    });
  }

  dismissDialog() {
    setState(() {
      dialogDismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [FeedScreen(), CoursesScreen(), UserScreen()];
    List<Widget> headers = [
      AppBar(
        backgroundColor: mainColor,
        title: Text(
          'Flöde',
          style: TextStyle(color: Colors.white),
        ),
      ),
      AppBar(
        backgroundColor: mainColor,
        title: Text(
          'Spela',
          style: TextStyle(color: Colors.white),
        ),
      ),
      AppBar(
        backgroundColor: mainColor,
        title: Text(
          'Profil',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, 'main');
            },
            child: Icon(
              Icons.exit_to_app,
            ),
          ),
          SizedBox(
            width: 16,
          )
        ],
      ),
    ];
    final Map args = ModalRoute.of(context).settings.arguments;
    if (args != null) registerDialog = args['registered'] != null;
    var dialog = AlertDialog(
      actions: <Widget>[
        RaisedButton(
          onPressed: () {
            dismissDialog();
          },
          color: accentColor,
          child: Text(
            'Ok',
            style: TextStyle(color: mainColor),
          ),
        )
      ],
      title: Text('Registrering lyckades!',
          style: TextStyle(fontSize: 15, color: Colors.green)),
    );
    return Scaffold(
        appBar: headers[bodyIndex],
        bottomNavigationBar: bottomBar(),
        body: Stack(
          children: <Widget>[
            tabs[bodyIndex],
            registerDialog && !dialogDismissed ? dialog : Container()
          ],
        ));
  }

  bottomBar() {
    return Container(
      color: mainColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TabButton(
              onPress: changeHomeIndex,
              index: 0,
              icon: Icons.menu,
              focused: bodyIndex == 0),
          TabButton(
              onPress: changeHomeIndex,
              index: 1,
              icon: Icons.play_arrow,
              focused: bodyIndex == 1),
          TabButton(
              onPress: changeHomeIndex,
              index: 2,
              icon: Icons.person,
              focused: bodyIndex == 2)
        ],
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  final Function onPress;
  final int index;
  final IconData icon;
  final bool focused;
  TabButton({this.onPress, this.index, this.icon, this.focused});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => onPress(index),
        child: Container(
          width: 50,
          height: 50,
          child: Icon(
            icon,
            color: focused ? accentColor : Color.fromRGBO(230, 230, 230, 1),
            size: 30,
          ),
        ));
  }
}
