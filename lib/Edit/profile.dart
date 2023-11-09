import 'package:abc/Login/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final String userKey;
  ProfilePage({required this.userKey});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = '';
  String _gender = '';
  int _age = 0;
  int _weight = 0;
  int _height = 0;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.userKey)
          .get();

      if (documentSnapshot.exists) {
        setState(() {
          _userName = documentSnapshot.get('name');
          _gender = documentSnapshot.get('gender');
          _age = documentSnapshot.get('age');
          _weight = documentSnapshot.get('weight');
          _height = documentSnapshot.get('height');
        });
      } else {
        print('User not found!');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  Future<void> _saveUserData() async {
    try {
      if (_formKey.currentState!.validate()) {
        final Map<String, dynamic> updatedData = {
          'name': _userName,
          'gender': _gender,
          'age': _age,
          'weight': _weight,
          'height': _height,
        };

        await FirebaseFirestore.instance
            .collection('user')
            .doc(widget.userKey)
            .update(updatedData);

        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userKeyLast4Digits =
        widget.userKey.substring(widget.userKey.length - 4);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('โปรไฟล์'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage())); // Logout
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        _isEditing
                            ? TextFormField(
                                initialValue: _userName,
                                onChanged: (value) {
                                  setState(() {
                                    _userName = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณากรอกชื่อ';
                                  }
                                  return null;
                                },
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                _userName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('เพศ: ${_gender == 'male' ? 'ผู้ชาย' : 'ผู้หญิง'}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  _isEditing
                      ? TextFormField(
                          initialValue: _age.toString(),
                          onChanged: (value) {
                            // Check if the input value is a valid number before parsing
                            if (value.isEmpty) {
                              setState(() {
                                _age =
                                    0; // Set a default value or you can choose another appropriate value.
                              });
                            } else {
                              try {
                                setState(() {
                                  _age = int.parse(value);
                                });
                              } catch (e) {
                                print('Error parsing age: $e');
                                // You can handle the error here, like showing a warning to the user.
                                // For simplicity, we set _age to 0.
                                setState(() {
                                  _age = 0;
                                });
                              }
                            }
                          },
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกอายุ';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'อายุ',
                          ),
                        )
                      : Text('อายุ: $_age', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  _isEditing
                      ? TextFormField(
                          initialValue: _weight.toString(),
                          onChanged: (value) {
                            // Check if the input value is a valid number before parsing
                            if (value.isEmpty) {
                              setState(() {
                                _weight =
                                    0; // Set a default value or you can choose another appropriate value.
                              });
                            } else {
                              try {
                                setState(() {
                                  _weight = int.parse(value);
                                });
                              } catch (e) {
                                print('Error parsing weight: $e');
                                // You can handle the error here, like showing a warning to the user.
                                // For simplicity, we set _weight to 0.
                                setState(() {
                                  _weight = 0;
                                });
                              }
                            }
                          },
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกน้ำหนัก';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'น้ำหนัก',
                          ),
                        )
                      : Text('น้ำหนัก: $_weight',
                          style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  _isEditing
                      ? TextFormField(
                          initialValue: _height.toString(),
                          onChanged: (value) {
                            // Check if the input value is a valid number before parsing
                            if (value.isEmpty) {
                              setState(() {
                                _height =
                                    0; // Set a default value or you can choose another appropriate value.
                              });
                            } else {
                              try {
                                setState(() {
                                  _height = int.parse(value);
                                });
                              } catch (e) {
                                print('Error parsing height: $e');
                                // You can handle the error here, like showing a warning to the user.
                                // For simplicity, we set _height to 0.
                                setState(() {
                                  _height = 0;
                                });
                              }
                            }
                          },
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'กรุณากรอกส่วนสูง';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'ส่วนสูง',
                          ),
                        )
                      : Text('ส่วนสูง: $_height',
                          style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  Text('เบอร์โทรศัพท์: ****$userKeyLast4Digits',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: _saveUserData,
              child: Icon(Icons.save),
            )
          : null,
    );
  }
}
