import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:gnanou_nam/constants.dart';
import 'package:gnanou_nam/screens/addresses_screen.dart';
import 'package:gnanou_nam/screens/history_screen.dart';
import 'package:gnanou_nam/screens/profile_screen.dart';
import 'package:gnanou_nam/services/name_icon.dart';
import 'package:google_sign_in/google_sign_in.dart';

class NavigationDrawer extends StatelessWidget {
  NavigationDrawer({Key? key}) : super(key: key);
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: mainColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(context),
          const Divider(
            color: Colors.white,
          ),
          buildMenuItems(context),
        ],
      ),
    );
  }

  Widget header(
      {required Widget image, required Widget name, required Widget email}) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 0),
      title: name,
      subtitle: email,
      leading: image,
    );
  }

  Widget buildHeader(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.03),
                    child: header(
                      image: NameIcon(
                        firstName: snapshot.data!.data()['name'],
                        backgroundColor: Colors.deepPurple,
                        textColor: Colors.white,
                      ),
                      name: Text(
                        snapshot.data!.data()['name'],
                        style:
                            const TextStyle(fontSize: 22, color: Colors.white),
                      ),
                      email: Text(
                        snapshot.data!.data()['email'],
                        style: const TextStyle(
                            fontSize: 15, color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Widget buildMenuItems(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(
            Icons.history,
            size: 28,
            color: Colors.white,
          ),
          title: const Text('Historique',
              style: TextStyle(fontSize: 17, color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()));
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.location_on,
            size: 28,
            color: Colors.white,
          ),
          title: const Text('Mes adresses',
              style: TextStyle(fontSize: 17, color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AddressesScreen()));
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.person,
            size: 28,
            color: Colors.white,
          ),
          title: const Text('Mon profil',
              style: TextStyle(fontSize: 17, color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()));
          },
        ),
        const Divider(
          color: Colors.white,
        ),
        ListTile(
          leading: const Icon(
            Icons.share,
            size: 28,
            color: Colors.white,
          ),
          title: const Text("Partager l'app.",
              style: TextStyle(fontSize: 17, color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.star,
            size: 28,
            color: Colors.white,
          ),
          title: const Text('Nous évaluer',
              style: TextStyle(fontSize: 17, color: Colors.white)),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.15),
          child: OutlinedButton.icon(
            icon: const Icon(
              FontAwesome.logout,
              color: Colors.white,
              size: 24,
            ),
            label: const Text(
              'Se deconnecter',
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
            onPressed: () {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.WARNING,
                animType: AnimType.SCALE,
                desc: 'En etês-vous sûr(e)?',
                btnOkText: 'Oui',
                btnCancelText: 'Non',
                btnCancelOnPress: () {},
                btnOkOnPress: _logOut,
              ).show();
            },
            style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                shape: const StadiumBorder(),
                side: const BorderSide(width: 2, color: Colors.white)),
          ),
        ),
      ],
    );
  }

  _logOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
