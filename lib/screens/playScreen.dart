import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discgolf/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Map arguments;
String game;
int currentHoleIndex;

class PlayScreen extends StatefulWidget {
  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  @override
  void initState() {
    super.initState();
    currentHoleIndex = 0;
  }

  setGame(Map args, String uid) {
    if (game == null) {
      game = '';

      Map playerList = {};
      List<String> invitableFriends = List();
      Map holes = Map();

      args['holes'].forEach((hole) {
        holes[hole['number'].toString()] = {
          'throws': hole['par'],
          'locations': {}
        };
      });

      print(arguments['players']);
      args['players'].forEach((player) {
        String playerID = player['id'];
        if (player['guest'] != null && player['guest'])
          playerList[player['firstname']] = {'holes': holes, 'guest': true};
        else if (playerID == null) {
          // arguments['players'][]
          playerList[uid] = {'holes': holes};
        } else {
          playerList[player['id']] = {'holes': holes};
          invitableFriends.add(player['id']);
        }
      });

      Firestore.instance.collection('games').add({
        'players': playerList,
        'date': DateTime.now(),
        'courseID': args['courseID'],
        'track': args['name']
      }).then((docRef) {
        setState(() {
          game = docRef.documentID;
        });
        sendInvites(invitableFriends);
      });
    }
  }

  sendInvites(List<String> friends) {
    friends.forEach((friend) {
      Firestore.instance.collection('users').document(friend).get().then((doc) {
        List gamerequests = List();
        if (doc.data['gamerequests'] != null) {
          doc.data['gamerequests'].forEach((gr) {
            gamerequests.add(gr);
          });
        }
        gamerequests.add({'gameID': game, 'arguments': arguments});
        Firestore.instance
            .collection('users')
            .document(friend)
            .updateData({'gamerequests': gamerequests});
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    game = null;
  }

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<FirebaseUser>(context).uid;

    final Map args = ModalRoute.of(context).settings.arguments;
    if (arguments == null) arguments = args;
    if (args['game'] != null) game = args['game'];
    setGame(args, uid);
    if (game == '' || game == null)
      return Container(
        child: CupertinoActivityIndicator(radius: 30),
      );
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            HoleList(args: args),
            SizedBox(
              height: 10,
            ),
            NavButtons()
          ],
        ));
  }
}

class HoleList extends StatefulWidget {
  final Map args;

  HoleList({this.args});

  @override
  _HoleListState createState() => _HoleListState();
}

class _HoleListState extends State<HoleList> {
  final double spaceBetweenCards = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 4 * 3,
      child: PageView.builder(
        onPageChanged: (page) {
          setState(() {
            currentHoleIndex = page;
          });
        },
        controller: PageController(viewportFraction: 0.95),
        scrollDirection: Axis.horizontal,
        itemCount: widget.args['holes'].length,
        itemBuilder: (context, index) {
          HoleCard card = HoleCard(
            width: MediaQuery.of(context).size.width - spaceBetweenCards * 4,
            data: widget.args['holes'][index],
          );
          return card;
        },
      ),
    );
  }
}

class HoleCard extends StatefulWidget {
  final double width;
  final Map data;

  HoleCard({@required this.width, this.data});

  @override
  _HoleCardState createState() => _HoleCardState();
}

class _HoleCardState extends State<HoleCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.data['number'].toString(),
              style: TextStyle(color: textColor, fontSize: 40),
            ),
            SizedBox(
              height: 40,
            ),
            Text(
              'Par: ${widget.data['par'].toString()}',
              style: TextStyle(color: textColor, fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: widget.width - 30,
              height: 2,
              color: accentColor,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Spelare',
              style: TextStyle(color: textColor, fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            PlayersScore(),
          ],
        ),
        width: widget.width,
        height: 1000,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black,
        ),
      ),
    );
  }
}

class NavButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Function goToMap = () {
      Navigator.pushNamed(context, 'mapTest', arguments: {
        'hole': arguments['holes'][currentHoleIndex],
        'gameid': game
      });
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          getNavButton(title: 'Karta', onPress: goToMap),
          SizedBox(
            width: 20,
          ),
          getNavButton(title: 'Översikt'),
        ],
      ),
    );
  }

  getNavButton({String title, Function onPress}) {
    return Flexible(
      child: GestureDetector(
        onTap: onPress,
        child: Container(
          // width: 150,
          height: 50,
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(fontSize: 20, color: mainColor)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: accentColor,
          ),
        ),
      ),
    );
  }
}

class PlayersScore extends StatelessWidget {
  final Map players;
  PlayersScore({this.players});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: arguments['players'].map<Widget>((player) {
        return PlayerScore(player: player);
      }).toList(),
    );
  }
}

class PlayerScore extends StatefulWidget {
  final Map player;
  PlayerScore({@required this.player});
  @override
  _PlayerScoreState createState() => _PlayerScoreState();
}

class _PlayerScoreState extends State<PlayerScore> {
  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<FirebaseUser>(context).uid;
    int throws = 0;
    String playerID = widget.player['id'];
    if (playerID == null) playerID = uid;

    return Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  width: 10,
                ),
                //dont mind this
                Text(
                    '${widget.player['firstname'].toString()} ${widget.player['lastname'] == null ? '' : widget.player['lastname'].toString()}',
                    style: TextStyle(fontSize: 20, color: textColor)),
              ],
            ),
            Row(
              children: <Widget>[
                RoundButton(
                  action: 'decrease',
                  playerID: playerID,
                  onTap: () {
                    if (throws > 0) {
                      String key =
                          'players.$playerID.holes.${currentHoleIndex + 1}.throws';
                      Firestore.instance
                          .collection('games')
                          .document(game)
                          .updateData({key: throws - 1}).then((data) {
                        setState(() {});
                      });
                    }
                  },
                ),
                SizedBox(
                  width: 15,
                ),
                StreamBuilder(
                  stream: Firestore.instance
                      .collection('games')
                      .document(game)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      throws = snapshot.data['players'][playerID]['holes']
                          [(currentHoleIndex + 1).toString()]['throws'];
                    }
                    return Text(throws.toString(),
                        style: TextStyle(fontSize: 15, color: Colors.white));
                  },
                ),
                SizedBox(
                  width: 15,
                ),
                RoundButton(
                  action: 'increase',
                  playerID: playerID,
                  onTap: () {
                    String key =
                        'players.$playerID.holes.${currentHoleIndex + 1}.throws';
                    Firestore.instance
                        .collection('games')
                        .document(game)
                        .updateData({key: throws + 1}).then((data) {
                      setState(() {});
                    });
                  },
                ),
              ],
            ),
          ],
        ));
  }
}

class RoundButton extends StatelessWidget {
  final String action;
  final String playerID;
  final Function onTap;
  RoundButton({this.action, this.playerID, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: 30,
          height: 30,
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(300),
            color: Colors.white,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(300),
              color: Colors.black,
            ),
            child: Icon(
              action == 'increase' ? Icons.add : Icons.remove,
              color: Colors.white,
              size: 20,
            ),
          )),
    );
  }
}
