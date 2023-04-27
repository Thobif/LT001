import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'exer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'finessHistoryPage.dart';
import 'package:intl/intl.dart';

class FitnessScreen extends StatefulWidget {
  final String userKey;

  FitnessScreen({required this.userKey});

  @override
  _FitnessScreenState createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getData(widget.userKey);
  }

  String name = '';
  double exercise2 = 0.0;
  int TG_cal = 0;
  int exercise = 0;
  double pal = 0.0;
  double exer_cal = 0.0;
  double RS = 0.0;

  late YoutubePlayerController _controller1;
  late YoutubePlayerController _controller2;
  late YoutubePlayerController _controller3;
  late YoutubePlayerController _controller4;
  late YoutubePlayerController _controller5;
  String videoUrl1 =
      "https://www.youtube.com/watch?v=SoyW4nCSP14&list=RDCMUCeLebRZ-VKfiwTXd25ojN-w&index=7";
  String videoUrl2 =
      "https://www.youtube.com/watch?v=3Oa4HISbY30&list=RDCMUCeLebRZ-VKfiwTXd25ojN-w&index=2";
  String videoUrl3 = "https://www.youtube.com/watch?v=dTqLoAElJXQ&t=117s";
  String videoUrl4 = "https://www.youtube.com/watch?v=R69fU-0l4JE";
  String videoUrl5 =
      "https://www.youtube.com/watch?v=iF9h5Q9csOI&list=RDCMUCeLebRZ-VKfiwTXd25ojN-w&index=4";

  final List<String> videoTitles = [
    '10 ท่า กระชับต้นขา แบบยืน',
    '11 ลดหน้าท้องแบบยืน ท้องล่าง',
    '10 ท่า กระชับช่วงแขนไหล่ แบบยืน',
    '10 ท่า กระชับช่วงแขนไหล่',
    'คาร์ดีโอแทนวิ่ง 15 นาที',
  ];
  final List<String> calories = [
    'เผาผลาญ 150 แคลอรี่',
    'เผาผลาญ 180 แคลอรี่',
    'เผาผลาญ 120 แคลอรี่',
    'เผาผลาญ 90 แคลอรี่',
    'เผาผลาญ 200 แคลอรี่',
  ];

  @override
  void initState() {
    super.initState();
    getData(widget.userKey);
    _controller1 = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(videoUrl1)!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
    _controller2 = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(videoUrl2)!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
    _controller3 = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(videoUrl3)!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
    _controller4 = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(videoUrl4)!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
    _controller5 = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(videoUrl5)!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  void initStatee() {
    super.initState();
    getData(widget.userKey);
  }

  void getData(String userKey) async {
    CollectionReference targets =
        FirebaseFirestore.instance.collection('target');

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('user').doc(widget.userKey);

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

  @override
  void dispose() {
    _controller1.pause();
    _controller2.pause();
    _controller3.pause();
    _controller4.pause();
    _controller5.pause();
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
    super.dispose();
  }

  void _navigateToHistoryPage(BuildContext context) {
    DateTime currentDate = DateTime.now();
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

  @override
  // โค้ดตัวอย่างที่แสดงส่วนของ Widget build

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    String formattedDate = '${currentDate.day}/${currentDate.month}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness'),
        backgroundColor: Colors.green,
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
                    _navigateToHistoryPage(context);
                  },
                ),
                Text(
                  DateFormat('dd MMMM').format(DateTime.now()),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 48), // สำหรับเว้นช่องว่างเทียบเท่ากับไอคอน
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 25),
                  buildVideoPlayer(_controller1, videoTitles[0], calories[0]),
                  SizedBox(height: 25),
                  buildVideoPlayer(_controller2, videoTitles[1], calories[1]),
                  SizedBox(height: 25),
                  buildVideoPlayer(_controller3, videoTitles[2], calories[2]),
                  SizedBox(height: 25),
                  buildVideoPlayer(_controller4, videoTitles[3], calories[3]),
                  SizedBox(height: 25),
                  buildVideoPlayer(_controller5, videoTitles[4], calories[4]),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => calKcal(
                    title: 'Calorie Calculator', userKey: widget.userKey)),
          );
        },
        child: Icon(Icons.add),
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
