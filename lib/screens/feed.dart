import 'package:discgolf/screens/user.dart';
import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        color: Colors.red,
        child: Column(
          children: <Widget>[
            // Text(counterBloc.counter.toString()),
            Center(
              child: RaisedButton(onPressed: () {
                Navigator.pushNamed(context, 'user');
              }),
            ),
            Center(
              child: RaisedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'mapTest');
                },
                child: Text('Map'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
