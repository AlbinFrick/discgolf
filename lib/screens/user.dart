import 'package:discgolf/bloc/user_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class User extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserBloc userBloc = Provider.of<UserBloc>(context);
    return Scaffold(
        body: Container(
      color: Colors.green[500],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(userBloc.uid.toString()),
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
