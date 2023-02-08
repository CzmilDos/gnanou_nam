import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnanou_nam/constants.dart';
import 'package:gnanou_nam/screens/admin_command_done.dart';
import 'package:gnanou_nam/screens/admin_myCommands.dart';
import 'package:gnanou_nam/screens/admin_waitings.dart';
import 'package:fluttericon/font_awesome_icons.dart';

import '../main.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
          title: const Text('Liste des commandes'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'En attentes', icon: Icon(Icons.history)),
              Tab(text: 'En cours', icon: Icon(Icons.adb)),
              Tab(text: 'Traitées', icon: Icon(Icons.adb))
            ],
          ),
          actions: [
            IconButton(icon: const Icon(FontAwesome.logout),
              onPressed: (){
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.WARNING,
                  animType: AnimType.SCALE,
                  desc: 'Se déconnecter?',
                  btnOkText: 'Oui',
                  btnCancelText: 'Non',
                  btnCancelOnPress: () {},
                  btnOkOnPress: _logOut,
                ).show();
              },
            )
          ],

        ),
        backgroundColor: const Color(0xfff2f3f7),
        body: const TabBarView(
          children: [
            AdminWaitings(),
            AdminMyCommands(),
            AdminCommandDone()
          ],
        ),
      ),
    );
  }

  _logOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthWrapper()));
  }
}
