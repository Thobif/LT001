import 'package:flutter/material.dart';
import 'other.dart';

class FatPage extends StatefulWidget {
  final String name;
  final String gender;
  final String userKey;
  final int height;
  final int weight;
  final int age;
  final Map<String, bool> allergens;
  final Map<String, bool> diseases;

  FatPage({
    required this.name,
    required this.userKey,
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
    required this.allergens,
    required this.diseases,
  });

  @override
  _FatPageState createState() => _FatPageState();
}

class _FatPageState extends State<FatPage> {
  int? _bodyFatPercentage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ขั้นตอนที่ 8:ไขมันในร่างกาย'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 20),
              Image.asset(widget.gender == 'male'
                  ? 'assets/images/male.jpg'
                  : 'assets/images/female.jpg'), // แสดงรูปภาพตามเพศ
              SizedBox(height: 20),
              Text(
                'คุณมีเปอร์เซนไขมันในร่างกายเท่าไหร่?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    _bodyFatPercentage = int.tryParse(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: 'เปอร์เซนไขมันในร่างกาย',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 210),
              Center(
                child: ElevatedButton(
                  child: Text('ต่อไป'),
                  onPressed: () {
                    if (_bodyFatPercentage != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EighthPage(
                            name: widget.name,
                            userKey: widget.userKey,
                            gender: widget.gender,
                            height: widget.height,
                            weight: widget.weight,
                            age: widget.age,
                            allergens: widget.allergens,
                            diseases: widget.diseases,
                            bodyFatPercentage: _bodyFatPercentage!,
                          ),
                        ),
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 15, horizontal: 50)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ),
              // ... existing code ...
            ],
          ),
        ),
      ),
    );
  }
}
