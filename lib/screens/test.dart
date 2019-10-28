import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 200,
        height: 100,
        color: Colors.red,
        alignment: Alignment.center,
        child: Text('Hello World!', style: TextStyle(fontSize: 20)));
  }
}
