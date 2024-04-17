import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/Screens/ChatScreen/MyMessagesScreen.dart';
import 'package:chat_app/Screens/homeScreen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:chat_app/Screens/Authentication/UserDetailScreen.dart';
import 'package:chat_app/Screens/ChatScreen/chatScreen.dart';
import 'package:chat_app/Screens/splashScreen.dart';
import 'package:chat_app/Screens/Authentication/OtpScreen.dart';
import 'package:chat_app/Screens/Authentication/phoneVerificationScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chat App',
        home: MySplashScreen(),
        routes: {
          OtpScreen.routeName: (context) => OtpScreen(),
          UserDetailScreen.routeName: (context) => UserDetailScreen(),
          ChatScreen.routeName: (context) => ChatScreen(),
          HomeScreen.routeName: (context) => HomeScreen(),
          MyMessagesScreen.routeName: (context) => MyMessagesScreen(),
          PhoneVerificationScreen.routeName: (context) =>
              PhoneVerificationScreen(),
        },
      );
    });
  }
}
