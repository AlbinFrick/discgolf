import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discgolf/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InviteFriends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(
          title: Text(args['name']),
          backgroundColor: mainColor,
        ),
        body: FriendAdder());
  }
}

class FriendAdder extends StatefulWidget {
  @override
  _FriendAdderState createState() => _FriendAdderState();
}

class _FriendAdderState extends State<FriendAdder> {
  List<String> addedPlayers = List();
  List<String> friends = List();

  getPlayerFriends(String uid) async {
    var hej = await Firestore.instance.collection('users').document(uid).get();
    friends = List<String>.from(hej.data['friends']);
    print('friends: $friends');
  }

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<FirebaseUser>(context).uid;
    if (friends.length < 1) getPlayerFriends(uid);
    return Container();
  }
}
