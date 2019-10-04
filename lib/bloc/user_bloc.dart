import 'package:flutter/material.dart';

class UserBloc extends ChangeNotifier {
  String _uid;
  String get uid => _uid;

  set uid(String val) {
    _uid = val;
    notifyListeners();
  }

  setUserID(String val) {
    uid = val;
  }
}
