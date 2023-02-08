import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdressWidget extends StatefulWidget {
  const AdressWidget({
    required this.adName,
    required this.adTel,
    required this.adDetails,
    required this.adID,
  });

  final String adName;
  final String adTel;
  final String adDetails;
  final String adID;

  @override
  _AdressWidgetState createState() => _AdressWidgetState();
}

class _AdressWidgetState extends State<AdressWidget> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
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
            btnOkOnPress: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('addresses')
                  .doc(widget.adID)
                  .delete();
              Fluttertoast.showToast(
                  msg: "Adresse supprimée...!",
                  fontSize: 18,
              );
            },
          ).show();
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        title: Text(
          widget.adName,
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
              widget.adDetails,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16
              ),
            ),
            const SizedBox(height: 10,),
            Text(
              widget.adTel,
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
            color: Colors.black,
          ),
          onPressed: (){},
        ),
      ),
    );
  }
}
