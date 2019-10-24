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
  List<DocumentSnapshot> userGames = new List<DocumentSnapshot>();
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

  @override
  Widget build(BuildContext context) {
    userID = Provider.of<FirebaseUser>(context).uid;
    loadUserGames(userID);
    return SingleChildScrollView(
      child: userGames.length == 0
          ? Container(
              color: Colors.red,
            )
          : Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  listTitle(),
                  getLatestGames(),
                ],
              ),
            ),
    );
  }

  loadUserGames(userID) {
    List<DocumentSnapshot> allGames;
    Firestore.instance.collection('games').getDocuments().then((querySnapshot) {
      allGames = querySnapshot.documents;
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
                    ', ' +
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
              onTap: () {
                print(game.documentID.toString());
              },
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
