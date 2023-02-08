import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gnanou_nam/constants.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  String waiting = 'En attente';
  String validate = 'Validée';

  Future _refresh() async{
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f3f7),
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text('Commandes en attente'),
        centerTitle: true,
      ),
      body: LiquidPullToRefresh(
        onRefresh: _refresh,
        showChildOpacityTransition: false,
        color: mainColor,
        animSpeedFactor: 3,
        springAnimationDurationInMilliseconds: 300,
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('commands')
                .where('uploadedBy', isEqualTo: user!.uid)
                .where('isVisible', isEqualTo: true)
                .orderBy('createdAt', descending: true)
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
                                  msg: 'Maintenez pour effacer',
                                  fontSize: 18
                              );
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'N° Commande: '+snapshot.data!.docs[index]['commandId'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18
                                  ),
                                ),
                                const SizedBox(height: 10,),
                                Text(
                                  snapshot.data!.docs[index]['commandAddress'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      fontSize: 19
                                  ),
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    Text(
                                      snapshot.data!.docs[index]['clothesNumber']+' Habits',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 18
                                      ),
                                    ),
                                    const SizedBox(width: 15,),
                                    const Icon(Icons.arrow_right_outlined,),
                                    const SizedBox(width: 15,),
                                    Text(
                                      snapshot.data!.docs[index]['commandPrice'].toString()+' FCFA',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 18, fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Text(
                                  formattedDate(snapshot.data!.docs[index]['createdAt']),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16
                                  ),
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    const Text(
                                      'Statut: ',
                                      style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      snapshot.data!.docs[index]['isValidated'] == false ? waiting : snapshot.data!.docs[index]['isDone'] == false ? validate : 'Traité',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 18, fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.copy,
                                size: 26,
                                color: Colors.black54,
                              ),
                              onPressed: (){
                                  Clipboard.setData(ClipboardData(text: snapshot.data!.docs[index]['commandId'])).then((value) => Fluttertoast.showToast(
                                      msg: 'N° commande copié',
                                      fontSize: 18
                                  ));
                              },
                            ),
                            onLongPress: (){
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.QUESTION,
                                animType: AnimType.SCALE,
                                desc: "Etês-vous sûr de vouloir effacer cette commande de l'historique ?",
                                btnOkText: 'Oui',
                                btnCancelText: 'Non',
                                btnCancelOnPress: () {},
                                btnOkOnPress: () {
                                  snapshot.data!.docs[index].reference.update({
                                    'isVisible': false
                                  });
                                  Fluttertoast.showToast(
                                    msg: "Adresse supprimée...!",
                                    fontSize: 18,
                                  );
                                },
                              ).show();
                            },
                          ),
                        );
                      }
                  );
                }else{
                  return const Center(
                    child: Text("Vous n'avez effectué aucune commande...!",
                      style: TextStyle(
                          fontSize: 16,
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
      ),
    );
  }

  String formattedDate(timeStamp){
    var dateFromTimeStamp =
        DateTime.fromMillisecondsSinceEpoch(timeStamp.seconds * 1000);
    return DateFormat('dd-MM-yyyy à hh:mm a').format(dateFromTimeStamp);
  }
}
