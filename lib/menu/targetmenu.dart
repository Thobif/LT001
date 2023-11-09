import 'package:abc/home/home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TargetMenu extends StatelessWidget {
  final String userKey;
  final String foodKey;
  final double fat;
  final double carb;
  final double pro;
  final double kcal;
  final int orderQuantity;

  TargetMenu({
    required this.userKey,
    required this.foodKey,
    required this.fat,
    required this.carb,
    required this.pro,
    required this.kcal,
    required this.orderQuantity,
  });

  void _submitOrder(BuildContext context) async {
    double totalKcal = kcal * orderQuantity;
    double totalFat = fat * orderQuantity;
    double totalCarb = carb * orderQuantity;
    double totalPro = pro * orderQuantity;

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('user').doc(userKey);

    // Add order to Firestore
    CollectionReference result =
        FirebaseFirestore.instance.collection('result');
    await result.add({
      'R_cal': totalKcal,
      'R_fat': totalFat * 9,
      'R_carb': totalCarb * 4,
      'R_pro': totalPro * 4,
      'date': DateTime.now(),
      'food_ID': foodKey,
      'phone': userRef,
      'quantity': orderQuantity,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          userKey: userKey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ตรวจสอบความถูกต้อง'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('แคลอรี่: ${(kcal * orderQuantity).toStringAsFixed(2)}'),
            Text('ไขมัน: ${(fat * orderQuantity).toStringAsFixed(2)}'),
            Text('คาร์โบไฮเดรต: ${(carb * orderQuantity).toStringAsFixed(2)}'),
            Text('โปรตีน: ${(pro * orderQuantity).toStringAsFixed(2)}'),
            Text('จำนวน: $orderQuantity'),
            ElevatedButton(
              child: Text('ยินยัน'),
              onPressed: () {
                _submitOrder(context);
              },
            ),
            ElevatedButton(
              child: Text('ยกเลิก'),
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
