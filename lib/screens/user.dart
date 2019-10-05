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
      color: Colors.grey[700],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FriendList(),
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
            Text('Vänner',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 2,
          child: StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: snapshot.data['friends'].map<Widget>((friend) {
                      print(friend);
                      return FriendCard(friend);
                    }).toList(),
                  );
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
      color: Colors.white,
      child: ListTile(
          trailing: Icon(
            Icons.navigate_next,
            color: mainColor,
          ),
          title: getFriendName()),
    );
  }

  getFriendName() {
    return StreamBuilder(
      stream:
          Firestore.instance.collection('users').document(friend).snapshots(),
      builder: (context, snapshot) {
        String name = '';
        if (snapshot.hasData) name = snapshot.data.data['email'];
        return Text(name,
            style: TextStyle(color: accentColor, fontWeight: FontWeight.bold));
      },
    );
  }
}
