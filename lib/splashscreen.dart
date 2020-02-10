import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    Future.delayed(Duration(seconds: 2)).then((_){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(title: 'Infodengue')));
    });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        color: Colors.white,
        child: Center(
          child: Container(
            width: 723,
            height: 802,
            child: Image.asset("assets/splash.png"),
          ),
        )
    );
  }
}
