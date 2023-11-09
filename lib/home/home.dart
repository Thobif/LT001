import 'package:abc/cameara/camera.dart';
import 'package:abc/fitness/fitnesspage.dart';
import 'package:abc/food/food_screen.dart';
import 'package:abc/menu/menudetail.dart';
import 'package:flutter/material.dart';
import 'package:abc/Edit/profile.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'history3.dart';
import 'date2.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends StatefulWidget {
  final String userKey;

  HomeScreen({required this.userKey});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
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

  int numberOfDates = 0;
  
  void initState() {
    super.initState();
    initializeDateFormatting('th', null);
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
//////
    CollectionReference targets =
        FirebaseFirestore.instance.collection('target');

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('user').doc(widget.userKey);

          QuerySnapshot querySnapshotA =
        await targets.where('phone', isEqualTo: userRef).get();

    if (querySnapshotA.docs.isNotEmpty) {
      numberOfDates = querySnapshotA.docs.where((doc) {
        final data =
            doc.data() as Map<String, dynamic>?; // Cast to the expected type
        return data != null && data.containsKey('date');
      }).length;
    } else {
      print('No target data found for the specified date.');
    }
//////
    DateTime currentDate = DateTime.now();
    DateTime currentDateWithoutTime =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    QuerySnapshot querySnapshot = await targets
        .where('phone', isEqualTo: userRef)
        .where('date', isEqualTo: currentDateWithoutTime)
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

      for (QueryDocumentSnapshot doc in queryresultSnapshot.docs) {
        Map<String, dynamic> resultData = doc.data() as Map<String, dynamic>;
        R_cal += (resultData['R_cal'] ?? 0).toInt();
        R_pro += (resultData['R_pro'] ?? 0).toInt();
        R_carb += (resultData['R_carb'] ?? 0).toInt();
        R_fat += (resultData['R_fat'] ?? 0).toInt();
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

    PS_carb = R_carb / TG_carb;
    PS_fat = R_fat / TG_fat;
    PS_pro = R_pro / TG_pro;
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

  void _navigateTohistory(BuildContext context) {
    DateTime currentDate = DateTime.now();
    DateTime currentDateWithoutTime =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage3(
          userKey: widget.userKey,
          currentDateWithoutTime: currentDateWithoutTime,
        ),
      ),
    );
  }

  void _navigateToDatePage(BuildContext context, DateTime selectedDate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DatePage2(
          userKey: widget.userKey,
          currentDateWithoutTime:
              selectedDate, // ส่งวันที่ที่ต้องการให้แสดงข้อมูล
        ),
      ),
    );
  }

  void _reloadData() {
    getData(widget.userKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _reloadData(); // เมื่อคลิกที่ title ใน AppBar
          },
          child: Text('LiveWell'),
        ),
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
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => _navigateTohistory(context),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (numberOfDates != 1) ...[
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          DateTime currentDate = DateTime.now();
                          DateTime selectedDate =
                              currentDate.subtract(Duration(days: 1));
                          _navigateToDatePage(context, selectedDate);
                        },
                      ),
                      Text(
                         DateFormat('dd MMMM', 'th').format(DateTime.now()),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 48)
                    ] else ...[
                      SizedBox(width: 48),
                      Text(
                        DateFormat('dd MMMM', 'th').format(DateTime.now()),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 48) // สำหรับเว้นช่องว่างเทียบเท่ากับไอคอน
                    ],
                  ],
                ),
                  Text(
                    'ยินดีต้อนรับ, $name',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ขอให้เป็นวันที่ดีสำหรับสุขภาพของคุณ',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
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
                      child: Container(width: 250, height: 250),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${NumberFormat.decimalPattern().format(R_cal)}/${NumberFormat.decimalPattern().format(TG_cal)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'แคลอรี่',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                        '${NumberFormat.decimalPattern().format(R_carb)} / ${NumberFormat.decimalPattern().format(TG_carb)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

    final paintGray = Paint()
      ..color = Colors.grey // สีเทา
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (progressBlue > 0) {
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
    } else {
      canvas.drawArc(
          Rect.fromCircle(
              center: center, radius: outerRadius - paintGray.strokeWidth / 2),
          0,
          0,
          false,
          paintGray);
    }

    if (progressGreen > 0) {
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
    } else {
      canvas.drawArc(
          Rect.fromCircle(
              center: center, radius: outerRadius - paintGray.strokeWidth * 2),
          0,
          0,
          false,
          paintGray);
    }

    if (progressRed > 0) {
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
    } else {
      canvas.drawArc(
          Rect.fromCircle(
              center: center,
              radius: outerRadius - paintGray.strokeWidth * 3.5),
          0,
          0,
          false,
          paintGray);
    }
  }

  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
