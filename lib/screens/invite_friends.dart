import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discgolf/utils/colors.dart';
import 'package:discgolf/utils/colors.dart' as prefix0;
import 'package:discgolf/widgets/list_title.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

DocumentSnapshot userSnapshot;
Future friends;
var friendsData;

class InviteFriends extends StatefulWidget {
  @override
  _InviteFriendsState createState() => _InviteFriendsState();
}

class _InviteFriendsState extends State<InviteFriends> {
  getPlayerFriends(String uid) async {
    userSnapshot =
        await Firestore.instance.collection('users').document(uid).get();
    List<String> friendIDs = List<String>.from(userSnapshot.data['friends']);
    List<Map<String, dynamic>> friends = List();
    friends = await getFriends(friendIDs, friends);
    return friends;
  }

  getFriends(friendIDs, friends) async {
    for (var i = 0; i < friendIDs.length; i++) {
      DocumentSnapshot user = await Firestore.instance
          .collection('users')
          .document(friendIDs[i])
          .get();
      user.data['index'] = i;
      user.data['id'] = friendIDs[i];
      friends.add(user.data);
    }
    return friends;
  }

  @override
  void dispose() {
    super.dispose();
    friendsData = null;
  }

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<FirebaseUser>(context).uid;
    // Map userData;
    // if (userSnapshot != null) {
    //   userData = userSnapshot.data;
    //   userData['id'] = uid;
    // }
    // userSnapshot['id'] = uid;
    if (friendsData == null) {
      friends = getPlayerFriends(uid);
      friends.then((data) {
        setState(() {
          friendsData = data;
        });
      });
    }
    final Map args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text(args['name']),
        backgroundColor: mainColor,
      ),
      body: friendsData == null
          ? Container(
              child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Laddar vänner...'),
                  CupertinoActivityIndicator()
                ],
              ),
            ))
          : FriendAdder(friends: friendsData, user: userSnapshot, args: args),
    );
  }
}

class FriendAdder extends StatefulWidget {
  final List friends;
  final DocumentSnapshot user;
  final Map args;
  FriendAdder({this.friends, this.user, this.args});

  @override
  _FriendAdderState createState() => _FriendAdderState();
}

class _FriendAdderState extends State<FriendAdder> {
  List addedPlayers = List();
  final TextEditingController _guestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // loadUser();
    addedPlayers.add(widget.user.data);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 5),
              ListTitle('Spelare'),
              PlayersList(
                  players: addedPlayers,
                  onRemove: (player, e) {
                    setState(() {
                      if (player['guest'] == null)
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
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: <Widget>[
                    ListTitle('Lägg till gäst'),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: TextFormField(
                              cursorColor: accentColor,
                              controller: _guestController,
                              onFieldSubmitted: (input) {
                                addGuest();
                              },
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(15.0),
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelStyle:
                                      TextStyle(color: Colors.grey[700]),
                                  labelText: 'Namn',
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: accentColor),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: mainColor),
                                  ))),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        RaisedButton(
                          color: mainColor,
                          textColor: prefix0.accentColor,
                          child: Text('Lägg till'),
                          onPressed: () {
                            addGuest();
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                        ),
                        SizedBox(
                          width: 70,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: FloatingActionButton(
              backgroundColor: mainColor,
              child: Icon(
                Icons.play_arrow,
                color: accentColor,
              ),
              onPressed: () {
                widget.args['players'] = setPlayerData();
                Navigator.pushNamed(context, 'play', arguments: widget.args);
              }),
        )
      ],
    );
  }

  setPlayerData() {
    final String uid = Provider.of<FirebaseUser>(context).uid;

    List playerData = [];
    addedPlayers.forEach((p) {
      if (p['id'] == null) p['id'] = uid;
      playerData.add({
        'firstname': p['firstname'],
        'lastname': p['lastname'],
        'id': p['id'],
        'guest': !(p['guest'] == null || p['guest'] == false)
      });
    });
    return playerData;
  }

  void addGuest() {
    if (_guestController.text.length > 0) {
      setState(() {
        addedPlayers.add({
          'firstname': _guestController.text,
          'index': addedPlayers.length,
          'guest': true
        });
      });
      _guestController.text = '';
    }
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
          dismissable: players[index]['index'] != null,
          friend: players[index],
          onAdd: (a, b) {
            if (players[index]['index'] != null) onRemove(players[index], 'a');
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
        if (friend != null) {
          return FriendCard(
              friend: friends[index],
              onAdd: onAddList,
              index: index,
              friendList: true);
        }
        return Container();
      },
    ));
  }
}

class FriendCard extends StatelessWidget {
  final Function onAdd;
  final friend;
  final bool dismissable;
  final bool friendList;
  final int index;
  FriendCard(
      {@required this.friend,
      @required this.onAdd,
      this.index,
      this.friendList = false,
      this.dismissable = false});
  @override
  Widget build(BuildContext context) {
    String lastname = friend['lastname'];
    if (lastname == null) lastname = '';
    Card friendCard = Card(
      elevation: 4,
      color: mainColor,
      margin: EdgeInsets.all(dismissable ? 0 : 4),
      child: ListTile(
          trailing: friendList
              ? Icon(
                  Icons.add,
                  color: accentColor,
                )
              : SizedBox(
                  width: 0,
                ),
          title: Text(
            '${friend['firstname']} $lastname',
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
