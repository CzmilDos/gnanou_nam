import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnanou_nam/constants.dart';


class SignUpScreen extends StatefulWidget {
  final Function() onClickedSignIn;
  final String? userToken;

  const SignUpScreen({Key? key, required this.onClickedSignIn, required this.userToken}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController confirmPasswordController = TextEditingController();
  late TextEditingController phoneNumberController = TextEditingController();
  late TextEditingController fullNameController = TextEditingController();
  final _signUpFormKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? error;

  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    emailController.addListener(() => setState(() {}));
    fullNameController.addListener(() => setState(() {}));
    phoneNumberController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneNumberController.dispose();
    fullNameController.dispose();
    super.dispose();
  }

  Future _submitFormOnSignUp() async {
    final isValid = _signUpFormKey.currentState!.validate();
    if(isValid){
      setState(() {
        isLoading = true;
      });
      final String email = emailController.text.trim().toLowerCase();
      final String password = passwordController.text.trim();
      final String fullName = fullNameController.text.trim();
      final String phoneNumber = phoneNumberController.text.trim();

      try{
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).then((value) async {
          User? user = FirebaseAuth.instance.currentUser;
          await FirebaseFirestore.instance.collection("users").doc(user!.uid).set({
            'token': widget.userToken,
            'uid': user.uid,
            'email': email,
            'name': fullName,
            'phoneNumber': phoneNumber,
            'quartier': '',
            'role': 'user'
          });
        });

      }on SocketException {
        return("Pas d'accès internet, veuillez vérifier votre connexion");

      } on FirebaseAuthException catch(e) {
        setState(() {
          isLoading = false;
          error = e.message;
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
        });
        if(error != null){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.amberAccent,
              margin: const EdgeInsets.only(bottom: 19, left: 10, right: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45)
              ),
              behavior: SnackBarBehavior.floating,
              content: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.error_outline),
                  ),
                  Expanded(child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: AutoSizeText(error!,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87
                      ),
                    ),
                  ),),
                ],
              )
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return widget.onClickedSignIn();
      },
      child: Scaffold(
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
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.07),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).size.height * 0.059),
                      _buildLogo(),
                      _buildContainer(),
                      _buildLoginBtn(),
                    ],
                  ),
                ),
              ],
            ),
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

  Widget _buildLoginButton() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 1.4 * (MediaQuery.of(context).size.height / 20),
            width: 5 * (MediaQuery.of(context).size.width / 10),
            margin: const EdgeInsets.only(bottom: 15),
            child: isLoading ? _buildSmallBtn() : RaisedButton(
              elevation: 8,
              color: mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              onPressed: _submitFormOnSignUp,
              child: Text(
                "Créer",
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 1.5,
                  fontSize: MediaQuery.of(context).size.height / 40,
                ),
              ),
            ),
          )
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
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Création de compte",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 30,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5,),

                  Form(
                    key: _signUpFormKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: fullNameController,
                            keyboardType: TextInputType.text,
                            validator: (value){
                              if(fullNameController.text.isEmpty |
                                  phoneNumberController.text.isEmpty |
                                  emailController.text.isEmpty |
                                  passwordController.text.isEmpty |
                                  confirmPasswordController.text.isEmpty){

                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.NO_HEADER,
                                  animType: AnimType.TOPSLIDE,
                                  title: 'Obligatoire',
                                  desc: 'Veuillez remplir tous les champs...!',
                                  btnOkOnPress: () {},
                                ).show();

                              }

                            },
                            decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: mainColor,
                                ),
                                suffixIcon: fullNameController.text.isEmpty
                                    ? Container(width: 0)
                                    : IconButton(
                                    onPressed: () => fullNameController.clear(),
                                    icon: const Icon(Icons.close)),
                                labelText: 'Prénom'),
                          ),
                        ),
                        const SizedBox(height: 5,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: TextFormField(
                            maxLength: 8,
                            textInputAction: TextInputAction.next,
                            controller: phoneNumberController,
                            keyboardType: TextInputType.phone,
                            validator: (value){
                              if(value!.isEmpty){
                                return "Entrez votre n° de téléphone";
                              }else if(value.length < 8){
                                return 'Numéro incorrect';
                              }
                            },
                            decoration: InputDecoration(
                                counterText: '',
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: mainColor,
                                ),
                                suffixIcon: phoneNumberController.text.isEmpty
                                    ? Container(width: 0)
                                    : IconButton(
                                    onPressed: () => phoneNumberController.clear(),
                                    icon: const Icon(Icons.close)),
                                labelText: 'N° Telephone',
                                hintText: "Sans l'indicatif",
                                hintStyle: const TextStyle(fontSize: 15)
                            ),
                          ),
                        ),
                        const SizedBox(height: 5,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            autovalidateMode: AutovalidateMode.onUserInteraction, controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value){
                              if(value!.isEmpty){
                                return "Entrez votre adresse e-mail";
                              }
                              else if(!value.contains("@")){
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
                        const SizedBox(height: 5,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            controller: passwordController,
                            keyboardType: TextInputType.text,
                            validator: (value){
                              if(value!.length < 8){
                                return "Au moins huit (08) caractères...";
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
                                onPressed: () => setState(() =>
                                isPasswordVisible = !isPasswordVisible),
                              ),
                              labelText: 'Mot de passe',
                            ),
                          ),
                        ),
                        const SizedBox(height: 5,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: TextFormField(
                            textInputAction: TextInputAction.done,
                            controller: confirmPasswordController,
                            keyboardType: TextInputType.text,
                            validator: (value){
                              if(passwordController.text != confirmPasswordController.text){
                                return "les mots de passes ne correspondent pas!";
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
                                onPressed: () => setState(() =>
                                isPasswordVisible = !isPasswordVisible),
                              ),
                              labelText: 'Confirmer le mot de passe',
                            ),
                          ),
                        ),
                        const SizedBox(height: 5,),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20,),

                  _buildLoginButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginBtn() {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Déjà membre? ',
              style: TextStyle(
                color: Colors.black,
                fontSize: MediaQuery.of(context).size.height / 44,
              ),
            ),
            TextButton(
              onPressed: (){
                widget.onClickedSignIn();
              },
              child: Text('Se connecter',
                style: TextStyle(
                  color: mainColor,
                  fontSize: MediaQuery.of(context).size.height / 40,
                  fontWeight: FontWeight.w800,
                ),
              ),),
          ]),
    );
  }

  Widget _buildSmallBtn(){
    return Container(
      decoration: const BoxDecoration(shape: BoxShape.circle, color: mainColor),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white,),
      ),
    );
  }

}
