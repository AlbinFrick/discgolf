import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discgolf/utils/colors.dart';
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
        child: StreamBuilder(
          stream: Firestore.instance.collection('courses').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return coursesList(snapshot.data.documents, context);
            }
            return Container();
          },
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
