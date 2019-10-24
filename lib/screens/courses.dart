import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discgolf/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<FirebaseUser>(context).uid;

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
            StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List gamerequests = snapshot.data['gamerequests'];
                  return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, 'play', arguments: {
                          'game': gamerequests[0]['gameID'],
                          'players': gamerequests[0]['arguments']['players'],
                          'holes': gamerequests[0]['arguments']['holes'],
                          'courseID': gamerequests[0]['arguments']['courseID'],
                          'distance': gamerequests[0]['arguments']['distance'],
                          'name': gamerequests[0]['arguments']['name'],
                        });
                      },
                      child: Text(gamerequests[0].toString()));
                }
                return Container();
              },
            ),
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
