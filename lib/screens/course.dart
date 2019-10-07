import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discgolf/utils/colors.dart';
import 'package:flutter/material.dart';

class CourseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context).settings.arguments;
    // print(args['course']['tracks'][0]);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(args['course']['name']),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(40),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width - 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: mainColor,
              ),
              child: Text('Karta', style: TextStyle(color: textColor)),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                children: buildTracks(args['course']['tracks'], context),
              ),
            )
            // RaisedButton(
            //   color: accentColor,
            //   onPressed: () {
            //     // Navigator.pushNamed(context, 'inviteFriends', arguments: {track});
            //   },
            //   child: Text('Spela'),
            // )
          ],
        ),
      ),
    );
  }

  buildTracks(List<dynamic> tracks, BuildContext context) {
    print(tracks);
    return tracks.map<Widget>((track) {
      return GestureDetector(
        onTap: () =>
            Navigator.pushNamed(context, 'inviteFriends', arguments: track),
        child: Card(
          color: mainColor,
          child: ListTile(
            title: Text(
              track['name'],
              style: TextStyle(color: textColor),
            ),
            trailing: Icon(Icons.navigate_next, color: textColor),
          ),
        ),
      );
    }).toList();
  }
}
