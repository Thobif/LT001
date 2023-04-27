import 'package:abc/cameara/camera.dart';
import 'package:abc/fitness/fitnesspage.dart';
import 'package:abc/food/food_screen.dart';
import 'package:abc/menu/menudetail.dart';
import 'package:flutter/material.dart';
import 'package:abc/Edit/profile.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:abc/home/history2.dart';

class HistoryPage3 extends StatefulWidget {
  final String userKey;
  final DateTime currentDateWithoutTime;

  HistoryPage3({required this.userKey, required this.currentDateWithoutTime});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HistoryPage3> {
  String name = '';
  int TG_cal = 0;
  int TG_pro = 0;
  int TG_carb = 0;
  int TG_fat = 0;
  int R_cal = 0;
  int R_pro = 0;
  int R_carb = 0;
  int R_fat = 0;
  double PS_pro = 0.0;
  double PS_carb = 0.0;
  double PS_fat = 0.0;

  late DateTime currentDateWithoutTime;

  @override
  void initState() {
    currentDateWithoutTime = widget.currentDateWithoutTime;
    super.initState();
    getData(widget.userKey);
  }

  void getData(String userKey) async {
    CollectionReference users = FirebaseFirestore.instance.collection('user');
    DocumentSnapshot snapshot = await users.doc(userKey).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      name = data['name'] ?? '';
    } else {
      print('User not found');
    }

    CollectionReference targets =
        FirebaseFirestore.instance.collection('target');

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('user').doc(widget.userKey);

    DateTime currentDate = DateTime.now();

    QuerySnapshot querySnapshot = await targets
        .where('phone', isEqualTo: userRef)
        .where('date', isEqualTo: widget.currentDateWithoutTime)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      Map<String, dynamic> targetData =
          querySnapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        TG_cal = targetData['TG_cal'] ?? 0;
        TG_pro = targetData['TG_pro'] ?? 0;
        TG_carb = targetData['TG_carb'] ?? 0;
        TG_fat = targetData['TG_fat'] ?? 0;
      });
    } else {
      print('No target data found for the specified date.');
    }
    CollectionReference result =
        FirebaseFirestore.instance.collection('result');

    DateTime startOfCurrentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    DateTime endOfCurrentDate = DateTime(
        currentDate.year, currentDate.month, currentDate.day, 23, 59, 59);

    QuerySnapshot queryresultSnapshot = await result
        .where('phone', isEqualTo: userRef)
        .where('date', isGreaterThanOrEqualTo: startOfCurrentDate)
        .where('date', isLessThanOrEqualTo: endOfCurrentDate)
        .get();

    if (queryresultSnapshot.docs.isNotEmpty) {
      num R_cal = 0;
      num R_pro = 0;
      num R_carb = 0;
      num R_fat = 0;

      for (var doc in queryresultSnapshot.docs) {
        Map<String, dynamic> resultData = doc.data() as Map<String, dynamic>;
        R_cal += resultData['R_cal'] ?? 0;
        R_pro += resultData['R_pro'] ?? 0;
        R_carb += resultData['R_carb'] ?? 0;
        R_fat += resultData['R_fat'] ?? 0;
      }

      setState(() {
        this.R_cal = R_cal.toInt();
        this.R_pro = R_pro.toInt();
        this.R_carb = R_carb.toInt();
        this.R_fat = R_fat.toInt();
      });
    } else {
      print('No result data found for the specified date.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text('Name: $name'),
          ),
          ListTile(
            title: Text(
                'Date: ${DateFormat('yyyy-MM-dd').format(currentDateWithoutTime)}'),
          ),
          ListTile(
            title: Text('Target Calories: $TG_cal'),
          ),
          ListTile(
            title: Text('Target Protein: $TG_pro'),
          ),
          ListTile(
            title: Text('Target Carbohydrates: $TG_carb'),
          ),
          ListTile(
            title: Text('Target Fat: $TG_fat'),
          ),
          ListTile(
            title: Text('Result Calories: $R_cal'),
          ),
          ListTile(
            title: Text('Result Protein: $R_pro'),
          ),
          ListTile(
            title: Text('Result Carbohydrates: $R_carb'),
          ),
          ListTile(
            title: Text('Result Fat: $R_fat'),
          ),
        ],
      ),
    );
  }
}
