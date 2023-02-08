import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gnanou_nam/constants.dart';
import 'package:gnanou_nam/screens/add_address.dart';
import 'package:gnanou_nam/screens/edit_address.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  _AddressesScreenState createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xfff2f3f7),
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text('Mes adresses'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: mainColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        icon: const Icon(Icons.add_location, size: 30,),
        label: const Text('Ajouter une adresse', style: TextStyle(fontSize: 16),),
        onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddAddress()));
          },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('addresses')
              .snapshots(),
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: SpinKitThreeBounce(
                size: 30,
                color: mainColor,
              ),
              );
            }else if (snapshot.connectionState == ConnectionState.active){
              if(snapshot.data!.docs.isNotEmpty){
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index){
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                        ),
                        elevation: 8,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: ListTile(
                          onTap: (){
                            Fluttertoast.showToast(
                                msg: 'Maintenez pour supprimer',
                                fontSize: 18
                            );
                          },
                          onLongPress: (){
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.QUESTION,
                              animType: AnimType.SCALE,
                              desc: 'Etês-vous sûr de vouloir supprimer cette adresse?',
                              btnOkText: 'Oui',
                              btnCancelText: 'Non',
                              btnCancelOnPress: () {},
                              btnOkOnPress: () {
                                snapshot.data!.docs[index].reference.delete();
                                Fluttertoast.showToast(
                                  msg: "Adresse supprimée...!",
                                  fontSize: 18,
                                );
                              },
                            ).show();
                          },
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          title: Text(
                            snapshot.data!.docs[index]['adName'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 22
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10,),
                              Text(
                                snapshot.data!.docs[index]['adDetails'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16
                                ),
                              ),
                              const SizedBox(height: 10,),
                              Text(
                                snapshot.data!.docs[index]['adTel'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 30,
                              color: Color(0xff37904c),
                            ),
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => EditAddress(docSnap: snapshot.data!.docs[index])));
                            },
                          ),
                        ),
                      );
                    }
                );
              }else{
                return const Center(
                  child: Text('Aucune adresse enrégistrée...!',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87
                    ),),
                );
              }
            }
            return const Center(
              child: Text("Une erreur s'esst produite",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),

            );
          }
      ),
    );
  }
}
