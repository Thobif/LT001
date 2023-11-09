import 'targetmenu.dart';
import 'package:flutter/material.dart';
import 'package:abc/food/restaurantmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MenuDetail extends StatefulWidget {
  final String userKey;
  final Restaurant restaurant;

  MenuDetail({required this.userKey, required this.restaurant});

  @override
  _MenuDetailState createState() => _MenuDetailState();
}

class _MenuDetailState extends State<MenuDetail> {
  List<Map<String, dynamic>> _foodList = [];
  QuerySnapshot? _querySnapshot;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    CollectionReference food = FirebaseFirestore.instance.collection('food');
    DocumentReference restaurantRef = FirebaseFirestore.instance
        .collection('shop')
        .doc(widget.restaurant.key);
    QuerySnapshot querySnapshot =
        await food.where('shop', isEqualTo: restaurantRef).get();
    if (querySnapshot.docs.isNotEmpty) {
      List<Map<String, dynamic>> foodList = querySnapshot.docs
          .map((doc) => {
                'name': doc['name'].toString(),
                'fat': doc['fat']?.toDouble() ?? 0.0,
                'carb': doc['carb']?.toDouble() ?? 0.0,
                'pro': doc['pro']?.toDouble() ?? 0.0,
                'Kcal': doc['kcal']?.toDouble() ?? 0.0,
              })
          .toList();
      setState(() {
        _foodList = foodList;
        _querySnapshot = querySnapshot;
      });
    } else {
      print('User not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _foodList.length,
                itemBuilder: (context, index) {
                  final food = _foodList[index];
                  return ListTile(
                    title: Text(food['name']),
                    subtitle: Text(
                        'Kcal: ${food['Kcal']}, Fat: ${food['fat']}, Carb: ${food['carb']}, Pro: ${food['pro']}'),
                    onTap: () {
                      if (_querySnapshot != null) {
                        // เพิ่มเงื่อนไขเช็ค _querySnapshot ไม่เท่ากับ null
                        int orderQuantity = 1; // default order quantity
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('จำนวนอาหาร'),
                              content: Container(
                                width: 150.0,
                                height: 50.0,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      hintText: 'กรอกจำนวนอาหาร'),
                                  onChanged: (value) {
                                    orderQuantity = int.tryParse(value) ?? 1;
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TargetMenu(
                                          userKey: widget.userKey,
                                          foodKey:
                                              _querySnapshot!.docs[index].id,
                                          fat: food['fat'],
                                          carb: food['carb'],
                                          pro: food['pro'],
                                          kcal: food['Kcal'],
                                          orderQuantity: orderQuantity,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
