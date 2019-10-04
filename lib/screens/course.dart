import 'package:discgolf/utils/colors.dart';
import 'package:flutter/material.dart';

class CourseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context).settings.arguments;
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
            RaisedButton(
              color: accentColor,
              onPressed: () {},
              child: Text('Spela'),
            )
          ],
        ),
      ),
    );
  }
}
