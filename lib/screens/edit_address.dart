import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import '../constants.dart';

enum ButtonState {init, loading, done}

class EditAddress extends StatefulWidget {
  final DocumentSnapshot docSnap;
  const EditAddress({Key? key, required this.docSnap}) : super(key: key);

  @override
  _EditAddressState createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
  ButtonState state = ButtonState.init;
  TextEditingController adressNameController = TextEditingController();
  TextEditingController adressTelController = TextEditingController();
  TextEditingController adressDetailsController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;

  String? latitude;
  String? longitude;
  String? street;
  String? locality;

  final _formKey = GlobalKey<FormState>();

  bool enCours = false;

  @override
  void initState() {
    adressNameController = TextEditingController(text: widget.docSnap.get('adName'));
    adressTelController = TextEditingController(text: widget.docSnap.get('adTel'));
    adressDetailsController = TextEditingController(text: widget.docSnap.get('adDetails'));
    latitude = widget.docSnap.get('adLat');
    longitude = widget.docSnap.get('adLong');
    street = widget.docSnap.get('adStreet');
    locality = widget.docSnap.get('adLocality');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = state == ButtonState.done;
    final isLoading = state == ButtonState.init;

    return Scaffold(backgroundColor: const Color(0xfff2f3f7),
      appBar: AppBar(
        elevation: 4,
        backgroundColor: mainColor,
        title: const Text("Editer l'adresse"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: isLoading ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 65),
                child: buildLoading(),
              ) : Padding(
                padding: const EdgeInsets.all(15.0),
                child: buildDone(isDone),
              ),
            ),
            Form(
              key: _formKey,
              child: CupertinoFormSection(
                backgroundColor: const Color(0xff37904c),
                header: const Text('Informations sur la position',
                  style: TextStyle(color: Colors.white, fontSize: 14),),
                children: [
                  CupertinoFormRow(
                    helper: const Text('Ex: Maison, Chez Raul, etc...', style: TextStyle(fontSize: 14),),
                    child: CupertinoTextFormFieldRow(
                      maxLength: 25,
                      textInputAction: TextInputAction.next,
                      controller: adressNameController,
                      padding: const EdgeInsets.all(16),
                      placeholder: "Nom de l'adresse",
                      placeholderStyle: const TextStyle(color: Colors.black54),
                      validator: (value){
                        if(adressNameController.text.isEmpty |
                        adressTelController.text.isEmpty |
                        adressDetailsController.text.isEmpty){

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
                    ),
                  ),
                  const Divider(height: 6, thickness: 0.5, ),
                  CupertinoFormRow(
                    child: CupertinoTextFormFieldRow(
                      maxLength: 8,
                      keyboardType: TextInputType.phone,
                      controller: adressTelController,
                      textInputAction: TextInputAction.next,
                      padding: const EdgeInsets.all(16),
                      placeholder: "N° Tél. à contacter à l'arriver",
                      validator: (value){
                        if(value!.isEmpty){
                          return '';
                        }else if(value.length < 8){
                          return 'Numéro incorrect';
                        }
                      },
                      placeholderStyle: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  const Divider(height: 6, thickness: 0.5, ),
                  CupertinoFormRow(
                    helper: const Text('Ex: Hédzranawoe non loin de... En face ou a coté de...', style: TextStyle(fontSize: 14),),
                    child: CupertinoTextFormFieldRow(
                      textInputAction: TextInputAction.done,
                      controller: adressDetailsController,
                      padding: const EdgeInsets.all(16),
                      placeholder: 'Précision(s)...',
                      validator: (value){
                        if(value!.isEmpty){
                          return '';
                        }
                      },
                      placeholderStyle: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50,),
            Container(
                height: 1.4 * (MediaQuery.of(context).size.height / 20),
                width: 5 * (MediaQuery.of(context).size.width / 12),
                margin: const EdgeInsets.only(bottom: 20),
                child: enCours ? _buildSmallBtn() : RaisedButton(
                  elevation: 12,
                  color: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  onPressed: () async {
                    final isValid = _formKey.currentState!.validate();
                    if(isValid){
                      setState(() {
                        enCours = true;
                      });
                      try{
                        widget.docSnap.reference.delete();
                        FirebaseFirestore.instance.collection("users").doc(user!.uid).collection('addresses').doc(adressNameController.text).set({
                          'adName': adressNameController.text,
                          'adTel': adressTelController.text,
                          'adDetails': adressDetailsController.text,
                          'adLong': longitude,
                          'adLat': latitude,
                          'adStreet': street,
                          'adLocality': locality
                        }).whenComplete(() {
                          Navigator.of(context).pop();
                          Fluttertoast.showToast(
                            msg: 'Adresse enrégistrée avec succès',
                            fontSize: 18,
                          );
                        });
                      }catch(e){return;}
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
                )
            ),
          ],
        ),
      ),

    );
  }

  Widget buildLoading() => OutlinedButton(
    onPressed:() async {
      setState(() => state = ButtonState.loading);

      var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      var lat = position.latitude;
      var long = position.longitude;

      setState(() {
        latitude = "$lat";
        longitude = "$long";
      });

      setState(() => state = ButtonState.done);

    },
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:const [
            Icon(Icons.location_searching_rounded, color: mainColor),
            SizedBox(width: 5),
            Text(
              'Modifier la position GPS',
              style: TextStyle(color: mainColor, fontSize: 16, fontWeight: FontWeight.w600,),
            ),
          ]
      ),
    ),
    style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        side: const BorderSide(width: 2, color: mainColor)
    ),
  );

  Widget buildDone(bool isDone) {
    return Padding(
      padding: const EdgeInsets.all(6.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isDone ? 'Nouvelle position enrégistrée!' : 'En cours',
            style: const TextStyle(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(width: 15,),
          isDone ? const Icon(Icons.where_to_vote_rounded, color: Colors.green, size: 35,)
              : Container(height: 35, width: 35,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: mainColor),
            child: const Center(
              child: SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,)),
            ),
          )
        ],
      ),
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
