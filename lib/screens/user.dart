import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.red,
        child: Center(
          child: StreamBuilder(
            stream: Firestore.instance.collection('courses').snapshots(),
            builder: (context, snap) {
              if (snap.hasData) {
                print(snap.data.documents[0]['address']);
                return Text(snap.data.documents[0]['address'].toString());
              }
              return Text('noData');
            },
          ),
        ),
      ),
    );
  }
}
