import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl/intl.dart';

class MyMessagesItem extends StatelessWidget {
  final String name;
  final String text;
  final String lastName;
  // final DateTime date;
  final String id;
  final DateTime date;
  String profilePic;

  MyMessagesItem(
    this.name,
    this.text,
    this.date,
    this.id,
    this.lastName,
    this.profilePic,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.3.h),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: ListTile(
            leading: GestureDetector(
              onTap: () async {
                print(id);
                final userData = await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(id)
                    .get();
                profilePic = userData['profilePic'];
                final fullName =
                    userData['userFirstName'] + ' ' + userData['userLastName'];
                final phoneNumber = userData['phoneNumber'];
                final email = userData['email'];

                // ignore: use_build_context_synchronously
                return showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: SizedBox(
                        height: 35.h,
                        child: Column(children: [
                          profilePic != ''
                              ? CircleAvatar(
                                  minRadius: 100.0,
                                  maxRadius: 100.0,
                                  backgroundImage: NetworkImage(profilePic),
                                )
                              : const CircleAvatar(
                                  minRadius: 100.0,
                                  maxRadius: 100.0,
                                  child: Icon(
                                    Icons.person,
                                    size: 70,
                                  ),
                                ),

                          SizedBox(
                            height: 2.h,
                          ),
                          // name
                          Text(fullName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(
                            height: 1.h,
                          ),
                          Text(email,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(
                            height: 1.h,
                          ),
                          //
                          Text(
                              phoneNumber.substring(0, 2) +
                                  '******' +
                                  phoneNumber.substring(8),
                              style: const TextStyle(
                                fontSize: 14,
                                // fontWeight: FontWeight.bold,
                              )),
                        ]),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            // Close the dialog
                            Navigator.of(context).pop();
                          },
                          child: const Text('CLose'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(id)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: 5.h,
                      height: 5.h,
                      child: const Icon(
                        Icons.person,
                        size: 30,
                      ),
                    );
                  } else {
                    return Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(4),
                          ),
                        ),
                        height: 5.h,
                        width: 5.h,
                        child: snapshot.data!.data()!['profilePic'] == '' ||
                                snapshot.data!.data()!['profilePic'] == null
                            ? const Icon(
                                Icons.person,
                                size: 30,
                              )
                            : Image.network(
                                snapshot.data!.data()!['profilePic'],
                                fit: BoxFit.cover,
                              ));
                  }
                },
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 25.w,
                  child: Text(
                    '${name}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (text != '')
                  Text(
                    DateFormat.yMEd().format(date),
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
            subtitle: text != ''
                ? Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                : null,
            trailing: GestureDetector(
                onTap: () async {
                  final userData = await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(id)
                      .get();
                  profilePic = userData['profilePic'];
                  final fullName = userData['userFirstName'] +
                      ' ' +
                      userData['userLastName'];
                  final phoneNumber = userData['phoneNumber'];
                  final email = userData['email'];

                  // ignore: use_build_context_synchronously
                  return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: SizedBox(
                          height: 35.h,
                          child: Column(children: [
                            profilePic != ''
                                ? CircleAvatar(
                                    minRadius: 100.0,
                                    maxRadius: 100.0,
                                    backgroundImage: NetworkImage(profilePic),
                                  )
                                : const CircleAvatar(
                                    minRadius: 100.0,
                                    maxRadius: 100.0,
                                    child: Icon(
                                      Icons.person,
                                      size: 70,
                                    ),
                                  ),

                            SizedBox(
                              height: 2.h,
                            ),
                            // name
                            Text(fullName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(
                              height: 1.h,
                            ),
                            Text(email,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(
                              height: 1.h,
                            ),
                            //
                            Text(
                                phoneNumber.substring(0, 2) +
                                    '******' +
                                    phoneNumber.substring(8),
                                style: const TextStyle(
                                  fontSize: 14,
                                  // fontWeight: FontWeight.bold,
                                )),
                          ]),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              // Close the dialog
                              Navigator.of(context).pop();
                            },
                            child: const Text('CLose'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Icon(Icons.more_vert)),
          )),
    );
  }
}
