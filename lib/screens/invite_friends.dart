import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discgolf/screens/user.dart';
import 'package:discgolf/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InviteFriends extends StatelessWidget {
  getPlayerFriends(String uid) async {
    DocumentSnapshot userSnapshot =
        await Firestore.instance.collection('users').document(uid).get();
    List<String> friendIDs = List<String>.from(userSnapshot.data['friends']);s
    List<Map<String, dynamic>> friends = List();
    friends = await getFriends(friendIDs, friends);
    print('friends done loading');
    return friends;
  }

  getFriends(friendIDs, friends) async {
    for (var i = 0; i < friendIDs.length; i++) {
      DocumentSnapshot user = await Firestore.instance
          .collection('users')
          .document(friendIDs[i])
          .get();
      if (user != null && user.data != null) friends.add(user.data);
    }
    return friends;
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context).settings.arguments;
    final String uid = Provider.of<FirebaseUser>(context).uid;

    return Scaffold(
        appBar: AppBar(
          title: Text(args['name']),
          backgroundColor: mainColor,
        ),
        body: FutureBuilder(
          future: getPlayerFriends(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done)
              return FriendAdder(friends: snapshot.data);
            return Container(
                // color: Colors.black,
                );
          },
        ));
  }
}

class FriendAdder extends StatefulWidget {
  final List friends;
  FriendAdder({this.friends});

  @override
  _FriendAdderState createState() => _FriendAdderState();
}

class _FriendAdderState extends State<FriendAdder> {
  List addedPlayers = List();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Flexible(
            child: PlayersList(
                players: addedPlayers,
                onRemove: (player, e) {
                  setState(() {
                    widget.friends.add(player);
                    addedPlayers.remove(player);
                  });
                }),
          ),
          Flexible(
            child: FriendList(
                friends: widget.friends,
                onAdd: (player) {
                  setState(() {
                    addedPlayers.add(player);
                  });
                }),
          ),
        ],
      ),
    );
  }
}

class PlayersList extends StatelessWidget {
  final List players;
  final Function onRemove;
  PlayersList({this.players, this.onRemove});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        return FriendCard(
          friend: players[index],
          onAdd: (a, b) {
            onRemove(players[index], 'a');
          },
        );
      },
    ));
  }
}

class FriendList extends StatelessWidget {
  final Function onAdd;
  final List friends;

  FriendList({this.friends, this.onAdd});

  onAddList(player, index) {
    onAdd(player);
    friends.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    // final String uid = Provider.of<FirebaseUser>(context).uid;

    return Container(
        child: ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        return FriendCard(
            friend: friends[index], onAdd: onAddList, index: index);
      },
    ));
  }
}

class FriendCard extends StatelessWidget {
  final Function onAdd;
  final friend;
  final int index;
  FriendCard({@required this.friend, @required this.onAdd, this.index});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onAdd(friend, index),
      child: Card(
        color: Colors.red,
        child: ListTile(leading: Text(friend['email'])),
      ),
    );
  }
}
