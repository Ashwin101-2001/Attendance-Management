

import 'package:flutter/material.dart';

import 'functions.dart';

class attendanceButton extends StatefulWidget {
  Function([int x]) notifyParent;
  int a;
  attendanceButton(this.notifyParent,[this.a]);
  @override
  attendanceButtonState createState() => attendanceButtonState(notifyParent);
}

class attendanceButtonState extends State<attendanceButton> {
  Function([int x])  notifyParent;
  int a;
  attendanceButtonState(this.notifyParent,[this.a]);
  int selectAttendance=2;
  @override

  @override
  Widget build(BuildContext context) {
    return   DropdownButton<int>(
      value: selectAttendance,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style:  TextStyle(color: getTileColor(selectAttendance)),
      underline: Container(
        height: 2,
        color:getTileColor(selectAttendance) ,
      ),
      onChanged: (int newValue) {
        setState(() {
          selectAttendance = newValue;
        });
        notifyParent(newValue);
      },
      items: <int>[0,1,2]
          .map<DropdownMenuItem<int>>((int  value) {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(getAtt(value),style:TextStyle(color: getTileColor(value))),

        );

      }).toList(),
    );

  }
}
