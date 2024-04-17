import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:chat_app/Screens/ChatScreen/chatScreen.dart';
import 'package:chat_app/Utils/global.dart';
import 'package:chat_app/Widget/MyMessagesItem.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class MyMessagesScreen extends StatefulWidget {
  static const routeName = '/my-messages-screen';

  @override
  State<MyMessagesScreen> createState() => _MyMessagesScreenState();
}

class _MyMessagesScreenState extends State<MyMessagesScreen> {
  final List<String> _tabNames = [
    "All Users",
    "Recent Chats",
  ];
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 0.5.h,
          horizontal: 3.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 5.h,
            ),
            Text(
              'My Messages',
              style: TextStyle(
                fontSize: 7.w,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            Row(
              children: [
                for (var t = 0; t < _tabNames.length; t++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = t;
                        });
                      },
                      child: Column(
                        children: [
                          Text(
                            _tabNames[t],
                            style: TextStyle(
                              color: _selectedTab == t
                                  ? Colors.black
                                  : const Color(0xff757575),
                              fontWeight: _selectedTab == t
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                          Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: _selectedTab == t
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // SizedBox(
            //   height: 1.h,
            // ),
            _selectedTab == 0
                ? Container(
                    height: 72.h,
                    width: 100.w,
                    child: FutureBuilder(
                      future:
                          FirebaseFirestore.instance.collection('Users').get(),
                      // .doc(currentFirebaseUser!.uid)
                      // .collection('recentChat')
                      // .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final documents = snapshot.data!.docs;
//

                        return ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (context, index) =>
                              // Text(documents[index]['Publisher'])
                              GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        ChatScreen.routeName,
                                        arguments: {
                                          'userId': documents[index].id,
                                          'Publisher': documents[index]
                                                  ['userFirstName'] +
                                              ' ' +
                                              documents[index]['userLastName'],
                                        });
                                  },
                                  child: documents[index].id !=
                                          currentFirebaseUser!.uid
                                      ? MyMessagesItem(
                                          documents[index]['userFirstName'],
                                          '',
                                          DateTime.now(),
                                          documents[index].id,
                                          documents[index]['phoneNumber'],
                                          documents[index]['profilePic'] != null
                                              ? documents[index]['profilePic']
                                              : '',
                                        )
                                      : SizedBox.shrink()),
                        );
                      },
                    ))
                : Container(
                    height: 65.5.h,
                    width: 100.w,
                    child: FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(currentFirebaseUser!.uid)
                            .collection('recentChat')
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final documents = snapshot.data!.docs;

                          if (documents.length == 0) {
                            return Center(
                              child: Text(
                                'No Reecent Messages',
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          } else {
                            return ListView.builder(
                              itemCount: documents.length,
                              itemBuilder: (context, index) =>
                                  // Text(documents[index]['Publisher'])
                                  GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      ChatScreen.routeName,
                                      arguments: {
                                        'userId': documents[index].id,
                                        'Publisher': documents[index]['Name'],
                                      });
                                },
                                child: MyMessagesItem(
                                  documents[index]['Name'],
                                  documents[index]['lastText'],
                                  documents[index]['createdAt'].toDate(),
                                  documents[index].id,
                                  '',
                                  '',
                                ),
                              ),
                            );
                          }
                        })),
          ],
        ),
      ),
    );
  }
}
//done
