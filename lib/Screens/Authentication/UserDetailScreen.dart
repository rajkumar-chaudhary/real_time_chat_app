import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/Screens/homeScreen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../Utils/global.dart';
import 'package:chat_app/Utils/BlueBtn.dart';

class UserDetailScreen extends StatefulWidget {
  static const routeName = '/user-detail-screen';

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool isLoading = false;
  String userFirstName = '-';
  String userLastName = '-';
  String userEmail = '-';
  var phoneNumber;
  var check = false;

  @override
  void didChangeDependencies() {
    if (check == false) {
      final routeArgs =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      setState(() {
        phoneNumber = routeArgs['phoneNumber'];
      });
      check = true;
    }
    super.didChangeDependencies();
  }

  Future<void> setUserName() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentFirebaseUser!.uid)
        .set({
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'phoneNumber': phoneNumber,
      'userId': currentFirebaseUser!.uid,
      'profilePic': '',
      'email': userEmail,
    });
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          SizedBox(
            height: 10.h,
          ),
          Container(
            child: Text(
              'Enter Your Name',
              style: TextStyle(
                fontSize: 7.w,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 2.0.h,
          ),
          TextField(
            decoration: new InputDecoration(
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(30),
                  ),
                ),
                filled: true,
                prefixIcon: const Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 126, 44, 233),
                ),
                hintStyle: TextStyle(color: Colors.grey[800]),
                hintText: "Enter Your First name",
                fillColor: Colors.white70),
            onChanged: (value) {
              userFirstName = value;
            },
          ),
          SizedBox(
            height: 3.h,
          ),
          TextField(
            decoration: new InputDecoration(
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(30),
                  ),
                ),
                filled: true,
                prefixIcon: const Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 126, 44, 233),
                ),
                hintStyle: TextStyle(color: Colors.grey[800]),
                hintText: "Enter Your Last name",
                fillColor: Colors.white70),
            onChanged: (value) {
              userLastName = value;
            },
          ),
          SizedBox(
            height: 3.h,
          ),
          TextField(
            decoration: new InputDecoration(
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(30),
                  ),
                ),
                filled: true,
                prefixIcon: const Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 126, 44, 233),
                ),
                hintStyle: TextStyle(color: Colors.grey[800]),
                hintText: "Enter Your Email ID",
                fillColor: Colors.white70),
            onChanged: (value) {
              userEmail = value;
            },
          ),
          SizedBox(
            height: 1.h,
          ),
          isLoading
              ? const CircularProgressIndicator()
              : BlueBtn(
                  label: 'Proceed',
                  ontap: setUserName,
                )
        ]),
      ),
    );
  }
}
