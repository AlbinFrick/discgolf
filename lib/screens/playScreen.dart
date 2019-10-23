import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discgolf/utils/colors.dart';
import 'package:flutter/material.dart';

Map arguments;
var game;

class PlayScreen extends StatefulWidget {
  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  @override
  void initState() {
    super.initState();
  }

  setGame(args) {
    print('setting games');
    print(args['track']);
    if (game == null) {
      //  Firestore.instance.collection('games').add({
      // 'courseID': args[]
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context).settings.arguments;
    if (arguments == null) arguments = args;
    setGame(args);
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
                Text('0', style: TextStyle(fontSize: 20, color: accentColor)),
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
