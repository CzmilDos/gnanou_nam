import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gnanou_nam/constants.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AdminWaitings extends StatefulWidget {
  const AdminWaitings({Key? key}) : super(key: key);

  @override
  _AdminWaitingsState createState() => _AdminWaitingsState();
}

class _AdminWaitingsState extends State<AdminWaitings> {
  User? user = FirebaseAuth.instance.currentUser;

  void sendPushMessage(String token, String commandId) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAASof9bmQ:APA91bHc_-8tavXaNDpaB7xa8x39EG3i7n7wBc3oyJrAy18BEwYt_xa9GQb5aI5F_GsBgJ4rZwTEOb8L7j3lpZvP8ITuI39TU0QeheJuu4gX5tC-ds7SvyMWhP5JWrMWNC5pT3xrnqaQ',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': "Votre commande numéro $commandId a été validé. La laveuse sera là d'un moment à l'autre!",
              'title': 'GnanouNam'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'route': 'history'
            },
            "to": token,
          },
        ),
      );
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f3f7),
      body: StreamBuilder<QuerySnapshot>(

          stream: FirebaseFirestore.instance
              .collection('commands')
              .where('isValidated', isEqualTo: false)
              .orderBy('createdAt', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SpinKitThreeBounce(
                  size: 30,
                  color: mainColor,
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data!.docs.isNotEmpty) {
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 6,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: ListTile(
                          onTap: () {
                            Fluttertoast.showToast(
                                msg: 'Maintenez pour valider', fontSize: 18);
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          title: Row(
                            children: [
                              const Text(
                                'Commande N° ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 18),
                              ),
                              Text(
                                snapshot.data!.docs[index]['commandId'],
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 16),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                snapshot.data!.docs[index]['customerName'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontSize: 20),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                snapshot.data!.docs[index]['commandStreet'] +
                                    ', ' +
                                    snapshot.data!.docs[index]
                                        ['commandLocality'] +
                                    ' | ' +
                                    snapshot.data!.docs[index]
                                        ['commandAddrDetails'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 17),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    snapshot.data!.docs[index]
                                            ['clothesNumber'] +
                                        ' Habits',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.black87, fontSize: 18),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  const Icon(
                                    Icons.arrow_right_outlined,
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    snapshot.data!.docs[index]['commandPrice']
                                            .toString() +
                                        ' FCFA',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                formattedDate(
                                    snapshot.data!.docs[index]['createdAt']),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.black87, fontSize: 16),
                              ),
                            ],
                          ),
                          onLongPress: () async {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.INFO_REVERSED,
                              animType: AnimType.SCALE,
                              desc: "Valider la commande?",
                              btnOkText: 'Oui',
                              btnCancelText: 'Non',
                              btnCancelOnPress: () {},
                              btnOkOnPress: () async {
                                await snapshot.data!.docs[index].reference
                                    .update({
                                  'isValidated': true,
                                  'isValidatedBy': user!.uid,
                                  'validatedAt': Timestamp.now()
                                });
                                String uploadedBySnap = snapshot.data!.docs[index]['uploadedBy'];
                                String commandSnap = snapshot.data!.docs[index]['commandId'];
                                DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users').doc(uploadedBySnap).get();
                                String token = snap['token'];
                                sendPushMessage(token, commandSnap);
                                Fluttertoast.showToast(
                                  msg: "Commande validée !",
                                  fontSize: 18,
                                );
                              },
                            ).show();
                          },
                        ),
                      );
                    });
              } else {
                return const Center(
                  child: Text(
                    "Aucune commande en attente...!",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                );
              }
            }
            return const Center(
              child: Text(
                "Une erreur s'esst produite",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            );
          }),
    );
  }

  String formattedDate(timeStamp) {
    var dateFromTimeStamp =
        DateTime.fromMillisecondsSinceEpoch(timeStamp.seconds * 1000);
    return DateFormat('dd-MM-yyyy à hh:mm a').format(dateFromTimeStamp);
  }
}
