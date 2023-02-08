import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gnanou_nam/authentication/auth_screen.dart';
import 'package:gnanou_nam/constants.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../main.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onClickedSignUp;
  final String? userToken;

  const LoginScreen({Key? key, required this.onClickedSignUp, required this.userToken})
      : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController resetEmailController = TextEditingController();

  final _loginFormKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool reseting = false;

  String? error;

  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() {}));
    resetEmailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    resetEmailController.dispose();
    super.dispose();
  }

  Future _submitFormOnLogin() async {
    final isValid = _loginFormKey.currentState!.validate();
    if (isValid) {
      setState(() {
        isLoading = true;
      });
      final String email = emailController.text.trim().toLowerCase();
      final String password = passwordController.text.trim();

      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      } on SocketException {
        return ("Pas d'accès internet, veuillez vérifier votre connexion");
      } on FirebaseAuthException catch (e) {
        setState(() {
          isLoading = false;
          error = e.message;
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
        });
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.amberAccent,
              margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45)),
              behavior: SnackBarBehavior.floating,
              content: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.error_outline),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: AutoSizeText(
                        error!,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              )));
        }
      }
    }
  }

  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  _googleSignInFct() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: SpinKitChasingDots(
          size: 40,
          color: Colors.amber
        ),));

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        await _auth.signInWithCredential(authCredential).then((value) async {
          User? user = _auth.currentUser;
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .set({
            'token': widget.userToken,
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName,
            'phoneNumber': '',
            'quartier': '',
            'role': 'user'
          });
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      });
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.amberAccent,
            margin: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(45)),
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.error_outline),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: AutoSizeText(
                      error!,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            )));
      }
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  openDialog() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: const Text('Ré-initialisation du mot de passe!'),
            content: TextField(
              autofocus: true,
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Entrez votre adresse email',
              ),
            ),
            actions: [
              TextButton(
                  onPressed: resetPassword,
                  child: reseting
                      ? _buildSmallBtn()
                      : const Text(
                          'Valider',
                          style: TextStyle(color: mainColor, fontSize: 18),
                        ))
            ],
          ));

  void resetPassword() async {
    setState(() {
      reseting = true;
    });
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: resetEmailController.text)
          .then((value) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const AuthScreen()));
        AwesomeDialog(
          context: context,
          dialogType: DialogType.SUCCES,
          animType: AnimType.SCALE,
          title: 'Lien de ré-initialisation envoyé!',
          desc:
              'Cliquez sur le lien envoyé à votre adresse mail pour ré-initialiser votre mot de passe',
          btnOkOnPress: () {},
        ).show();
      });
    } catch (error) {
      setState(() {
        reseting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xfff2f3f7),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.73,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: const BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(70),
                      bottomRight: Radius.circular(70),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.07),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.059),
                    _buildLogo(),
                    _buildContainer(),
                    _buildSignUpBtn(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: Text(
            'Gnanou Nam...!',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height / 25,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildForgetPasswordButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
          child: TextButton(
            onPressed: () {
              openDialog();
            },
            child: const Text(
              "Mot de passe oublié",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
            height: 1.4 * (MediaQuery.of(context).size.height / 20),
            width: 5 * (MediaQuery.of(context).size.width / 10),
            margin: const EdgeInsets.only(bottom: 20),
            child: isLoading
                ? _buildSmallBtn()
                : RaisedButton(
                    elevation: 12,
                    color: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: _submitFormOnLogin,
                    child: Text(
                      "Connexion",
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 1.5,
                        fontSize: MediaQuery.of(context).size.height / 40,
                      ),
                    ),
                  )),
      ],
    );
  }

  Widget _buildOrRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: const Text(
            '- OU -',
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSocialBtnRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _googleSignInFct,
            child: const CircleAvatar(
              backgroundImage: AssetImage("images/google.png"),
              radius: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContainer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Authentification",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Form(
                  key: _loginFormKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Veuillez entrer votre adresse email !";
                            } else if (!value.contains("@")) {
                              return "L'adresse email n'est pas valide";
                            }
                          },
                          decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: mainColor,
                              ),
                              suffixIcon: emailController.text.isEmpty
                                  ? Container(width: 0)
                                  : IconButton(
                                      onPressed: () => emailController.clear(),
                                      icon: const Icon(Icons.close)),
                              labelText: 'E-mail'),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: TextFormField(
                          textInputAction: TextInputAction.done,
                          controller: passwordController,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Veuillez entrer votre mot de passe!";
                            }
                          },
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.vpn_key,
                              color: mainColor,
                            ),
                            suffixIcon: IconButton(
                              icon: isPasswordVisible
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility),
                              onPressed: () => setState(
                                  () => isPasswordVisible = !isPasswordVisible),
                            ),
                            labelText: 'Mot de passe',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
                _buildForgetPasswordButton(),
                _buildLoginButton(),
                _buildOrRow(),
                _buildSocialBtnRow(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          'Nouvel utilisateur? ',
          style: TextStyle(
            color: Colors.black,
            fontSize: MediaQuery.of(context).size.height / 44,
          ),
        ),
        TextButton(
          onPressed: () {
            widget.onClickedSignUp();
          },
          child: Text(
            'Créer un compte',
            style: TextStyle(
              color: mainColor,
              fontSize: MediaQuery.of(context).size.height / 40,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildSmallBtn() {
    return Container(
      decoration: const BoxDecoration(shape: BoxShape.circle, color: mainColor),
      child: const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}
