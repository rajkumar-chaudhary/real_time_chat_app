import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/Utils/global.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../Widget/Messages.dart';
import '../../Widget/NewMessage.dart';

class ChatScreen extends StatefulWidget {
  static const routeName = '/chat-screen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var userId = '';
  var Publisher = '';
  bool check = false;

  @override
  void initState() {
    getUSerData();
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (check == false) {
      final routeArgs =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      if (routeArgs != null) {
        userId = routeArgs['userId']!.toString();
        Publisher = routeArgs['Publisher']!.toString();
      }
      check = true;
    }
    super.didChangeDependencies();
  }

  bool _isLoading = true;
  dynamic userData;
  void getUSerData() async {
    setState(() {
      _isLoading = true;
    });
    userData = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentFirebaseUser!.uid)
        .get();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: SizedBox(
          width: 60.w,
          child: Text(
            softWrap: true,
            'You are chatting with $Publisher',
            style: TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        )),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 78.h,
                child: Messages(userId),
              ),
              if (!_isLoading)
                NewMessages(userId, Publisher,
                    userData['userFirstName'] + ' ' + userData['userLastName']),
            ],
          ),
        ));
  }
}
