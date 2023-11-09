import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:abc/query/name.dart';
import 'result.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _phoneNumberController = TextEditingController();
  String _errorMessage = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _verifyPhoneNumber() async {
    String phoneNumber = _phoneNumberController.text;
    if (phoneNumber.length != 10) {
      // ตรวจสอบว่ามี 10 ตัวเลขหรือไม่
      setState(() {
        _errorMessage = 'คุณใส่เบอร์มือถือไม่ถูกต้อง';
      });
      return;
    }
    try {
      CollectionReference users = FirebaseFirestore.instance.collection('user');
      DocumentSnapshot doc = await users.doc(phoneNumber).get();

      if (doc.exists) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ResultPageWidget(userKey: phoneNumber)),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FirstPage(userKey: phoneNumber)),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  @override
  @override
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: FractionallySizedBox(
          heightFactor: 0.8, // ปรับตัวเลขนี้เพื่อเปลี่ยนตำแหน่งเนื้อหา
          child: SingleChildScrollView(
            // ใส่ SingleChildScrollView หากต้องการให้เนื้อหาสามารถเลื่อนขึ้นลงได้
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Logo1.png',
                  width: 200,
                  height: 200,
                ),
                SizedBox(height: 0),
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: -8,
                        blurRadius: 1,
                        offset: Offset(15, -10),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _phoneNumberController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: 'เบอร์โทรศัพท์',
                      hintText: '080-123-4567',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _verifyPhoneNumber,
                  child: Text(
                    'เข้าสู่ระบบ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 65, vertical: 12),
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(width: 2, color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
