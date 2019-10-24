import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discgolf/utils/colors.dart';
import 'package:discgolf/widgets/list_title.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        // color: Colors.black87,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: Firestore.instance.collection('courses').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return coursesList(snapshot.data.documents, context);
                }
                return Container();
              },
            ),
            ListTitle('Inbjudningar'),
            GameRequestsBuilder(),
          ],
        ));
  }

  coursesList(List<DocumentSnapshot> courses, BuildContext context) {
    // return Container();
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            SizedBox(
              width: 5,
            ),
            Text('Banor',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
        Column(
          children: courses.map((course) {
            return CourseCard(course);
          }).toList(),
        ),
      ],
    );
  }
}

class CourseCard extends StatelessWidget {
  final DocumentSnapshot course;
  CourseCard(this.course);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'course', arguments: {
          'course': course,
        });
      },
      child: Card(
        elevation: 4,
        color: mainColor,
        child: ListTile(
          trailing: Icon(
            Icons.navigate_next,
            color: textColor,
          ),
          title: Text(
            course['name'],
            style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            course['address'],
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}

class GameRequestsBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<FirebaseUser>(context).uid;

    return StreamBuilder(
      stream: Firestore.instance.collection('users').document(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List gamerequests = snapshot.data['gamerequests'];
          return Column(
            children: gamerequests.map((gameReq) {
              return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, 'play', arguments: {
                      'game': gameReq['gameID'],
                      'players': gameReq['arguments']['players'],
                      'holes': gameReq['arguments']['holes'],
                      'courseID': gameReq['arguments']['courseID'],
                      'distance': gameReq['arguments']['distance'],
                      'name': gameReq['arguments']['name'],
                    });
                  },
                  child: GameRequest(gameReq: gameReq));
            }).toList(),
          );
        }
        return Container();
      },
    );
  }
}

class GameRequest extends StatelessWidget {
  final Map gameReq;
  GameRequest({this.gameReq});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: mainColor,
      child: ListTile(
        trailing: Container(
          width: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                Icons.check,
                color: Colors.green,
              ),
              SizedBox(
                width: 20,
              ),
              Icon(
                Icons.close,
                color: Colors.red,
              ),
            ],
          ),
        ),
        title: Text(
          gameReq['arguments']['name'],
          style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          gameReq['arguments']['players'][0]['firstname'].toString(),
          style: TextStyle(color: textColor),
        ),
      ),
    );
    return Container(
        width: 100,
        height: 20,
        color: Colors.red,
        child: Text(gameReq['gameID'].toString()));
  }
}
