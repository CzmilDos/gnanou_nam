import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gnanou_nam/constants.dart';
import 'package:gnanou_nam/services/custom_rect_tween.dart';
import 'package:gnanou_nam/services/hero_dialog_route.dart';
import 'package:intl/intl.dart';

class AdminCommandDone extends StatefulWidget {
  const AdminCommandDone({Key? key}) : super(key: key);

  @override
  _AdminCommandDoneState createState() => _AdminCommandDoneState();
}

class _AdminCommandDoneState extends State<AdminCommandDone> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f3f7),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('commands')
              .where('isDone', isEqualTo: true)
              .where('isValidatedBy', isEqualTo: user!.uid)
              .orderBy('doneAt', descending: true)
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
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            HeroDialogRoute(
                              builder: (context) => Center(
                                child: CommandDetailsPopUp(
                                    commandSnap: snapshot.data!.docs[index]),
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: snapshot.data!.docs[index].id,
                          createRectTween: (begin, end) {
                            return CustomRectTween(begin: begin, end: end);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 8,
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: ListTile(
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
                                  Row(
                                    children: [
                                      Text(
                                        snapshot.data!.docs[index]
                                                ['clothesNumber'] +
                                            ' Habits',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 18),
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
                                        snapshot.data!
                                                .docs[index]['commandPrice']
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    });
              } else {
                return const Center(
                  child: Text(
                    "Vous n'avez traité aucune commande...!",
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

class CommandDetailsPopUp extends StatefulWidget {
  final DocumentSnapshot commandSnap;

  const CommandDetailsPopUp({Key? key, required this.commandSnap}) : super(key: key);

  @override
  State<CommandDetailsPopUp> createState() => _CommandDetailsPopUpState();
}

class _CommandDetailsPopUpState extends State<CommandDetailsPopUp> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.commandSnap.id,
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin, end: end);
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          color: Colors.white,
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate(widget.commandSnap.get('createdAt')),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87, fontSize: 16),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Commande N° ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 19),
                      ),
                      Text(
                        widget.commandSnap.get('commandId'),
                        style:
                            const TextStyle(color: Colors.black87, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 1.5,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Nom du client :',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Expanded(
                        child: Text(widget.commandSnap.get('customerName'),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Nbre d'habits :",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Expanded(
                        child: Text(widget.commandSnap.get('clothesNumber'),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Montant :',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Expanded(
                        child: Text(
                            widget.commandSnap.get('commandPrice').toString() +
                                ' FCFA',
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Adresse :',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      Expanded(
                        child: Text(
                            widget.commandSnap.get('commandStreet') +
                                ', ' +
                                widget.commandSnap.get('commandLocality'),
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Validé le ' +
                        formattedDate(widget.commandSnap.get('validatedAt')),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Traité le ' +
                        formattedDate(widget.commandSnap.get('doneAt')),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formattedDate(timeStamp) {
    var dateFromTimeStamp =
        DateTime.fromMillisecondsSinceEpoch(timeStamp.seconds * 1000);
    return DateFormat('dd-MM-yyyy à hh:mm a').format(dateFromTimeStamp);
  }
}
