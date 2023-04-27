import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:abc/home/home.dart';

class TargetPage extends StatefulWidget {
  final String userKey;

  TargetPage({required this.userKey});

  @override
  _TargetPageState createState() => _TargetPageState();
}

class _TargetPageState extends State<TargetPage> {
  int age = 0;
  String gender = '';
  int weight = 0;
  int height = 0;
  int activityLevel = 0;
  int exerciseLevel = 0;
  int fat = 0;
  int lbm = 0; // เพิ่มตัวแปร LBM
  double BMR = 0.0;
  int neat = 0;
  double reslut = 0.0;
  double TG_cal = 0.0;
  double TG_pro = 0.0;
  double TG_carb = 0.0;
  double TG_fat = 0.0;
  int R_cal = 0;
  int R_pro = 0;
  int R_carb = 0;
  int R_fat = 0;

  @override
  void initState() {
    super.initState();
    getUserData(widget.userKey);
  }

  void getUserData(String userKey) async {
    CollectionReference users = FirebaseFirestore.instance.collection('user');
    DocumentSnapshot snapshot = await users.doc(userKey).get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

      setState(() {
        age = data['age'] ?? 0;
        gender = data['gender'] ?? '';
        weight = data['weight'] ?? 0;
        height = data['height'] ?? 0;
        activityLevel = data['activityLevel'] ?? 0;
        exerciseLevel = data['exerciseLevel'] ?? 0;
        fat = data['fat'] ?? 0;

        // คำนวณค่า LBM

        lbm = weight - (fat * weight ~/ 100);
        // คำนวณค่า BMR
        if (gender == 'male') {
          BMR = (13.587 * lbm) + (9.613 * fat) + 198 - (3.351 * age) + 674;
        } else {
          BMR = (13.587 * lbm) + (9.613 * fat) - (3.351 * age) + 674;
        }

        neat = (activityLevel + exerciseLevel) ~/ 2;
        if (neat == 1) {
          reslut = 1.1;
        } else if (neat == 2) {
          reslut = 1.3;
        } else if (neat == 3) {
          reslut = 1.5;
        } else if (neat == 4) {
          reslut = 1.7;
        } else {
          reslut = 1.9;
        }

        TG_cal = BMR * reslut;
        TG_pro = 2.2 * lbm * 4;
        TG_fat = (TG_cal - TG_pro) / 4.0;
        TG_carb = (TG_cal - TG_pro) - TG_fat;

        TG_fat = TG_fat / 2;
        TG_pro = TG_pro + TG_fat;
      });
      saveTargetData();
    } else {
      print('User not found');
    }
  }

  void saveTargetData() async {
    CollectionReference targets =
        FirebaseFirestore.instance.collection('target');

    // Calculate values
    int int_TG_cal = TG_cal.round();
    int int_TG_carb = TG_carb.round();
    int int_TG_fat = TG_fat.round();
    int int_TG_pro = TG_pro.round();
    DateTime currentDate = DateTime.now();
    DateTime currentDateWithoutTime =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    // Reference user document by userKey
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('user').doc(widget.userKey);

    // Save target data
    await targets.add({
      'TG_cal': int_TG_cal,
      'TG_carb': int_TG_carb,
      'TG_fat': int_TG_fat,
      'TG_pro': int_TG_pro,
      'date': currentDateWithoutTime,
      'phone': userRef, // Save userRef in 'phone' field
    });
    CollectionReference result =
        FirebaseFirestore.instance.collection('result');

    FirebaseFirestore.instance.collection('user').doc(widget.userKey);

    await result.add({
      'R_cal': R_cal,
      'R_carb': R_carb,
      'R_fat': R_fat,
      'R_pro': R_pro,
      'date': currentDateWithoutTime,
      'phone': userRef, // Save userRef in 'phone' field
      'food_ID': null,
      'quantity': null,
    });

    // Navigate to HomePage and pass userKey
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => HomeScreen(userKey: widget.userKey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Target Data'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
