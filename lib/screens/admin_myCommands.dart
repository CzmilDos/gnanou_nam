import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gnanou_nam/constants.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class AdminMyCommands extends StatefulWidget {
  const AdminMyCommands({Key? key}) : super(key: key);

  @override
  _AdminMyCommandsState createState() => _AdminMyCommandsState();
}

class _AdminMyCommandsState extends State<AdminMyCommands> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f3f7),
      body: Stack(children: [
        Center(
          child: Lottie.asset('images/78696-delivery-motorbike.json'),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('commands')
                .where('isValidatedBy', isEqualTo: user!.uid)
                .where('isDone', isEqualTo: false)
                .orderBy('validatedAt', descending: true)
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
                        String latitude =
                            snapshot.data!.docs[index]['commandLat'];
                        String longitude =
                            snapshot.data!.docs[index]['commandLong'];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 6,
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          child: ListTile(
                            onTap: () async {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.NO_HEADER,
                                animType: AnimType.SCALE,
                                desc: "Appeler le client ?",
                                btnOkText: 'Oui',
                                btnCancelText: 'Non',
                                btnCancelOnPress: () {},
                                btnOkOnPress: () async {
                                  final phoneNumber =
                                      snapshot.data!.docs[index]['commandTel'];
                                  await FlutterPhoneDirectCaller.callNumber(
                                      phoneNumber);
                                },
                              ).show();
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
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'Valildé le ' +
                                      formattedDate(snapshot.data!.docs[index]
                                          ['validatedAt']),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.black87, fontSize: 16),
                                ),
                              ],
                            ),
                            onLongPress: () {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.QUESTION,
                                animType: AnimType.SCALE,
                                desc: "Commande deja traitée ?",
                                btnOkText: 'Oui',
                                btnCancelText: 'Non',
                                btnCancelOnPress: () {},
                                btnOkOnPress: () async {
                                  await snapshot.data!.docs[index].reference
                                      .update({
                                    'isDone': true,
                                    'doneAt': Timestamp.now()
                                  });
                                  Fluttertoast.showToast(
                                    msg: "Commande traitée !",
                                    fontSize: 18,
                                  );
                                },
                              ).show();
                            },
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.my_location_rounded,
                                size: 30,
                                color: Color(0xff37904c),
                              ),
                              onPressed: () async {
                                bool service =
                                    await Geolocator.isLocationServiceEnabled();
                                LocationPermission permission;
                                permission = await Geolocator.checkPermission();
                                if (!service) {
                                  await Geolocator.openLocationSettings();
                                } else if (permission ==
                                    LocationPermission.denied) {
                                  permission =
                                      await Geolocator.requestPermission();
                                } else {
                                  String googleUrl =
                                      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
                                  await launch(googleUrl);
                                }
                              },
                            ),
                          ),
                        );
                      });
                } else {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Text(
                          "Vous n'avez validé aucune commande...!",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        )
                      ]);
                }
              }
              return const Center(
                child: Text(
                  "Une erreur s'esst produite",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              );
            }),
      ]),
    );
  }

  String formattedDate(timeStamp) {
    var dateFromTimeStamp =
        DateTime.fromMillisecondsSinceEpoch(timeStamp.seconds * 1000);
    return DateFormat('dd-MM-yyyy à hh:mm a').format(dateFromTimeStamp);
  }
}
