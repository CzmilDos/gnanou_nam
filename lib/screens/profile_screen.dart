import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gnanou_nam/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController adressController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  final _updateFormKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;

  bool _isLoading = false;
  bool enCours = false;

  String? phoneNumber;
  String? quartier;
  String? email;
  String? name;

  @override
  void dispose() {
    phoneNumberController.dispose();
    fullNameController.dispose();
    adressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    try {
      _isLoading = true;
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      setState(() {
        email = userDoc.get('email');
        name = userDoc.get('name');
        phoneNumber = userDoc.get('phoneNumber');
        quartier = userDoc.get('quartier');
      });
    } catch (error) {
      return null;
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text('Mon profil'),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xfff2f3f7),
      body: Center(
          child: _isLoading
              ? const Center(
                  child: SpinKitThreeBounce(
                  size: 30,
                  color: mainColor,
                ))
              : SingleChildScrollView(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 55),
                        child: Card(
                          elevation: 10,
                          color: Colors.white,
                          margin: const EdgeInsets.all(30),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 40,
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(name!,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w600)),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Divider(
                                  thickness: 3,
                                  color: Colors.grey[300],
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Vos coordonnées :',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 22),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: userInfo(
                                    icon: Icons.email,
                                    content: email!,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: userInfo(
                                      icon: Icons.phone_android,
                                      content: phoneNumber == ''
                                          ? 'Non renseigné...'
                                          : phoneNumber!),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: userInfo(
                                      icon: Icons.location_pin,
                                      content: quartier == ''
                                          ? 'Non renseignée...'
                                          : quartier!),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Divider(
                                  thickness: 3,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: MaterialButton(
                                      onPressed: () {
                                        phoneNumberController.text =
                                            phoneNumber!;
                                        adressController.text = quartier!;
                                        fullNameController.text = name!;
                                        showModalBottomSheet(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            25))),
                                            isScrollControlled: true,
                                            context: context,
                                            builder: (context) {
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const SizedBox(
                                                    height: 14,
                                                  ),
                                                  Container(
                                                    width: 70,
                                                    height: 8,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        color: mainColor),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 30),
                                                    child: Text(
                                                      'Mettre à jour les infos',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                context)
                                                            .viewInsets
                                                            .bottom),
                                                    child: Form(
                                                      key: _updateFormKey,
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        15.0),
                                                            child:
                                                                TextFormField(
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              controller:
                                                                  fullNameController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      prefixIcon:
                                                                          Icon(
                                                                        Icons
                                                                            .person,
                                                                        color:
                                                                            mainColor,
                                                                      ),
                                                                      labelText:
                                                                          'Prénom'),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        15.0),
                                                            child:
                                                                TextFormField(
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              maxLength: 8,
                                                              controller:
                                                                  phoneNumberController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .phone,
                                                              validator:
                                                                  (value) {
                                                                if (value!
                                                                    .isEmpty) {
                                                                  return '';
                                                                } else if (value
                                                                        .length <
                                                                    8) {
                                                                  return 'Numéro incorrect';
                                                                }
                                                              },
                                                              decoration:
                                                                  const InputDecoration(
                                                                counterText: '',
                                                                prefixIcon:
                                                                    Icon(
                                                                  Icons.phone,
                                                                  color:
                                                                      mainColor,
                                                                ),
                                                                labelText:
                                                                    'N° Telephone',
                                                                hintText:
                                                                    "Sans l'indicatif",
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        15.0),
                                                            child:
                                                                TextFormField(
                                                              textInputAction:
                                                                  TextInputAction
                                                                      .next,
                                                              controller:
                                                                  adressController,
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              decoration:
                                                                  const InputDecoration(
                                                                      prefixIcon:
                                                                          Icon(
                                                                        Icons
                                                                            .location_pin,
                                                                        color:
                                                                            mainColor,
                                                                      ),
                                                                      labelText:
                                                                          'Quartier'),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        30.0),
                                                            child: enCours
                                                                ? _buildSmallBtn()
                                                                : MaterialButton(
                                                                    onPressed:
                                                                        () async {
                                                                      final isValid = _updateFormKey
                                                                          .currentState!
                                                                          .validate();
                                                                      if (isValid) {
                                                                        setState(
                                                                            () {
                                                                          name =
                                                                              fullNameController.text;
                                                                          phoneNumber =
                                                                              phoneNumberController.text;
                                                                          quartier =
                                                                              adressController.text;
                                                                        });
                                                                        await FirebaseFirestore
                                                                            .instance
                                                                            .collection('users')
                                                                            .doc(user!.uid)
                                                                            .update({
                                                                          'name':
                                                                              fullNameController.text,
                                                                          'phoneNumber':
                                                                              phoneNumberController.text,
                                                                          'quartier':
                                                                              adressController.text,
                                                                        }).whenComplete(() {
                                                                          Fluttertoast.showToast(
                                                                              msg: 'Profil mis à jour',
                                                                              fontSize: 18,
                                                                              gravity: ToastGravity.TOP);
                                                                          setState(
                                                                              () {
                                                                            enCours =
                                                                                false;
                                                                          });
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        });
                                                                      }
                                                                    },
                                                                    color:
                                                                        mainColor,
                                                                    elevation:
                                                                        6,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(15)),
                                                                    child:
                                                                        const Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              14),
                                                                      child:
                                                                          Text(
                                                                        'Enregistrer',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 18),
                                                                      ),
                                                                    ),
                                                                  ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                      color: mainColor,
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              phoneNumber == '' ||
                                                      quartier == ''
                                                  ? 'Completer'
                                                  : 'Mettre à jour',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            const Icon(
                                              Icons.update,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: size.width * 0.20,
                            height: size.height * 0.20,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    width: 2,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
                                image: const DecorationImage(
                                    image: AssetImage('images/avatar3.jpg'),
                                    fit: BoxFit.contain)),
                          )
                        ],
                      ),
                    ],
                  ),
                )),
    );
  }

  Widget userInfo({required IconData icon, required String content}) {
    return Row(
      children: [
        Icon(
          icon,
          color: mainColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            content,
            style: const TextStyle(color: Colors.black87, fontSize: 18),
          ),
        ),
      ],
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
