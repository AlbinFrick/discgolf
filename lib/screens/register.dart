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
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();

  bool couldNotRegisterError = false;

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Registrera'),
      ),
      
      body: Container(
        child: new SingleChildScrollView(
        scrollDirection: Axis.vertical,
        reverse: true,
        padding: EdgeInsets.fromLTRB(40, 100, 40, 0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              textFormField('E-mail', username: true, controller: _usernameController),
              SizedBox(
                height: 15,
              ),
              textFormField('Förnamn', controller: _firstnameController),
              SizedBox(
                height: 15,
              ),
              textFormField('Efternamn', controller: _lastnameController),
              SizedBox(
                height: 15,
              ),
              textFormField('Lösenord',
                  password: true, controller: _passwordController),
              SizedBox(
                height: 15,
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
     ),
    ); 
  }

  textFormField(label, {bool password = false, username= false, @required controller}) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value.isEmpty) {
          return 'Saknas';
        }
        if (couldNotRegisterError) {
          couldNotRegisterError = false;
          return 'Ett fel uppstod vid registrering';
        }
        return null;
      },
      autocorrect: false,
      keyboardType: username ? TextInputType.emailAddress : TextInputType.text,
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
        /*FirebaseUser user */await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _usernameController.text,
            password: _passwordController.text);
 //       UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
   //     userUpdateInfo.displayName = _firstnameController;
     //   user.updateProfile(userUpdateInfo).then((onValue){
        Navigator.pushReplacementNamed(context, 'home', arguments: {
          'registered': true, 
        });
       // Firestore.instance.collection('users').document().setData(
         //       {'email': _usernameController, 'firstname': _firstnameController}).then((onValue) {
           //   _sheetController.setState(() {
             //   _loading = false;
           //   });
         //   });
      }
    } catch (e) {
      print(e);
      couldNotRegisterError = true;
      _formKey.currentState.validate();
    }
  }
}
