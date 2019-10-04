import 'package:discgolf/screens/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(RegisterScreen());

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool couldNotRegisterError = false;

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Registrera'),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(40, 100, 40, 0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              textFormField('Användare', controller: _usernameController),
              SizedBox(
                height: 20,
              ),
              textFormField('Lösenord',
                  password: true, controller: _passwordController),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                color: Colors.grey,
                child: Container(
                    width: 70, child: Center(child: Text('Registrera'))),
                onPressed: () {
                  register();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  textFormField(label, {bool password = false, @required controller}) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value.isEmpty) {
          return 'Saknas';
        }
        if (couldNotRegisterError) {
          couldNotRegisterError = false;
          return 'Fel lösenord eller användarnamn';
        }
        return null;
      },
      obscureText: password,
      decoration: InputDecoration(
          prefix: SizedBox(
            width: 10,
          ),
          labelText: label,
          border:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.black))),
    );
  }

  register() async {
    try {
      if (_formKey.currentState.validate()) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _usernameController.text,
            password: _passwordController.text);
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
      couldNotRegisterError = true;
      _formKey.currentState.validate();
    }
  }
}
