import 'package:flutter/material.dart';

class ListTitle extends StatelessWidget {
  final String title;
  ListTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 5,
        ),
        Text(title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }
}
