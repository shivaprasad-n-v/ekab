import 'package:flutter/material.dart';

import '../uder.dart';

class sedian extends StatefulWidget {
  @override
  _sedianState createState() => _sedianState();
}

class _sedianState extends State<sedian> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.green,),
      body: Column(
        children: [
         drive("peter", "Honda city", "25"),
         drive("parker", "Benz e200", "120") ,
          drive("james", "audi q1", "130"),
          drive("comrad", "VOLVO a9", "110")
        ],
      ),
    );
  }
  drive(String name ,String vh,String price){
    return  GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Under()));

      } ,child: Card(
      elevation: 30,

      child: Container(
        height: 100,
        child: Row(
          children: [
            SizedBox(width: 8,),
            Container(
              height: 90,
              width: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/driv.png")),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            SizedBox(width: 8,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Driver: ${name}", style: TextStyle(
                    fontSize: 20),),
                SizedBox(height: 8,),
                Text("Cab Name:${vh}"),
                SizedBox(height: 8,),
                Text("Price:\$ $price"),
              ],
            )


          ],
        ),
      ),
    ),
    );





  }



}
