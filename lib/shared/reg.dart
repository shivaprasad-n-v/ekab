import 'package:codemagic/main.dart';
import 'package:codemagic/maps.dart';
import 'package:codemagic/shared/colors.dart';
import 'package:codemagic/shared/styles.dart';
import 'package:flutter/material.dart';

import '../log.dart';
import 'inputFields.dart';


class SignUpPage extends StatefulWidget {
  final String pageTitle;

  SignUpPage({Key key, this.pageTitle}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: white,
          title: Text('Sign Up',
              style: TextStyle(
                  color: Colors.grey, fontFamily: 'Poppins', fontSize: 15)),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                // Navigator.of(context).pushReplacementNamed('/signin');
                Navigator.push(context, MaterialPageRoute(
                    builder: (Context)=>SignInPage()
                ));

              },
              child: Text('Sign In', style: contrastText),
            )
          ],
        ),
        body: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 18, right: 18),
              child: Stack(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Welcome to Taxit!', style: h3),
                      Text('Let\'s get started', style: taglineText),
                      fryoTextInput('Username'),
                      fryoTextInput('Full Name'),
                      fryoEmailInput('Email Address'),
                      fryoPasswordInput('Password')
                    ],
                  ),
                  Positioned(
                    bottom: 15,
                    right: -15,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (Context)=>MapView()
                        ));
                      },
                      color: primaryColor,
                      padding: EdgeInsets.all(13),
                      shape: CircleBorder(),
                      child: Icon(Icons.arrow_forward, color: white),
                    ),
                  )
                ],
              ),
              height: 360,

              width: double.infinity,
              decoration: authPlateDecoration,
            ),
          ],
        )
    );
  }
}