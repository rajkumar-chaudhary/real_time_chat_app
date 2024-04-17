import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/Screens/Authentication/phoneVerificationScreen.dart';
import 'package:chat_app/Utils/global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<String> uploadImagesFunction(image) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('storage')
        .child(currentFirebaseUser!.uid + image.name + 'jpg');

    await ref.putFile(File(image.path)).whenComplete(() => null);

    final url = await ref.getDownloadURL();

    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 7.h,
          ),
          // netowrk image profile
          FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('Users')
                .doc(currentFirebaseUser!.uid)
                .get(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                    snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Center(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(children: [
                          snapshot.data!.data()!['profilePic'] != null
                              ? CircleAvatar(
                                  minRadius: 100.0,
                                  maxRadius: 100.0,
                                  backgroundImage: NetworkImage(
                                      snapshot.data!.data()!['profilePic']),
                                )
                              : CircleAvatar(
                                  minRadius: 100.0,
                                  maxRadius: 100.0,
                                  child: Icon(
                                    Icons.person,
                                    size: 70,
                                  ),
                                ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () async {
                                XFile? _pickedImage;

                                final picker = ImagePicker();
                                final pickedImage = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 80,
                                  // maxWidth: 150,
                                );
                                setState(() {
                                  _pickedImage = pickedImage;
                                });
                                final imageLink =
                                    await uploadImagesFunction(pickedImage);
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(currentFirebaseUser!.uid)
                                    .update({
                                  ''
                                      'profilePic': imageLink,
                                });
                                setState(() {});
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  child: Icon(Icons.edit),
                                  backgroundColor: Colors.grey[200],
                                ),
                              ),
                            ),
                          ),
                        ]),

                        SizedBox(
                          height: 2.h,
                        ),
                        // name
                        Text(
                            snapshot.data!.data()!['userFirstName'] +
                                ' ' +
                                snapshot.data!.data()!['userLastName'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(
                          height: 1.h,
                        ),
                        Text(snapshot.data!.data()!['email'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              // fontWeight: FontWeight.bold,
                            )),
                        SizedBox(
                          height: 1.h,
                        ),
                        Text(snapshot.data!.data()!['phoneNumber'],
                            style: TextStyle(
                              fontSize: 14,
                              // fontWeight: FontWeight.bold,
                            )),
                      ]),
                );
              }
            },
          ),
          SizedBox(
            height: 5.h,
          ),
          TextButton.icon(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context)
                  .pushReplacementNamed(PhoneVerificationScreen.routeName);
            },
            icon: Icon(Icons.logout),
            label: Text('log-out'),
          ),
        ],
      ),
    );
  }
}
