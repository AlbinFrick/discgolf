import 'package:discgolf/screens/user.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.yellow),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> tabs = [
    Container(
      color: Colors.red,
    ),
    Container(
      color: Colors.blue,
    )
  ];
  int bodyIndex = 0;

  changeHomeIndex(int index) {
    setState(() {
      bodyIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Row(
          children: <Widget>[
            TabButton(
              onPress: changeHomeIndex,
              index: 0,
            ),
            TabButton(
              onPress: changeHomeIndex,
              index: 1,
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            tabs[bodyIndex],
            Center(
              child: RaisedButton(onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => User()),
                );
              }),
            ),
          ],
        ));
  }
}

class TabButton extends StatelessWidget {
  final Function onPress;
  final int index;
  TabButton({this.onPress, this.index});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => onPress(index),
        child: Container(
          width: 50,
          height: 50,
          child: Icon(Icons.access_alarm),
        ));
  }
}
