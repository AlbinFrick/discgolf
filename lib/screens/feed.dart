import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discgolf/screens/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  //List<DocumentSnapshot> allGames;
  List<DocumentSnapshot> userGames = new List<DocumentSnapshot>();
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String userID = Provider.of<FirebaseUser>(context).uid;
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
        List keys;
        if (game.data['players'].length > 1) {
          keys = game.data['players'].keys.toList();
        } else {
          // if (game.data['players'].keys == userID) {
          //   userGames.add(game);
          // }
          print('suckmadick');
        }
        print(keys.toString());
        // List keys = game.data['players'].keys.toList();
        // print(keys[0] + 'asasdasdasasdasdasda');
        // print(keys.toString());
        // Map keys = game.data['players'].keys;
        // keys.forEach((key) {
        //   if (key == userID) {
        //     userGames.add(game);
        //   }
        // });
      });
      // userGames.forEach((game) {
      //   print('BAAAAAAAAAAAAAAAAAAAAJJJJS');
      //   print(game.data.toString());
      // });
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
    return Column(
      children: <Widget>[
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(userGames[0].data['courseID'].toString()),
                subtitle: Text(userGames[0].data['date'].toString() +
                    ', ' +
                    userGames[0].data['track'].toString()),
              ),
            ],
          ),
        )
      ],
    );
  }
}
