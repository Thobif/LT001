import 'package:abc/menu/targetmenu.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormFood extends StatefulWidget {
  final String userKey;

  FormFood({
    required this.userKey,
  });

  @override
  _FormFoodState createState() => _FormFoodState();
}

class _FormFoodState extends State<FormFood> {
  final kcal = TextEditingController();
  final fat = TextEditingController();
  final carb = TextEditingController();
  final pro = TextEditingController();

  @override
  void dispose() {
    kcal.dispose();
    fat.dispose();
    carb.dispose();
    pro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('กรอกสารอาหาร'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: fat,
                decoration: InputDecoration(
                  labelText: 'ไขมัน',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17.0),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              // Carb text field
              TextField(
                controller: carb,
                decoration: InputDecoration(
                  labelText: 'คาร์โบไฮเดรต',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17.0),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),

              // Pro text field
              TextField(
                controller: pro,
                decoration: InputDecoration(
                  labelText: 'โปรตีน',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17.0),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: () async {
                  double inputFat = double.parse(fat.text);
                  double inputCarb = double.parse(carb.text);
                  double inputPro = double.parse(pro.text);
                  

                double inputKcal = inputFat * 9 + inputPro * 4 + inputCarb * 4 ;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TargetMenu(
                        userKey: widget.userKey,
                        foodKey: 'none',
                        fat: inputFat,
                        carb: inputCarb,
                        pro: inputPro,
                        kcal: inputKcal,
                        orderQuantity: 1,
                      ),
                    ),
                  );
                },
                child: Text('ตกลง'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
