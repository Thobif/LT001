import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryPage3 extends StatefulWidget {
  final String userKey;
  final DateTime currentDateWithoutTime;

  HistoryPage3({required this.userKey, required this.currentDateWithoutTime});

  @override
  _HistoryPage3State createState() => _HistoryPage3State();
}

class _HistoryPage3State extends State<HistoryPage3> {
  String name = '';
  int R_cal = 0;
  int R_pro = 0;
  int R_carb = 0;
  int R_fat = 0;
  double PS_pro = 0.0;
  double PS_carb = 0.0;
  double PS_fat = 0.0;
  String foodName = 'N/A'; // เพิ่มตัวแปร foodName เพื่อเก็บชื่ออาหาร

  List<Map<String, dynamic>> groupedResults = [];

  @override
  void initState() {
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

    CollectionReference food = FirebaseFirestore.instance.collection('food');

    CollectionReference targets =
        FirebaseFirestore.instance.collection('target');

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('user').doc(widget.userKey);

    DateTime currentDate = widget.currentDateWithoutTime;
    DateTime currentDateWithoutTime =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    QuerySnapshot querySnapshot = await targets
        .where('phone', isEqualTo: userRef)
        .where('date', isEqualTo: widget.currentDateWithoutTime)
        .get();

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

    groupedResults = queryresultSnapshot.docs.map((doc) {
      Map<String, dynamic> resultData = doc.data() as Map<String, dynamic>;
      return {
        ...resultData,
        'documentId': doc.id, // เพิ่มค่า documentId ในข้อมูล
      };
    }).toList();

    if (queryresultSnapshot.docs.isNotEmpty) {
      num R_cal = 0;
      num R_pro = 0;
      num R_carb = 0;
      num R_fat = 0;

      for (var resultData in groupedResults) {
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

    setState(() {});
  }

  Future<void> deleteData(String documentId) async {
    // ทำการลบข้อมูลจาก Firestore โดยใช้ documentId
    final CollectionReference resultCollection =
        FirebaseFirestore.instance.collection('result');

    final resultDocRef = resultCollection.doc(documentId);
    await resultDocRef.delete();

    // หลังจากลบข้อมูลเสร็จแล้ว ลบข้อมูลออกจาก groupedResults
    setState(() {
      groupedResults.removeWhere((data) => data['documentId'] == documentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ประวัติการเพิ่มรายการอาหาร'),
        automaticallyImplyLeading: true,
      ),
      body: groupedResults.isEmpty
          ? Center(
              child: Text(
                'ไม่มีข้อมูลสำหรับ ${DateFormat('yyyy-MM-dd').format(widget.currentDateWithoutTime)}',
              ),
            )
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView.builder(
                itemCount: groupedResults.length,
                itemBuilder: (context, index) {
                  DateTime date = groupedResults[index]['date'].toDate();
                  double totalCalories =
                      (groupedResults[index]['R_cal'] ?? 0).toDouble();
                  double totalProtein =
                      (groupedResults[index]['R_pro'] ?? 0).toDouble();
                  double totalCarbs =
                      (groupedResults[index]['R_carb'] ?? 0).toDouble();
                  double totalFat =
                      (groupedResults[index]['R_fat'] ?? 0).toDouble();

                  String foodID = groupedResults[index]['food_ID'] ??
                      'N/A'; // Fetch food_ID

                  if (foodID != 'N/A' && foodID.isNotEmpty) {
                    fetchFoodData(foodID).then((queryFood) {
                      if (queryFood.docs.isNotEmpty) {
                        Map<String, dynamic> foodData =
                            queryFood.docs.first.data() as Map<String, dynamic>;
                        setState(() {
                          foodName = foodData['name']; // อัปเดตชื่ออาหาร
                        });
                      }
                    });
                  }

                  if (index == 0) {
                    return Column(
                      children: [
                        SizedBox(height: 20),

                        Center(
                          child: Text(
                            'วันที่: ${DateFormat('yyyy-MM-dd').format(date)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (totalCalories > 0)
                          Text('Result Calories: $totalCalories'),
                        if (totalProtein > 0)
                          Text('Result Protein: $totalProtein'),
                        if (totalCarbs > 0)
                          Text('Result Carbohydrates: $totalCarbs'),
                        if (totalFat > 0) Text('Result Fat: $totalFat'),
                        if (foodID != 'N/A') Text('Food ID: $foodID'),
                        if (foodName != 'N/A')
                          Text('Food Name: $foodName'), // แสดงชื่ออาหาร
                        Divider(),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                       
                          if (totalCalories > 0)
                            Text('แคลอรี่: $totalCalories'),
                          if (totalProtein > 0)
                            Text('โปรตีน: $totalProtein'),
                          if (totalCarbs > 0)
                            Text('คาร์โบไฮเดรต: $totalCarbs'),
                          if (totalFat > 0) Text('ไขมัน: $totalFat'),
                          Text(
                            '______________________________',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        padding: EdgeInsets.only(right: 10),
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          String documentId =
                              groupedResults[index]['documentId'];
                          deleteData(documentId);
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchFoodData(
      String foodID) async {
    return await FirebaseFirestore.instance
        .collection('food')
        .where('food_ID', isEqualTo: foodID)
        .get();
  }
}
