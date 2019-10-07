import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

getFriendName(friend) async {
  Stream<DocumentSnapshot> doc =
      await Firestore.instance.collection('users').document(friend).snapshots();
}
