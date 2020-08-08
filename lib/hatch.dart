import 'package:codemagic/uder.dart';
import 'package:flutter/material.dart';
class hatch extends StatefulWidget {
  @override
  _hatchState createState() => _hatchState();
}

class _hatchState extends State<hatch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.green,),
      body: Column(
        children: [
      drive("johan", "TATA TIGO", "50"),
          drive("jathan", "Swift desert", "75"),
          drive("david", "kwid", "40"),
          drive("raj", "Logan", "55"),
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
