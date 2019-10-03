import 'package:discgolf/screens/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(SignInScreen());

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool couldNotLoginError = false;

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
        title: Text('Logga in'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                    color: Colors.grey,
                    child: Container(
                        width: 70, child: Center(child: Text('Registrera'))),
                    onPressed: () {},
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  RaisedButton(
                    color: Colors.orange[400],
                    child: Container(
                        width: 70, child: Center(child: Text('Logga in'))),
                    onPressed: () {
                      signIn();
                    },
                  ),
                ],
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
        if (couldNotLoginError) {
          couldNotLoginError = false;
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

  signIn() async {
    try {
      if (_formKey.currentState.validate()) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _usernameController.text,
            password: _passwordController.text);
        Navigator.pushReplacementNamed(context, 'home');
      }
    } catch (e) {
      couldNotLoginError = true;
      _formKey.currentState.validate();
    }
  }
}
