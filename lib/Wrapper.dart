import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:varnam_attendance/Screens/viewEmployee.dart';
import 'package:varnam_attendance/utilities/Loading.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool loading=true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
   init();
    setState(() {
      loading = false;
    });
  }
  void init ()async
  { await Firebase.initializeApp();}


  @override
  Widget build(BuildContext context) {
    return !loading?viewEmployee():Loader();
  }
}
