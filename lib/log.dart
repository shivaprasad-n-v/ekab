import 'package:codemagic/main.dart';
import 'package:codemagic/maps.dart';
import 'package:codemagic/shared/reg.dart';
import 'package:flutter/material.dart';

import 'package:codemagic/shared/colors.dart';
import 'package:codemagic/shared/inputFields.dart';
import 'package:codemagic/shared/styles.dart';


class SignInPage extends StatefulWidget {
  final String pageTitle;

  SignInPage({Key key, this.pageTitle}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: white,
          title: Text('Sign In',
              style: TextStyle(
                  color: Colors.grey, fontFamily: 'Poppins', fontSize: 15)),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                // Navigator.of(context).pushReplacementNamed('/signup');

                Navigator.push(context, MaterialPageRoute(
                    builder: (Context)=>SignUpPage()
                ));
              },
              child: Text('Sign Up', style: contrastText),
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
                      Text('Welcome Back!', style: h3),
                      Text('Howdy, let\'s authenticate', style: taglineText),
                      fryoTextInput('Username'),
                      fryoPasswordInput('Password'),
                      FlatButton(
                        onPressed: () {},
                        child: Text('Forgot Password?', style: contrastTextBold),
                      )
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
              height: 245,

              width: double.infinity,
              decoration: authPlateDecoration,
            ),
          ],
        )
    );
  }
}