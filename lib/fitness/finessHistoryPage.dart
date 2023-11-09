import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'finessHistoryPage.dart';
import 'package:intl/intl.dart';
import 'fitnesspage.dart';
import 'package:intl/date_symbol_data_local.dart';

class finessHistoryPage extends StatefulWidget {
  final String userKey;
  final DateTime currentDateWithoutTime;

  finessHistoryPage(
      {required this.userKey, required this.currentDateWithoutTime});
  @override
  _finessHistoryPageState createState() => _finessHistoryPageState();
}

class _finessHistoryPageState extends State<finessHistoryPage> {
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeDateFormatting('th', null);
    getData(widget.userKey, widget.currentDateWithoutTime);
  }

  String name = '';
  double exercise2 = 0.0;
  int TG_cal = 0;
  int exercise = 0;
  double pal = 0.0;
  double exer_cal = 0.0;
  double RS = 0.0;

  @override
  void initState() {
    super.initState();
    getData(widget.userKey, widget.currentDateWithoutTime);

    // เช็คว่าวันที่ปัจจุบันเป็นวันที่เดียวกับ currentDateWithoutTime
    DateTime currentDate = DateTime.now();
    if (currentDate.year == widget.currentDateWithoutTime.year &&
        currentDate.month == widget.currentDateWithoutTime.month &&
        currentDate.day == widget.currentDateWithoutTime.day) {
      // ถ้าใช่ให้เรียกใช้งาน setState หลังจาก build สำเร็จ
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // ตรวจสอบว่า State ยังคงอยู่ในต้นไม้วิดเจ็ต
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FitnessScreen(
                userKey: widget.userKey,
              ),
            ),
          );
        }
      });
    }
  }

  void initStatee() {
    super.initState();
    getData(widget.userKey, widget.currentDateWithoutTime);
  }

  void getData(String userKey, DateTime currentDateWithoutTime) async {
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

    if (querySnapshot.docs.isNotEmpty) {
      Map<String, dynamic> targetData =
          querySnapshot.docs.first.data() as Map<String, dynamic>;
      setState(() {
        TG_cal = targetData['TG_cal'] ?? 0;
      });
    } else {
      print('No target data found for the specified date.');
    }

    CollectionReference users2 = FirebaseFirestore.instance.collection('user');
    DocumentSnapshot snapshot2 = await users2.doc(userKey).get();

    if (snapshot2.exists) {
      Map<String, dynamic> data = snapshot2.data() as Map<String, dynamic>;
      exercise = snapshot2['exerciseLevel'] ?? 0;
    } else {
      print('User not found');
    }

    CollectionReference exer = FirebaseFirestore.instance.collection('exer');
    DateTime startOfCurrentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);
    DateTime endOfCurrentDate = DateTime(
        currentDate.year, currentDate.month, currentDate.day, 23, 59, 59);

    QuerySnapshot queryexer = await exer
        .where('number', isEqualTo: userRef)
        .where('date', isGreaterThanOrEqualTo: startOfCurrentDate)
        .where('date', isLessThanOrEqualTo: endOfCurrentDate)
        .get();

    if (queryexer.docs.isNotEmpty) {
      num exer_cal = 0;

      for (QueryDocumentSnapshot doc in queryexer.docs) {
        Map<String, dynamic> exerdata = doc.data() as Map<String, dynamic>;
        exer_cal += (exerdata['exer_cal'] ?? 0).toInt();
      }

      setState(() {
        this.exer_cal = exer_cal.toDouble();
      });
    } else {
      print('No result data found for the specified date.');
    }

    if (exercise == 1) {
      exercise2 = 1.2;
    } else if (exercise == 2) {
      exercise2 = 1.375;
    } else if (exercise == 3) {
      exercise2 = 1.55;
    } else if (exercise == 4) {
      exercise2 = 1.725;
    } else {
      exercise2 = 1.9;
    }
    pal = TG_cal * exercise2;
    RS = exer_cal / pal;
    print('TG_cal: $TG_cal');
    print('exercise2: $exercise2');
    print('pal: $pal');
    print('exer_cal: $exer_cal');
    print('RS: $RS');
    setState(() {});
  }

  void _navigateToHistoryPage(BuildContext context) {
    DateTime currentDate = widget.currentDateWithoutTime;
    DateTime previousDate = currentDate.subtract(Duration(days: 1));
    DateTime previousDateWithoutTime =
        DateTime(previousDate.year, previousDate.month, previousDate.day);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => finessHistoryPage(
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
        builder: (context) => finessHistoryPage(
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

  void _navigateToDatePage(BuildContext context, DateTime selectedDate) {
    DateTime currentDate = widget.currentDateWithoutTime;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => finessHistoryPage(
          userKey: widget.userKey,
          currentDateWithoutTime: selectedDate,
        ),
      ),
    );
  }

  void _reloadData() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FitnessScreen(
          userKey: widget.userKey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    String formattedDate = '${currentDate.day}/${currentDate.month}';

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            _reloadData(); // เมื่อคลิกที่ title ใน AppBar
          },
          child: Text('LiveWell'),
        ),
        backgroundColor: Colors.green,
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    DateTime currentDate = widget.currentDateWithoutTime;
                    DateTime selectedDate = currentDate
                        .subtract(Duration(days: 1)); // ลดวันที่ 1 วัน
                    _navigateToDatePage(context, selectedDate);
                  },
                ),
                Text(
                  DateFormat('dd MMMM','th').format(widget.currentDateWithoutTime),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    DateTime currentDate = widget.currentDateWithoutTime;
                    DateTime selectedDate =
                        currentDate.add(Duration(days: 1)); // เพิ่มวันที่ 1 วัน
                    _navigateToDatePage(context, selectedDate);
                  },
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.red,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 20,
                  width: (MediaQuery.of(context).size.width - 32) * RS,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    '${NumberFormat.decimalPattern().format(exer_cal.toInt())} / '),
                Text('${NumberFormat.decimalPattern().format(pal.toInt())}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(width: 4),
                Text('ที่เผาพลาญไปแล้ว'),
                SizedBox(width: 16),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 4),
                Text('ที่ยังไม่เผาพลาญ'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVideoPlayer(
      YoutubePlayerController controller, String title, String calories) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          child: YoutubePlayer(
            controller: controller,
            showVideoProgressIndicator: true,
          ),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            Text(calories),
          ],
        ),
      ],
    );
  }
}