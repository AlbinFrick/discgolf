import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discgolf/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Map arguments;
String game;
int currentHole;

class PlayScreen extends StatefulWidget {
  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  @override
  void initState() {
    super.initState();
    currentHole = 1;
  }

  setGame(Map args, String uid) {
    if (game == null) {
      game = '';

      List playerList = List();
      Map holes = Map();

      args['holes'].forEach((hole) {
        holes[hole['number'].toString()] = {
          'throws': hole['par'],
          'locations': []
        };
      });

      args['players'].forEach((player) {
        String playerID = player['id'];
        if (playerID == null)
          playerList.add({uid: holes});
        else
          playerList.add({player['id']: holes});
      });

      Firestore.instance
          .collection('games')
          .add({'players': playerList}).then((docRef) {
        setState(() {
          game = docRef.documentID;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<FirebaseUser>(context).uid;

    final Map args = ModalRoute.of(context).settings.arguments;
    if (arguments == null) arguments = args;
    setGame(args, uid);
    if (game == '' || game == null) return Container(color: Colors.red);
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

class HoleList extends StatelessWidget {
  final Map args;
  final double spaceBetweenCards = 10;
  HoleList({this.args});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 4 * 3,
      child: PageView.builder(
        onPageChanged: (page) {
          currentHole = page;
        },
        controller: PageController(viewportFraction: 0.95),
        scrollDirection: Axis.horizontal,
        itemCount: args['holes'].length,
        itemBuilder: (context, index) {
          HoleCard card = HoleCard(
            width: MediaQuery.of(context).size.width - spaceBetweenCards * 4,
            data: args['holes'][index],
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
      print(arguments['holes'][currentHole]);
      Navigator.pushNamed(context, 'mapTest', arguments: {
        'hole': arguments['holes'][currentHole],
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
    print('from playerScore: $game');
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
                Text(
                    widget.player['email'].toString().substring(
                        0, widget.player['email'].toString().indexOf('@')),
                    style: TextStyle(fontSize: 20, color: textColor)),
              ],
            ),
            Row(
              children: <Widget>[
                RoundButton(iconData: Icons.remove),
                SizedBox(
                  width: 15,
                ),
                StreamBuilder(
                  stream: Firestore.instance
                      .collection('games')
                      .document(game)
                      .snapshots(),
                  builder: (context, snapshot) {
                    int playerThrows = 0;
                    // if (snapshot.hasData) {
                    //   snapshot.data['players'].forEach((p) {
                    //     if (widget.player['id'] != null) {
                    //       if (widget.player['id'] == p.keys.first) {}
                    //     }
                    //     print(p[uid][currentHole.toString()]['throws']);
                    //   });
                    //   // return Text(snapshot.data['players']['holes'][currentHole].toString(),
                    //   // style: TextStyle(fontSize: 15, color: Colors.white));
                    // }
                    return Container();
                  },
                ),
                SizedBox(
                  width: 15,
                ),
                RoundButton(iconData: Icons.add),
              ],
            ),
          ],
        ));
  }
}

class RoundButton extends StatelessWidget {
  final IconData iconData;
  RoundButton({this.iconData});
  @override
  Widget build(BuildContext context) {
    return Container(
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
            iconData,
            color: Colors.white,
            size: 20,
          ),
        ));
  }
}
