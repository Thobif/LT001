import 'package:abc/cameara/camera.dart';
import 'package:abc/fitness/fitnesspage.dart';
import 'package:abc/food/food_screen.dart';
import 'package:abc/home/home.dart';
import 'package:flutter/material.dart';
import 'package:abc/Edit/profile.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryPage2 extends StatefulWidget {
  final String userKey;
  final DateTime currentDateWithoutTime;

  HistoryPage2({required this.userKey, required this.currentDateWithoutTime});

  @override
  _HistoryPage2State createState() => _HistoryPage2State();
}

class _HistoryPage2State extends State<HistoryPage2> {
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

  void initState() {
    super.initState();
    getData(widget.userKey);
  }

  void getData(String userKey) async {
    setState(() {
      name = '';
      TG_cal = 0;
      TG_pro = 0;
      TG_carb = 0;
      TG_fat = 0;
      R_cal = 0;
      R_pro = 0;
      R_carb = 0;
      R_fat = 0;
      PS_pro = 0.0;
      PS_carb = 0.0;
      PS_fat = 0.0;
    });
    setState(() {});
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
    DateTime startOfCurrentDate = DateTime(
        widget.currentDateWithoutTime.year,
        widget.currentDateWithoutTime.month,
        widget.currentDateWithoutTime.day,
        0,
        0,
        0);
    DateTime endOfCurrentDate = DateTime(
        widget.currentDateWithoutTime.year,
        widget.currentDateWithoutTime.month,
        widget.currentDateWithoutTime.day,
        23,
        59,
        59);

    QuerySnapshot queryresultSnapshot = await result
        .where('phone', isEqualTo: userRef)
        .where('date', isGreaterThanOrEqualTo: startOfCurrentDate)
        .where('date', isLessThanOrEqualTo: endOfCurrentDate)
        .get();

    if (queryresultSnapshot.docs.isNotEmpty) {
      num tempR_cal = 0;
      num tempR_pro = 0;
      num tempR_carb = 0;
      num tempR_fat = 0;

      for (QueryDocumentSnapshot doc in queryresultSnapshot.docs) {
        Map<String, dynamic> resultData = doc.data() as Map<String, dynamic>;

        tempR_cal += (resultData['R_cal'] ?? 0).toInt();
        tempR_pro += (resultData['R_pro'] ?? 0).toInt();
        tempR_carb += (resultData['R_carb'] ?? 0).toInt();
        tempR_fat += (resultData['R_fat'] ?? 0).toInt();
        print(tempR_carb);
      }
      setState(() {
        this.R_cal = tempR_cal.toInt();
        this.R_pro = tempR_pro.toInt();
        this.R_carb = tempR_carb.toInt();
        this.R_fat = tempR_fat.toInt();
      });
    } else {
      print('No result data found for the specified date.');
    }

    PS_carb = R_carb / TG_carb;
    PS_fat = R_fat / TG_fat;
    PS_pro = R_pro / TG_pro;
  }

  void _navigateToHistoryPage2(BuildContext context) {
    DateTime currentDate = widget.currentDateWithoutTime;
    DateTime previousDate = currentDate.subtract(Duration(days: 1));
    DateTime previousDateWithoutTime =
        DateTime(previousDate.year, previousDate.month, previousDate.day);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage2(
          userKey: widget.userKey,
          currentDateWithoutTime: previousDateWithoutTime,
        ),
      ),
    );
  }

  void _navigateToNextHistoryPage(BuildContext context) {
    DateTime currentDate = widget.currentDateWithoutTime;
    DateTime nextDate = currentDate.add(Duration(days: 1));
    DateTime nextDateWithoutTime =
        DateTime(nextDate.year, nextDate.month, nextDate.day);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage2(
          userKey: widget.userKey,
          currentDateWithoutTime: nextDateWithoutTime,
        ),
      ),
    );
  }

  bool isCurrentDate(DateTime date) {
    DateTime now = DateTime.now();
    DateTime todayWithoutTime = DateTime(now.year, now.month, now.day);
    DateTime inputDateWithoutTime = DateTime(date.year, date.month, date.day);

    return inputDateWithoutTime == todayWithoutTime;
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(userKey: widget.userKey),
      ),
    );
  }

  void _navigateToFood(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodScreen(userKey: widget.userKey),
      ),
    );
  }

  void _navigateToFitness(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FitnessScreen(userKey: widget.userKey),
      ),
    );
  }

  Future<bool> checkPreviousDateData() async {
    DateTime previousDate =
        widget.currentDateWithoutTime.subtract(Duration(days: 1));
    DateTime previousDateWithoutTime =
        DateTime(previousDate.year, previousDate.month, previousDate.day);

    CollectionReference targets =
        FirebaseFirestore.instance.collection('target');
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('user').doc(widget.userKey);

    QuerySnapshot querySnapshot = await targets
        .where('phone', isEqualTo: userRef)
        .where('date', isEqualTo: previousDateWithoutTime)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LiveWell'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () => _navigateToProfile(context),
          ),
          IconButton(
            icon: Icon(Icons.restaurant_menu),
            onPressed: () => _navigateToFood(context),
          ),
          IconButton(
            icon: Icon(Icons.fitness_center),
            onPressed: () => _navigateToFitness(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder<bool>(
                      future: checkPreviousDateData(),
                      builder:
                          (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasData && snapshot.data == true) {
                          return IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              _navigateToHistoryPage2(context);
                            },
                          );
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                    Text(
                      DateFormat('dd MMMM')
                          .format(widget.currentDateWithoutTime),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    isCurrentDate(widget.currentDateWithoutTime)
                        ? SizedBox
                            .shrink() // If currentDateWithoutTime is today, don't show the IconButton
                        : IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: () {
                              _navigateToNextHistoryPage(context);
                            },
                          ),
                  ],
                ),
                Text(
                  'ยินดีต้อนรับ, $name',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'ขอให้เป็นวันที่ดีสำหรับสุขภาพของคุณ',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    painter: CircularProgressPainter(PS_fat, PS_pro, PS_carb),
                    child: Container(width: 200, height: 200),
                  ),
                  Text(
                    '$R_cal/$TG_cal',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle,
                      color: Color(0xFFFE7E8B),
                      size: 16,
                    ),
                    Text(
                      'ไขมัน',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      '$R_fat / $TG_fat',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle,
                      color: Color(0xFF6CEBA8),
                      size: 16,
                    ),
                    Text(
                      'โปรตีน',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      '$R_pro / $TG_pro',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.circle,
                      color: Color(0xFF8FBBF8),
                      size: 16,
                    ),
                    Text(
                      'คาร์โบไฮเดรต',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                    Text(
                      '$R_carb / $TG_carb',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progressRed;
  final double progressGreen;
  final double progressBlue;

  CircularProgressPainter(
      this.progressRed, this.progressGreen, this.progressBlue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;

    final paintBlue = Paint()
      ..color = Color(0xFF8FBBF8)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
        Rect.fromCircle(
            center: center, radius: outerRadius - paintBlue.strokeWidth / 2),
        90 * (pi / 180),
        -progressBlue * 360 * (pi / 180),
        false,
        paintBlue);

    final paintGreen = Paint()
      ..color = Color(0xFF6CEBA8)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
        Rect.fromCircle(
            center: center, radius: outerRadius - paintGreen.strokeWidth * 2),
        90 * (pi / 180),
        -progressGreen * 360 * (pi / 180),
        false,
        paintGreen);

    final paintRed = Paint()
      ..color = Color(0xFFFE7E8B)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
        Rect.fromCircle(
            center: center, radius: outerRadius - paintRed.strokeWidth * 3.5),
        90 * (pi / 180),
        -progressRed * 360 * (pi / 180),
        false,
        paintRed);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
