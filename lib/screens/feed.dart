import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discgolf/screens/invite_friends.dart' as prefix0;
import 'package:intl/date_symbol_data_local.dart';
import 'package:discgolf/screens/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:discgolf/utils/colors.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  //List<DocumentSnapshot> allGames;
  List<DocumentSnapshot> userGames;
  List<DocumentSnapshot> courses;
  List<DocumentSnapshot> users;
  String userID;
  bool loaded = false;
  @override
  initState() {
    super.initState();
    Firestore.instance
        .collection('courses')
        .getDocuments()
        .then((querySnapshot) {
      courses = querySnapshot.documents.toList();
    });
    Firestore.instance.collection('users').getDocuments().then((querySnapshot) {
      users = querySnapshot.documents.toList();
    });
  }

  Map game;
  bool open = false;
  @override
  Widget build(BuildContext context) {
    userID = Provider.of<FirebaseUser>(context).uid;
    if (userGames == null) loadUserGames(userID);
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          listTitle(),
          Stack(
            children: <Widget>[
              userGames == null
                  ? Container()
                  : OldGameList(
                      courses: courses,
                      userGames: userGames,
                      users: users,
                      onPressed: (Map g) {
                        setState(() {
                          game = g;
                          open = true;
                        });
                      },
                    ),
              IgnorePointer(
                ignoring: !open,
                child: Stack(
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => setState(() {
                        open = false;
                      }),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - 156,
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: open ? 1 : 0,
                      duration: Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      child: Container(
                        margin: EdgeInsets.all(10),
                        height: 450,
                        color: mainColor,
                        child: Text(game.toString(),
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  loadUserGames(userID) {
    List<DocumentSnapshot> allGames;
    Firestore.instance
        .collection('games')
        .orderBy('date', descending: true)
        .limit(3)
        .getDocuments()
        .then((querySnapshot) {
      allGames = querySnapshot.documents;
      userGames = List();
      allGames.forEach((game) {
        List keys = game.data['players'].keys.toList();
        keys.forEach((key) {
          if (key == userID) {
            userGames.add(game);
          }
        });
      });
      if (!loaded) {
        loaded = true;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    userGames = null;
  }

  Row listTitle() {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 10,
        ),
        Text(
          'Senaste spel',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }
}

class OldGameList extends StatelessWidget {
  final List<DocumentSnapshot> userGames;
  final List<DocumentSnapshot> courses;
  final List<DocumentSnapshot> users;
  final Function onPressed;
  OldGameList({this.userGames, this.courses, this.users, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        userGames.length == 0
            ? Container(
                padding: EdgeInsets.all(30),
                child: Container(
                  decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.all(1),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(7)),
                    child: Text('Du har inte spelat några spel än',
                        style: TextStyle(fontSize: 15)),
                  ),
                ),
              )
            : Container(
                padding: EdgeInsets.all(10),
                child: getLatestGames(),
              ),
      ],
    ));
  }

  getLatestGames() {
    List<Widget> tiles = new List<Widget>();
    userGames.forEach((game) {
      initializeDateFormatting("sv_SV", null).then((_) =>
          {print(new DateFormat.yMd().format(game.data['date'].toDate()))});

      tiles.add(Card(
        color: mainColor,
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text(
                getCourseNameFromID(game.data['courseID'].toString()),
                style:
                    TextStyle(color: accentColor, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                playersByNames(game.data['players'].keys.toList()) +
                    game.data['track'].toString() +
                    ',    ' +
                    new DateFormat.yMd()
                        .format(game.data['date'].toDate())
                        .toString(),
                style: TextStyle(color: textColor),
              ),
              trailing: Icon(
                Icons.more_vert,
                color: textColor,
              ),
              onTap: () => onPressed(game.data),
            )
          ],
        ),
      ));
    });
    return Column(children: tiles);
  }

  getCourseNameFromID(courseID) {
    String name = 'Could not find course id';
    courses.forEach((course) {
      if (course.documentID.toString() == courseID.toString()) {
        name = course['name'];
      }
    });
    return name;
  }

  playersByNames(List friends) {
    var friendString = new StringBuffer();
    users.forEach((user) {
      friends.forEach((friend) {
        if (user.documentID == friend)
          friendString.write(user['firstname'] + ', ');
      });
    });
    return friendString.toString();
  }
}
