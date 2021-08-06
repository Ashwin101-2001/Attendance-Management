

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:varnam_attendance/Firebase/attendanceDatabase.dart';
import 'package:varnam_attendance/utilities/Loading.dart';

import 'functions.dart';

class attendanceButton extends StatefulWidget {
  Function([int x]) notifyParent;
  attendanceButton(this.notifyParent,this.my,[this.a]);
  int a;
  SharedPreferences my;
  @override
  attendanceButtonState createState() => attendanceButtonState(notifyParent,this.my,this.a);
}

class attendanceButtonState extends State<attendanceButton> {
  Function([int x])  notifyParent;
  int a;
  DatabaseAttendanceService d = new DatabaseAttendanceService();
  SharedPreferences my;
  attendanceButtonState(this.notifyParent,this.my,[this.a]);
  int selectAttendance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectAttendance=my.getInt("defaultAttendance")??2;

  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: selectAttendance,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style:  TextStyle(color: getTileColor(selectAttendance)),
      underline: Container(
        height: 2,
        color:getTileColor(selectAttendance) ,
      ),
      onChanged: (int newValue) async  {


        setState(() {
          selectAttendance = newValue;
        });
        notifyParent(newValue);
        if(a==1)
          my.setInt("defaultAttendance", selectAttendance);
      },
      items: <int>[2,1,0]
          .map<DropdownMenuItem<int>>((int  value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(getAtt(value),style:TextStyle(color: getTileColor(value))),

        );

      }).toList(),
    );

  }
}
