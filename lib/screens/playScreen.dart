import 'package:discgolf/utils/colors.dart';
import 'package:flutter/material.dart';

class PlayScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context).settings.arguments;
    print(args);
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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: args['holes'].length,
        itemBuilder: (context, index) {
          HoleCard card = HoleCard(
            width: MediaQuery.of(context).size.width - spaceBetweenCards * 4,
            data: args['holes'][index],
          );
          List<Widget> cardWithMargins = List();
          cardWithMargins.add(card);
          if (index == 0) {
            cardWithMargins.insert(
                0,
                SizedBox(
                  width: spaceBetweenCards * 2,
                ));
          } else if (index == args['holes'].length - 1) {
            cardWithMargins.insert(
                0,
                SizedBox(
                  width: spaceBetweenCards,
                ));
            cardWithMargins.add(SizedBox(
              width: spaceBetweenCards * 2,
            ));
          } else {
            cardWithMargins.insert(
                0,
                SizedBox(
                  width: spaceBetweenCards,
                ));
          }
          return Row(
            children: cardWithMargins,
          );
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
    return Container(
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
            'Par: TBE',
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
    );
  }
}

class PlayersScore extends StatelessWidget {
  final Map players;
  PlayersScore({this.players});
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class PlayerScore extends StatefulWidget {
  @override
  _PlayerScoreState createState() => _PlayerScoreState();
}

class _PlayerScoreState extends State<PlayerScore> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      width: 10,
      height: 10,
    );
  }
}
