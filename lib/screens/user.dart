import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discgolf/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FriendList(),
          SizedBox(
            height: 10,
          ),
          FriendList(requests: true),
          Text(Provider.of<FirebaseUser>(context).uid),
          Center(
            child: RaisedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, 'main');
              },
              child: Text('Sign out'),
            ),
          ),
        ],
      ),
    ));
  }
}

class FriendList extends StatelessWidget {
  final bool requests;
  FriendList({this.requests = false});
  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<FirebaseUser>(context).uid;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              width: 5,
            ),
            Text(requests ? 'Förfrågningar' : 'Vänner',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
        Container(
          child: StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data['friend_requests'] != null && requests) {
                    return Column(
                        children: snapshot.data['friend_requests']
                            .map<Widget>((friend) {
                      return FriendRequestCard(friend);
                    }).toList());
                  }
                  if (snapshot.data['friends'] != null && !requests) {
                    return Column(
                        children:
                            snapshot.data['friends'].map<Widget>((friend) {
                      return FriendCard(friend);
                    }).toList());
                  }

                  // return Column(
                  //   children: requests
                  //       ? snapshot.data['friend_requests']
                  //           .map<Widget>((friend) {
                  //           return FriendRequestCard(friend);
                  //         }).toList()
                  //       : snapshot.data['friends'].map<Widget>((friend) {
                  //           return FriendCard(friend);
                  //         }).toList(),
                  // );
                }
                return Container();
              }),
        ),
      ],
    );
  }
}

class FriendCard extends StatelessWidget {
  final String friend;
  FriendCard(this.friend);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: mainColor,
      child: ListTile(
          trailing: Icon(
            Icons.navigate_next,
            color: textColor,
          ),
          title: getFriendName(friend)),
    );
  }
}

class FriendRequestCard extends StatelessWidget {
  final String friend;
  FriendRequestCard(this.friend);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: mainColor,
      child: ListTile(
          trailing: Container(
            width: 70,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(
                  Icons.check,
                  color: Colors.green,
                ),
                Icon(
                  Icons.close,
                  color: Colors.red,
                ),
              ],
            ),
          ),
          title: getFriendName(friend)),
    );
  }
}

getFriendName(String friend) {
  return StreamBuilder(
    stream: Firestore.instance.collection('users').document(friend).snapshots(),
    builder: (context, snapshot) {
      String name = '';
      if (snapshot.hasData) name = snapshot.data.data['email'];
      return Text(name,
          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold));
    },
  );
}
