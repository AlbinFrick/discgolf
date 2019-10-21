import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///Removes the friend with the given friendID from the currently logged in user.
class FireUtils {
  static _getUser(uid) async {
    DocumentSnapshot user =
        await Firestore.instance.collection('users').document(uid).get();
    return user;
  }

  static _updateUser(String uid, Map<String, dynamic> data) {
    Firestore.instance.collection('users').document(uid).updateData(data);
  }

  static _getUserFriends(uid) async {
    var user = await _getUser(uid);
    List<String> friends;
    if (user.data['friends'] is List) {
      friends = List<String>.from(user.data['friends']);
    } else {
      friends = List();
    }
    return friends;
  }

  static _getUserFriendRequests(uid, context) async {
    var user = await _getUser(uid);
    List<String> friendRequests =
        List<String>.from(user.data['friend_requests']);
    return friendRequests;
  }

  static removeUserFriend({@required friendID, @required context}) async {
    final String uid = Provider.of<FirebaseUser>(context).uid;
    var friends = await _getUserFriends(uid);
    friends.remove(friendID);
    _updateUser(uid, {'friends': friends});
  }

  static removeUserFriendRequest(
      {@required friendID, @required context}) async {
    final String uid = Provider.of<FirebaseUser>(context).uid;
    var friendRequests = await _getUserFriendRequests(uid, context);
    friendRequests.remove(friendID);
    _updateUser(uid, {'friend_requests': friendRequests});
  }

  static addUserFriend({@required friendID, @required context}) async {
    final String uid = Provider.of<FirebaseUser>(context).uid;
    List<String> friends = await _getUserFriends(uid);
    if (!friends.contains(friendID)) {
      friends.add(friendID);
      _updateUser(uid, {'friends': friends});
    }
  }

  ///This method adds the users id as a friend to another user.
  ///Meant to be called when the user accepts a friend request.
  static addUserToFriend({@required friendID, @required context}) async {
    final String uid = Provider.of<FirebaseUser>(context).uid;
    var friends = await _getUserFriends(friendID);
    friends.add(uid);
    _updateUser(friendID, {'friends': friends});
  }

  static addUserFriendRequest(
      {@required friendEmail, @required context}) async {
    final String uid = Provider.of<FirebaseUser>(context).uid;
    QuerySnapshot friend = await Firestore.instance
        .collection('users')
        .where('email', isEqualTo: friendEmail)
        .getDocuments();
    List friends = await _getUserFriends(uid);
    bool alreadyFriends = false;
    if ((friend.documents.length > 0))
      alreadyFriends = friends.contains(friend.documents[0].documentID);
    if (friend.documents.length == 0 || alreadyFriends) {
      return false;
    }
    var friendRequests = friend.documents[0]['friend_requests'];

    if (friendRequests is List && !friendRequests.contains(uid)) {
      friendRequests =
          List<String>.from(friend.documents[0]['friend_requests']);
    } else {
      friendRequests = List<String>();
    }
    friendRequests.add(uid);
    _updateUser(
        friend.documents[0].documentID, {'friend_requests': friendRequests});
    return true;
  }
}
