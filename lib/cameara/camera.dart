import 'dart:convert';
import 'dart:io';
import 'package:abc/cameara/addfoodcamera.dart';
import 'package:abc/food/food_screen.dart';
import 'package:abc/home/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Classify extends StatelessWidget {
  final String userKey;

  Classify({required this.userKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ตรวจจับอาหาร'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
           decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          child: Center(
              child: SendImageButton(
            userKey: userKey,
          )),
        ),
      ),
    );
  }
}

class SendImageButton extends StatefulWidget {
  final String userKey;

  SendImageButton({required this.userKey});

  @override
  _SendImageButtonState createState() => _SendImageButtonState();
}



class _SendImageButtonState extends State<SendImageButton> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _sendImage() async {
    // Select image from gallery
    final XFile? imageFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile == null) {
      return;
    }

    // Create a MultipartRequest with "POST" method
    final url = Uri.parse('http://172.16.8.229:5000/');

    // final url = Uri.parse('http://172.16.8.229:8080');
    final request = http.MultipartRequest('POST', url);

    // Attach the image file to the request using the "image" key
    final file = await http.MultipartFile.fromPath('image', imageFile.path);
    request.files.add(file);

    // Create a client and send the request
    final client = http.Client();
    try {
      final response = await client.send(request);
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      List<dynamic> resultList = jsonResponse['result'];

      // Show the result
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            contentPadding: EdgeInsets.all(16.0),
            content: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300, maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  children: resultList
                      .map(
                        (result) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20.0)),
                                    ),
                                    contentPadding: EdgeInsets.all(16.0),
                                    content: Text(
                                      result.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 24.0),
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('ยืนยัน'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddFoodCamera(
                                                userKey: widget.userKey,
                                                menuName: result.toString(),
                                              ),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          primary: Colors.green,
                                          side: BorderSide(
                                            color: Colors.green,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      OutlinedButton(
                                        child: const Text('ยกเลิก'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          primary: Colors.red,
                                          side: BorderSide(
                                            color: Colors.red,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              result.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24.0),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('ปิด'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: 8), // เพิ่มช่องว่างระหว่างปุ่ม
        ElevatedButton(
          onPressed: _sendImage,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.image, size: 18),
                SizedBox(width: 4),
                Text('เลือกรูปภาพ', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(0),
          ),
        ),
       
        
      ],
    );
  }
}
