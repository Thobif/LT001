import 'package:flutter/material.dart';
import 'query/name.dart';
import 'Login/SplashScreen.dart';
import 'Login/OTPpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Edit/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp2());
}

class MyApp2 extends StatelessWidget {
  const MyApp2({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Manjari',
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
