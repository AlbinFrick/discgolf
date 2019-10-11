import 'dart:async';

import 'package:discgolf/utils/colors.dart';
import 'package:discgolf/utils/fire_utils.dart';
import 'package:flutter/material.dart';

class FriendSearch extends StatefulWidget {
  @override
  _FriendSearchState createState() => _FriendSearchState();
}

class _FriendSearchState extends State<FriendSearch> {
  final TextEditingController _searchController = TextEditingController();
  String response = '';
  Color responseColor = Colors.black;
  double messageOpacity = 0;
  @override
  Widget build(BuildContext context) {
    search() async {
      String input = _searchController.text;
      if (input.length > 0 && input.contains('@')) {
        bool success = await FireUtils.addUserFriendRequest(
            friendEmail: _searchController.text, context: context);
        if (success) {
          _searchController.text = '';
          response = 'Förfrågan skickad!';
          responseColor = Colors.green;
          FocusScope.of(context).requestFocus(FocusNode());
        } else {
          response = 'Kunde inte lägga till.';
          responseColor = Colors.red;
        }
      } else {
        response = 'Skriv en email.';
        responseColor = Colors.red;
      }
      setState(() {
        messageOpacity = 1;
        Timer(
            Duration(seconds: 5),
            () => setState(() {
                  messageOpacity = 0;
                }));
      });
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: TextFormField(
                            cursorColor: accentColor,
                            textCapitalization: TextCapitalization.none,
                            onFieldSubmitted: (input) {
                              search();
                            },
                            controller: _searchController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                prefix: SizedBox(
                                  width: 10,
                                ),
                                labelText: 'Email',
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: accentColor),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: mainColor),
                                ))),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          search();
                        },
                        child: Center(
                          child: RaisedButton(
                            onPressed: () => search(),
                            color: mainColor,
                            child: Text('Lägg till',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: accentColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        // child: Icon(
                        //   Icons.play_arrow,
                        //   color: accentColor,
                        // ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: messageOpacity,
                child: Text(response, style: TextStyle(color: responseColor))),
          ],
        ));
  }
}
