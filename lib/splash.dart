import 'package:flutter/material.dart';
import 'package:codemagic/log.dart';

class ScreenShare extends StatefulWidget {
  @override
  _ScreenShareState createState() => _ScreenShareState();
}

class _ScreenShareState extends State<ScreenShare> {

  void initState(){
    super.initState();
    Future.delayed(
        Duration(
            seconds:  2
        ),
            (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> SignInPage()));
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return
       Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          color: Colors.green,

        ),
      );

  }
}