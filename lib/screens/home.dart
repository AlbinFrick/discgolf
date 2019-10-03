import 'package:discgolf/screens/signin.dart';
import 'package:discgolf/screens/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  getName() async {
    var value = await FirebaseAuth.instance.currentUser();

    print(value);
  }

  @override
  Widget build(BuildContext context) {
    getName();
    return Scaffold(
        appBar: headers[bodyIndex],
        bottomNavigationBar: bottomBar(),
        body: Stack(
          children: <Widget>[
            tabs[bodyIndex],
            Column(
              children: <Widget>[
                Center(
                  child: RaisedButton(onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => User()),
                    );
                  }),
                ),
                Center(
                  child: RaisedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacementNamed(context, 'main');
                    },
                    child: Text('Sign out'),
                  ),
                ),
              ],
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
