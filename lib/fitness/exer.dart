import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class calKcal extends StatefulWidget {
  final String title;
  final String userKey; // ประกาศตัวแปร userKey ในหน้าจอ calKcal

  calKcal({required this.title, required this.userKey});

  @override
  _calKcalState createState() => _calKcalState();
}

class _calKcalState extends State<calKcal> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _calorieController = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime getDateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  void _saveCalorie() async {
    if (_formKey.currentState!.validate()) {
      int calories = int.parse(_calorieController.text);
      DateTime now = DateTime.now(); // รับวันที่และเวลาปัจจุบัน
      DateTime dateOnly =
          getDateOnly(now); // แปลงเป็นวันที่เท่านั้นโดยตัดเวลาออก

      DocumentReference userRef =
          FirebaseFirestore.instance.collection('user').doc(widget.userKey);

      // Save to Firestore
      await _firestore.collection('exer').add({
        'exer_cal': calories,
        'date': dateOnly, // เพิ่มวันที่เท่านั้นลงใน field "date"
        'number': userRef,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว')));
      _calorieController.clear();

      Navigator.pop(
          context, widget.userKey); // ส่งค่า userKey กลับไปยัง FitnessScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20),
                Text(
                  'จำนวนแคลอรี่ที่เผาพลาญ',
                  style: Theme.of(context).textTheme.headline6,
                ),
                SizedBox(height: 20),
                Container(
                  height: 51,
                  width: 260,
                  child: TextFormField(
                    controller: _calorieController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกจำนวนแคลอรี่';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'กรอกจำนวนแคลอรี่',
                      hintText: 'เช่น 100',
                      suffixText: 'Kcal',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveCalorie,
                  child: Text('บันทึก'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
