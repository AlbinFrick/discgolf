import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discgolf/screens/user.dart';
import 'package:discgolf/utils/colors.dart';
import 'package:discgolf/widgets/list_title.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InviteFriends extends StatelessWidget {
  DocumentSnapshot userSnapshot;
  getPlayerFriends(String uid) async {
    userSnapshot =
        await Firestore.instance.collection('users').document(uid).get();
    List<String> friendIDs = List<String>.from(userSnapshot.data['friends']);
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
      user.data['index'] = i;
      // if (user != null && user.data != null)
      friends.add(user.data);
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
              return FriendAdder(friends: snapshot.data, user: userSnapshot);
            return Container(
                // color: Colors.black,
                );
          },
        ));
  }
}

class FriendAdder extends StatefulWidget {
  final List friends;
  final DocumentSnapshot user;
  FriendAdder({this.friends, this.user});

  @override
  _FriendAdderState createState() => _FriendAdderState();
}

class _FriendAdderState extends State<FriendAdder> {
  List addedPlayers = List();
  var user;

  @override
  void initState() {
    super.initState();
    // loadUser();
    addedPlayers.add(widget.user);
  }

  // loadUser(uid) async {
  //   DocumentSnapshot userSnapshot =
  //       await Firestore.instance.collection('users').document(uid).get();
  //   user = userSnapshot.data;
  //   setState(() {
  //     addedPlayers.add(user);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // final String uid = Provider.of<FirebaseUser>(context).uid;
    // if (user == null) loadUser(uid);
    return Container(
      padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 5),
          ListTitle('Spelare'),
          PlayersList(
              players: addedPlayers,
              onRemove: (player, e) {
                setState(() {
                  widget.friends.insert(player['index'], player);
                  addedPlayers.remove(player);
                });
              }),
          ListTitle('Vänner'),
          Flexible(
            flex: 2,
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
      shrinkWrap: true,
      itemCount: players.length,
      itemBuilder: (context, index) {
        return FriendCard(
          dismissable: true,
          friend: players[index],
          onAdd: (a, b) {
            onRemove(players[index], 'a');
          },
        );
        // );
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
    //removes the friend, but keeps the length of the list.
    friends[index] = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        var friend = friends[index];
        if (friend != null)
          return FriendCard(
              friend: friends[index], onAdd: onAddList, index: index);
        return Container();
      },
    ));
  }
}

class FriendCard extends StatelessWidget {
  final Function onAdd;
  final friend;
  final bool dismissable;
  final int index;
  FriendCard(
      {@required this.friend,
      @required this.onAdd,
      this.index,
      this.dismissable = false});
  @override
  Widget build(BuildContext context) {
    Card friendCard = Card(
      elevation: 4,
      color: mainColor,
      margin: EdgeInsets.all(dismissable ? 0 : 4),
      child: ListTile(
          title: Text(
        friend['email'],
        style: TextStyle(
            fontSize: 15, color: accentColor, fontWeight: FontWeight.bold),
      )),
    );
    return dismissable
        ? Padding(
            padding: EdgeInsets.all(4),
            child: Dismissible(
              direction: DismissDirection.endToStart,
              key: Key(friend['index'].toString()),
              child: friendCard,
              onDismissed: (dir) {
                onAdd(friend, index);
              },
              background: Card(
                color: Colors.red[800],
                child: Align(
                    alignment: Alignment(0.95, 0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    )),
              ),
            ))
        : GestureDetector(
            onTap: () {
              onAdd(friend, index);
            },
            child: friendCard);
  }
}
