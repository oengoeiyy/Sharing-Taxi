import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sharing_taxi/main.dart';
import 'package:sharing_taxi/screens/a_my_bottom_appbar.dart';
import 'package:sharing_taxi/screens/a_my_drawer.dart';
import 'package:sharing_taxi/screens/d2_from_saved_journey_screen.dart';
import 'package:sharing_taxi/screens/f_add_saved_location_screen.dart';
import 'package:sharing_taxi/screens/f_edit_saved_location_screen.dart';

class SavedLocationScreen extends StatefulWidget {
  const SavedLocationScreen({Key? key}) : super(key: key);

  @override
  State<SavedLocationScreen> createState() => _SavedLocationScreenState();
}

class _SavedLocationScreenState extends State<SavedLocationScreen> {
  CollectionReference passengerCollection =
      FirebaseFirestore.instance.collection("passengers");

  bool isDelete = false;
  String name = '';
  String docID = '';

  bool isFree = true;

  getUser() async {
    var user = await FirebaseFirestore.instance
        .collection('passengers')
        .doc(auth.currentUser!.uid)
        .get();

    isFree = user['isFree'];

    //return user;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    //final auth = FirebaseAuth.instance;
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 247, 247, 247),
        drawer: const MyDrawer(),
        appBar: AppBar(
          //iconTheme: const IconThemeData(color: Colors.orange),
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            "Saved Location ♡",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.height * 0.1,
          height: MediaQuery.of(context).size.height * 0.1,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const AddSavedLocationScreen();
              }));
            },
            backgroundColor: Colors.deepOrange.shade400,
            child: Icon(
              Icons.add_location_alt_outlined,
              size: MediaQuery.of(context).size.height * 0.05,
              color: Colors.white,
            ),
          ),
        ),
        bottomNavigationBar: const BottomAppBar(
          //color: Colors.pink,
          child: MyBottomAppbar(
            page: 'savedlocation',
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              isDelete = false;
            });
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('passengers')
                        .doc(auth.currentUser!.uid)
                        .collection('saved_locations')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.data!.docs.isEmpty) {
                        return Align(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Add your fisrt saved location here",
                                style: TextStyle(fontSize: 15),
                              ),
                              Icon(
                                Icons.trending_down,
                                size: 45,
                              )
                            ],
                          ),
                        );
                      }

                      return Stack(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: ((context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                child: SizedBox(
                                  height: 110,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        if (isFree == false) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "You are currently in the journey.",
                                              gravity: ToastGravity.CENTER,
                                              timeInSecForIosWeb: 7);
                                        } else {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return FromSavedJourneyScreen(
                                                endLat:
                                                    snapshot.data!.docs[index]
                                                        ['latitude'] as double,
                                                endLng:
                                                    snapshot.data!.docs[index]
                                                        ['longitude'] as double,
                                                endAddress: snapshot.data!
                                                    .docs[index]['address'],
                                                placeName: snapshot.data!
                                                    .docs[index]['placeName'],
                                                detail: snapshot.data!
                                                    .docs[index]['detail']);
                                          }));
                                        }
                                      },
                                      style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(1),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                side: const BorderSide(
                                                    width: 0.5,
                                                    color: Color.fromARGB(
                                                        255, 213, 213, 213)))),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color.fromARGB(
                                                    255, 255, 255, 255)),
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              //color: Colors.amber,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 25,
                                                        child: Icon(
                                                          Icons.location_pin,
                                                          color:
                                                              Colors.deepOrange,
                                                          size: 21,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "${snapshot.data!.docs[index]['placeName']}",
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 25,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "${snapshot.data!.docs[index]['detail']}",
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.2,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.1,
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.edit,
                                                        color:
                                                            Colors.orange[200],
                                                        size: 22,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) {
                                                          return EditSavedLocationScreen(
                                                              id: snapshot
                                                                  .data!
                                                                  .docs[index]
                                                                  .id);
                                                        }));
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.1,
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color:
                                                            Colors.orange[200],
                                                        size: 22,
                                                      ),
                                                      onPressed: () async {
                                                        setState(() {
                                                          isDelete = true;
                                                          name = snapshot.data!
                                                                  .docs[index]
                                                              ['placeName'];
                                                          docID = snapshot.data!
                                                              .docs[index].id;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      )),
                                ),
                              );
                            }),
                          ),
                        ],
                      );
                    }),
              ),
              isDelete
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Color.fromARGB(134, 237, 237, 237),
                    )
                  : const SizedBox(
                      width: 0,
                      height: 0,
                    ),
              isDelete ? deletePopup() : const SizedBox(width: 0, height: 0),
            ],
          ),
        ));
  }

  deletePopup() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            //side: const BorderSide(color: Colors.grey, width: 0.5)
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 10,
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete,
                    color: Colors.deepOrange,
                    size: 30,
                  ),
                  title: Text('Do you want to delete\n$name'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                      onPressed: () async {
                        try {
                          await passengerCollection
                              .doc(auth.currentUser!.uid)
                              .collection('saved_locations')
                              .doc(docID)
                              .delete()
                              .then((value) {
                            Fluttertoast.showToast(
                                msg: "Delete Success",
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 10);
                          });
                          setState(() {
                            isDelete = false;
                            name = '';
                            docID = '';
                          });
                        } on FirebaseAuthException catch (e) {
                          String? message;

                          message = e.message;

                          Fluttertoast.showToast(
                              //msg: e.message.toString(),
                              msg: message.toString(),
                              gravity: ToastGravity.CENTER);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      child: Text('Cancel',
                          style: TextStyle(color: Colors.grey[700])),
                      onPressed: () {
                        setState(() {
                          isDelete = false;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
