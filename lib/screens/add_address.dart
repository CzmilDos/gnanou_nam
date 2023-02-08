import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gnanou_nam/constants.dart';
import 'package:geocoding/geocoding.dart';

enum ButtonState { init, loading, done }

class AddAddress extends StatefulWidget {
  const AddAddress({Key? key}) : super(key: key);

  @override
  State<AddAddress> createState() => _AddAddressState();
}

class _AddAddressState extends State<AddAddress> {
  ButtonState state = ButtonState.init;
  TextEditingController adressNameController = TextEditingController();
  TextEditingController adressTelController = TextEditingController();
  TextEditingController adressDetailsController = TextEditingController();

  String? latitude;
  String? longitude;
  String? street;
  String? locality;

  final _formKey = GlobalKey<FormState>();

  bool enCours = false;

  @override
  void dispose() {
    super.dispose();
    adressNameController.dispose();
    adressTelController.dispose();
    adressDetailsController.dispose();
  }

  void getCoordinate() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var lat = position.latitude;
    var long = position.longitude;

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    placemarks[0].toString();
    setState(() {
      latitude = "$lat";
      longitude = "$long";
      street =
          placemarks[0].street == null ? "Rue inconnue" : placemarks[0].street!;
      locality = placemarks[0].street == null
          ? "Localité inconnue"
          : placemarks[0].locality!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDone = state == ButtonState.done;
    final isLoading = state == ButtonState.init;

    return Scaffold(
      backgroundColor: const Color(0xfff2f3f7),
      appBar: AppBar(
        elevation: 4,
        backgroundColor: mainColor,
        title: const Text('Enregistrer une adresse'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 6),
                      child: buildLoading(),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: buildDone(isDone),
                    ),
            ),
            Form(
              key: _formKey,
              child: CupertinoFormSection(
                backgroundColor: const Color(0xff37904c),
                header: const Text(
                  'Informations sur la position',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                children: [
                  CupertinoFormRow(
                    helper: const Text(
                      'Ex: Maison, Chez Raul, etc...',
                      style: TextStyle(fontSize: 14),
                    ),
                    child: CupertinoTextFormFieldRow(
                      maxLength: 25,
                      textInputAction: TextInputAction.next,
                      controller: adressNameController,
                      padding: const EdgeInsets.all(16),
                      placeholder: "Nom de l'adresse",
                      placeholderStyle: const TextStyle(color: Colors.black54),
                      validator: (value) {
                        if (adressNameController.text.isEmpty |
                            adressTelController.text.isEmpty |
                            adressDetailsController.text.isEmpty) {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.NO_HEADER,
                            animType: AnimType.TOPSLIDE,
                            title: 'Obligatoire',
                            desc: 'Vous devez remplir tous les champs...!',
                            btnOkOnPress: () {},
                          ).show();
                        }
                      },
                    ),
                  ),
                  const Divider(
                    height: 6,
                    thickness: 0.5,
                  ),
                  CupertinoFormRow(
                    child: CupertinoTextFormFieldRow(
                      maxLength: 8,
                      keyboardType: TextInputType.phone,
                      controller: adressTelController,
                      textInputAction: TextInputAction.next,
                      padding: const EdgeInsets.all(16),
                      placeholder: "N° Tél. à contacter à l'arriver",
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '';
                        } else if (value.length < 8) {
                          return 'Numéro incorrect';
                        }
                      },
                      placeholderStyle: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  const Divider(
                    height: 6,
                    thickness: 0.5,
                  ),
                  CupertinoFormRow(
                    helper: const Text(
                      'Ex: Hédzranawoe non loin de... En face ou a coté de...',
                      style: TextStyle(fontSize: 14),
                    ),
                    child: CupertinoTextFormFieldRow(
                      textInputAction: TextInputAction.done,
                      controller: adressDetailsController,
                      padding: const EdgeInsets.all(16),
                      placeholder: 'Précision(s)...',
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '';
                        }
                      },
                      placeholderStyle: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Container(
                height: 1.4 * (MediaQuery.of(context).size.height / 20),
                width: 5 * (MediaQuery.of(context).size.width / 12),
                margin: const EdgeInsets.only(bottom: 20),
                child: enCours
                    ? _buildSmallBtn()
                    : RaisedButton(
                        elevation: 12,
                        color: mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onPressed: () async {
                          final isValid = _formKey.currentState!.validate();
                          if (longitude == null || latitude == null) {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.INFO,
                              animType: AnimType.TOPSLIDE,
                              title: 'Obligatoire',
                              desc:
                                  'Cliquez sur le boutton en haut pour enregistrer votre position...!',
                              btnOkOnPress: () {},
                            ).show();
                          } else if (isValid) {
                            setState(() {
                              enCours = true;
                            });
                            final String adName =
                                adressNameController.text.trim();
                            final String adTel =
                                adressTelController.text.trim();
                            final String adDetails =
                                adressDetailsController.text.trim();

                            try {
                              User? user = FirebaseAuth.instance.currentUser;
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(user!.uid)
                                  .collection('addresses')
                                  .doc(adName)
                                  .set({
                                'adName': adName,
                                'adTel': adTel,
                                'adDetails': adDetails,
                                'adLong': longitude,
                                'adLat': latitude,
                                'adStreet': street,
                                'adLocality': locality
                              });
                              Navigator.of(context).pop();
                              Fluttertoast.showToast(
                                msg: 'Adresse enrégistrée avec succès',
                                fontSize: 18,
                              );
                            } catch (e) {}
                          }
                        },
                        child: Text(
                          "Enregistrer",
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontSize: MediaQuery.of(context).size.height / 40,
                          ),
                        ),
                      )),
          ],
        ),
      ),
    );
  }

  Widget buildLoading() => OutlinedButton(
        onPressed: () async {
          bool service = await Geolocator.isLocationServiceEnabled();
          LocationPermission permission = await Geolocator.checkPermission();
          if (!service) {
            await Geolocator.openLocationSettings();
          } else if (permission == LocationPermission.denied ||
              permission == LocationPermission.deniedForever) {
            permission = await Geolocator.requestPermission();
            if (permission == LocationPermission.always ||
                permission == LocationPermission.whileInUse) {
              setState(() => state = ButtonState.loading);
              getCoordinate();
              setState(() => state = ButtonState.done);
            }
          } else {
            setState(() => state = ButtonState.loading);
            getCoordinate();
            setState(() => state = ButtonState.done);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Icon(Icons.location_searching_rounded, color: mainColor),
            SizedBox(width: 5),
            AutoSizeText(
              'Enregistrer votre position actuelle',
              style: TextStyle(
                color: mainColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
        ),
        style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            side: const BorderSide(width: 2, color: mainColor)),
      );

  Widget buildDone(bool isDone) {
    return Padding(
      padding: const EdgeInsets.all(6.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isDone ? 'Position enrégistrée!' : 'En cours',
            style: const TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            width: 15,
          ),
          isDone
              ? const Icon(
                  Icons.where_to_vote_rounded,
                  color: Colors.green,
                  size: 35,
                )
              : Container(
                  height: 35,
                  width: 35,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: mainColor),
                  child: const Center(
                    child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        )),
                  ),
                )
        ],
      ),
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
