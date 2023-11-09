import 'package:abc/food/targetfood.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListFood extends StatelessWidget {
  final String userKey;

  ListFood({required this.userKey});

  @override
  Widget build(BuildContext context) {
    CollectionReference food = FirebaseFirestore.instance.collection('food');
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการอาหาร'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: food
            .where('shop',
                isEqualTo: FirebaseFirestore.instance
                    .collection('shop')
                    .doc('FLVCjXQVK0gjH80DETTm'))
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          // หากไม่มีข้อมูลจะแสดงข้อความ No data available
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No data available'),
            );
          }

          return Container(
             decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['name']),
                  subtitle: Text(
                      'Kcal: ${data['kcal']}, Fat: ${data['fat']}, Carb: ${data['carb']}, Pro: ${data['pro']}'),
                  onTap: () {
                    // เมื่อคลิกที่ ListTile แสดงหน้าต่างเพื่อระบุจำนวนจานที่ต้องการสั่งซื้อ
                    int quantity = 1;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('จำนวนอาหาร'),
                          content: TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'กรอกจำนวนอาหาร',
                            ),
                            onChanged: (value) {
                              quantity = int.tryParse(value) ?? 1;
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TargetFood(
                                      userKey: userKey,
                                      foodKey: document.id,
                                      kcal: data['kcal'].toDouble(),
                                      fat: data['fat'].toDouble(),
                                      carb: data['carb'].toDouble(),
                                      pro: data['pro'].toDouble(),
                                      quantity: quantity,
                                    ),
                                  ),
                                );
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
