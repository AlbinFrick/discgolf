import 'package:discgolf/screens/user.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
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
    ),
    Container(
      color: Colors.yellow,
    )
  ];
  List<Widget> headers = [
    AppBar(
      backgroundColor: Colors.black,
      title: Text(
        'Flöde',
        style: TextStyle(color: Colors.white),
      ),
    ),
    AppBar(
      backgroundColor: Colors.black,
      title: Text(
        'Spela',
        style: TextStyle(color: Colors.white),
      ),
    ),
    AppBar(
      backgroundColor: Colors.black,
      title: Text(
        'Användare',
        style: TextStyle(color: Colors.white),
      ),
    ),
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
        appBar: headers[bodyIndex],
        bottomNavigationBar: bottomBar(),
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

  bottomBar() {
    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TabButton(
              onPress: changeHomeIndex,
              index: 0,
              icon: Icons.menu,
              focused: bodyIndex == 0),
          TabButton(
              onPress: changeHomeIndex,
              index: 1,
              icon: Icons.play_arrow,
              focused: bodyIndex == 1),
          TabButton(
              onPress: changeHomeIndex,
              index: 2,
              icon: Icons.person,
              focused: bodyIndex == 2)
        ],
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  final Function onPress;
  final int index;
  final IconData icon;
  final bool focused;
  TabButton({this.onPress, this.index, this.icon, this.focused});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => onPress(index),
        child: Container(
          width: 50,
          height: 50,
          child: Icon(
            icon,
            color: focused ? Colors.white : Colors.grey,
            size: 30,
          ),
        ));
  }
}
