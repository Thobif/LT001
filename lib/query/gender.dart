import 'package:flutter/material.dart';
import 'height.dart';

class SecondPage extends StatefulWidget {
  final String name;
  final String userKey;

  SecondPage({
    required this.name,
    required this.userKey,
    });

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String? gender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ขั้นตอนที่ 2: ใส่เพศของคุณ'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/query1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Spacer(),
                Center(
                  child: Text(
                    'เพศของคุณ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              gender = 'male';
                            });
                          },
                          child: Icon(
                            Icons.male,
                            size: 100,
                            color: gender == 'male' ? Colors.blue : Colors.grey,
                          ),
                        ),
                        Text('ชาย')
                      ],
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              gender = 'female';
                            });
                          },
                          child: Icon(
                            Icons.female,
                            size: 100,
                            color:
                                gender == 'female' ? Colors.pink : Colors.grey,
                          ),
                        ),
                        Text('หญิง')
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    child: Text('ต่อไป'),
                    onPressed: () {
                      // Handle next button press
                      if (gender != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ThirdPage(name: widget.name,userKey: widget.userKey, gender: gender!),
                          ),
                        );
                      } else {
                        // Show an error message if no gender is selected
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('กรุณาเลือกเพศของคุณ')),
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
                SizedBox(height: 50),
                Center(
                  child: Text(
                    'ขั้นตอนที่ 2/8',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
