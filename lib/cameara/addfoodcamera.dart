import 'package:abc/home/home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class AddFoodCamera extends StatefulWidget {
  final String userKey;
  final String menuName;
  AddFoodCamera({
    required this.userKey,
    required this.menuName,
  });

  DateTime currentDate = DateTime.now();

  @override
  State<AddFoodCamera> createState() => _AddFoodCameraState();
}

class _AddFoodCameraState extends State<AddFoodCamera> {
  String? foodKey;

  int R_cal = 0;
  int R_pro = 0;
  int R_carb = 0;
  int R_fat = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFoodData();
  }

  Future<void> fetchFoodData() async {
    CollectionReference result = FirebaseFirestore.instance.collection('result');
    CollectionReference food = FirebaseFirestore.instance.collection('food');
    DocumentReference shopRef = FirebaseFirestore.instance
        .collection('shop')
        .doc('FLVCjXQVK0gjH80DETTm');

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('user').doc(widget.userKey);
    QuerySnapshot querySnapshotfood = await food
        .where('name', isEqualTo: widget.menuName)
        .where('shop', isEqualTo: shopRef)
        .get();

    if (querySnapshotfood.docs.isNotEmpty) {
      Map<String, dynamic> targetData =
          querySnapshotfood.docs.first.data() as Map<String, dynamic>;
      foodKey = querySnapshotfood.docs.first.id;
      R_cal = targetData['kcal']?.toInt() ?? 0;
      R_pro = targetData['pro']?.toInt() ?? 0;
      R_carb = targetData['carb']?.toInt() ?? 0;
      R_fat = targetData['fat']?.toInt() ?? 0;

      setState(() {
        isLoading = false;
      });
    } else {
      print("error food");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _submitOrder(BuildContext context) async {
    CollectionReference result =
        FirebaseFirestore.instance.collection('result');
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('user').doc(widget.userKey);

    if (!isLoading) {
      DateTime currentDate = DateTime.now();

      QuerySnapshot querySnapshot = await result
          .where('phone', isEqualTo: userRef)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await result.add({
          'date': currentDate,
          'food_ID': foodKey,
          'phone': userRef,
          'R_cal': R_cal,
          'R_pro': R_pro * 4,
          'R_carb': R_carb * 4,
          'R_fat': R_fat * 9,
          'quantity': 1,
        });
        print("date = $currentDate");
        print("food_ID = $foodKey");
        print("phone = $userRef");
        print("R_cal = $R_cal");
        print("R_pro = $R_pro");
        print("R_carb = $R_carb");
        print("R_fat = $R_fat");
      } else {
        print("error result");
      }
    } else {
      print("Data is still loading.");
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          userKey: widget.userKey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ตรวจจับอาหาร'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('แคลอรี่: $R_cal'),
                  Text('โปรตีน: $R_pro'),
                  Text('คาร์โบไฮเดรต: $R_carb'),
                  Text('ไขมัน: $R_fat'),
                  ElevatedButton(
                    child: Text('ยืนยัน'),
                    onPressed: () {
                      _submitOrder(context);
                    },
                  ),
                  ElevatedButton(
                    child: Text('ยกเลิก'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // เลือกสีสีแดงหรือสีที่คุณต้องการ
                    ),
                    onPressed: () {
                      Navigator.pop(context); // ใช้ Navigator.pop เพื่อกลับไปหน้าก่อนหน้า
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
