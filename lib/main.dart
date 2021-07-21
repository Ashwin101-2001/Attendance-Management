import 'package:flutter/material.dart';
import 'package:varnam_attendance/Screens/AddEmployee.dart';
import 'package:varnam_attendance/Screens/MarkAttendance.dart';
import 'package:varnam_attendance/Screens/viewEmployee.dart';
import 'package:varnam_attendance/Wrapper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      //home: addEmployee(),
      // home:markAttendance(),
      home:Wrapper(),
    );
  }
}


