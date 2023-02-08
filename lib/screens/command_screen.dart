import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gnanou_nam/constants.dart';
import 'package:gnanou_nam/screens/add_address.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class CommandScreen extends StatefulWidget {
  const CommandScreen({Key? key}) : super(key: key);

  @override
  _HomeCommandScreen createState() => _HomeCommandScreen();
}

class _HomeCommandScreen extends State<CommandScreen> {
  TextEditingController clothesNumController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;
  String? selectedAddress;
  bool enCours = false;
  String? name;
  String? userToken;
  String? street;
  String? locality;
  String? latitude;
  String? longitude;
  String? number;
  String? details;

  void getMyData() async {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    setState(() {
      name = userDoc.get('name');
    });
  }

  @override
  void initState() {
    super.initState();
    getMyData();
  }

  @override
  void dispose() {
    super.dispose();
    clothesNumController.dispose();
  }

  void sendPushMessage() async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAASof9bmQ:APA91bHc_-8tavXaNDpaB7xa8x39EG3i7n7wBc3oyJrAy18BEwYt_xa9GQb5aI5F_GsBgJ4rZwTEOb8L7j3lpZvP8ITuI39TU0QeheJuu4gX5tC-ds7SvyMWhP5JWrMWNC5pT3xrnqaQ',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'Nouvelle commande en attente',
              'title': 'GnanouNam'
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            "to": '/topics/commands',
          },
        ),
      );
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    var cnum = int.tryParse(clothesNumController.text) ?? 0;
    var totalPrice = cnum * 150;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text('Commander une lessive'),
        centerTitle: true,
      ),
      body: Builder(builder: (context) {
        return Stack(children: [
          Center(
            child: Lottie.asset('images/76383-washing-machine.json',
                repeat: false),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 16,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 16.0),
                          child: Text(
                            'Détails sur la commande',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: TextFormField(
                              decoration: InputDecoration(
                                  label: const Text("Nombre d'habits"),
                                  counterText: '',
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.4),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15))),
                              onChanged: (value) {
                                setState(() {
                                  totalPrice = int.parse(value) * 150;
                                });
                              },
                              maxLength: 3,
                              autofocus: false,
                              keyboardType: TextInputType.phone,
                              controller: clothesNumController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Veuillez spécifier le nombre d'habits!";
                                }
                              },
                            ),
                          ),
                        ),

                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(user!.uid)
                                .collection('addresses')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 29.0),
                                  child: Text('Chargement...'),
                                ));
                              } else {
                                List<DropdownMenuItem> addressItems = [];
                                for (int i = 0;
                                i < snapshot.data!.docs.length;
                                i++) {
                                  DocumentSnapshot snap = snapshot.data!.docs[i];
                                  addressItems.add(DropdownMenuItem(
                                    child: Text(
                                      snap.id,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    value: snap.id,
                                  ));
                                }

                                return Padding(
                                  padding: const EdgeInsets.only(top: 8,bottom: 16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(color: Colors.black38, width: 1)
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.location_pin,
                                          size: 30,
                                          color: mainColor,
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        addressItems.isEmpty? GestureDetector(
                                          child: const Padding(
                                            padding: EdgeInsets.only(left: 0, top: 12, right: 12, bottom: 12),
                                            child: Text('Aucune adresse enrégistrée', style: TextStyle(fontSize: 17),),
                                          ),
                                          onTap: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAddress()));
                                          })
                                        : DropdownButton<dynamic>(
                                          items: addressItems,
                                          onChanged: (choosen) async {
                                            setState(() {
                                              selectedAddress = choosen;
                                            });
                                            final DocumentSnapshot addressDoc =
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(FirebaseAuth.instance
                                                .currentUser!.uid)
                                                .collection('addresses')
                                                .doc(selectedAddress)
                                                .get();
                                            setState(() {
                                              street = addressDoc.get('adStreet');
                                              locality =
                                                  addressDoc.get('adLocality');
                                              latitude = addressDoc.get('adLat');
                                              longitude =
                                                  addressDoc.get('adLong');
                                              number = addressDoc.get('adTel');
                                              details =
                                                  addressDoc.get('adDetails');
                                            });
                                          },
                                          value: selectedAddress,
                                          isExpanded: false,
                                          hint: const Text(
                                            "Choisir l'adresse",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }),
                      ],
                    ),
                  ),
                ),
                selectedAddress == null || clothesNumController.text == ''
                    ? Container()
                    : buildToPay(totalPrice: totalPrice, cnum: cnum)
              ],
            ),
          ),
        ]);
      }),
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

  Widget buildToPay({required int cnum, required int totalPrice}) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Facturation',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: const [
                    Expanded(
                      child: Text(
                        'Prix unitaire :',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text('150 FCFA',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Row(children: [
                    const Expanded(
                        child: Text('Prix sur le nombre... :',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold))),
                    Expanded(
                      child: Text('$totalPrice FCFA',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ]),
                ),
                const Divider(
                  thickness: 1.5,
                  color: Colors.black54,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(children: [
                    const Expanded(
                      child: Text('Total à payer :',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Text('$totalPrice FCFA',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 1.3 * (MediaQuery.of(context).size.height / 20),
        ),
        Container(
            height: 1.4 * (MediaQuery.of(context).size.height / 20),
            width: 4 * (MediaQuery.of(context).size.width / 8),
            margin: const EdgeInsets.only(bottom: 20),
            child: enCours
                ? _buildSmallBtn()
                : RaisedButton(
                    elevation: 12,
                    color: mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    onPressed: () async {
                      final isValid = _formKey.currentState!.validate();
                      if (cnum < 20) {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.NO_HEADER,
                          animType: AnimType.TOPSLIDE,
                          desc:
                              'Le nombre minimal pour une commande est de 20 habits...!',
                          btnOkOnPress: () {},
                        ).show();
                      } else if (isValid) {
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.WARNING,
                          animType: AnimType.SCALE,
                          desc: 'Etês-vous sûr de vouloir valider la commande?',
                          btnOkText: 'Oui',
                          btnCancelText: 'Non',
                          btnCancelOnPress: () {},
                          btnOkOnPress: () async {
                            setState(() {
                              enCours = true;
                            });
                            final commandId = const Uuid().v4().substring(0, 8);

                            User? user = FirebaseAuth.instance.currentUser;
                            final String clothesNumber =
                                clothesNumController.text.trim();
                            try {
                              await FirebaseFirestore.instance
                                  .collection('commands')
                                  .add({
                                'commandId': commandId,
                                'uploadedBy': user!.uid,
                                'customerName': name,
                                'commandLat': latitude,
                                'commandLong': longitude,
                                'commandStreet': street,
                                'commandLocality': locality,
                                'commandTel': number,
                                'commandAddrDetails': details,
                                'createdAt': Timestamp.now(),
                                'isValidated': false,
                                'isDone': false,
                                'isValidatedBy': '',
                                'validatedAt': '',
                                'doneAt': '',
                                'isVisible': true,
                                'clothesNumber': clothesNumber,
                                'commandPrice': totalPrice,
                                'commandAddress': selectedAddress
                              });
                              final DocumentSnapshot userDoc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .get();
                              setState(() {
                                userToken = userDoc.get('token');
                              });
                              await FirebaseMessaging.instance.getToken().then((token) async{
                                if(userToken != token) {
                                  FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                                    'token': token
                                  });
                                }
                              });
                              sendPushMessage();
                              setState(() {
                                enCours = false;
                              });
                              await AwesomeDialog(
                                context: context,
                                dialogType: DialogType.SUCCES,
                                animType: AnimType.TOPSLIDE,
                                desc: 'Commande effectuée avec succès...!',
                                btnOkOnPress: () {},
                              ).show();
                              clothesNumController.clear();
                              setState(() {
                                selectedAddress = null;
                              });
                            } catch (error) {
                              return;
                            }
                          },
                        ).show();
                      }
                    },
                    child: Text(
                      "Valider",
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


  /*showSnackBar(BuildContext context){
    return Flushbar(
      icon: Icon(Icons.error, size: 32, color: Colors.white,),
      shouldIconPulse: false,
      title: 'Test',
      message: 'erreur adresse',
      duration: Duration(seconds: 2),
      flushbarPosition: FlushbarPosition.TOP,
    )..show(context);
  }*/
}
