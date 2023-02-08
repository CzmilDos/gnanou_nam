import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gnanou_nam/authentication/login.dart';
import 'package:gnanou_nam/authentication/registration.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  String? userToken;

  @override
  void initState() {
    getToken();
    super.initState();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token){
      setState(() {
        userToken = token;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLogin ? LoginScreen(onClickedSignUp: toggle, userToken: userToken,) : SignUpScreen(onClickedSignIn: toggle, userToken: userToken,);
  }

  void toggle() => setState(() => isLogin = !isLogin);

}
