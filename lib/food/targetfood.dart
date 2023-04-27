import 'package:abc/home/home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TargetFood extends StatelessWidget {
  final String userKey;
  final String foodKey;
  final double fat;
  final double carb;
  final double pro;
  final double kcal;
  final int quantity;

  TargetFood({
    required this.userKey,
    required this.foodKey,
    required this.fat,
    required this.carb,
    required this.pro,
    required this.kcal,
    required this.quantity,
  });

  void _submitOrder(BuildContext context) async {
    // Multiply the nutrient values by the order quantity
    double totalKcal = kcal * quantity;
    double totalFat = fat * quantity;
    double totalCarb = carb * quantity;
    double totalPro = pro * quantity;

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
      'quantity': quantity,
    });

    // Navigate back to Home screen
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
        title: Text('Target Food '),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Kcal: ${(kcal * quantity).toStringAsFixed(2)}'),
            Text('Fat: ${(fat * quantity).toStringAsFixed(2)}'),
            Text('Carb: ${(carb * quantity).toStringAsFixed(2)}'),
            Text('Pro: ${(pro * quantity).toStringAsFixed(2)}'),
            Text('Order quantity: $quantity'),
            ElevatedButton(
              child: Text('Submit order'),
              onPressed: () {
                _submitOrder(context);
              },
            ),
            ElevatedButton(
              child: Text('Cancel'),
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
