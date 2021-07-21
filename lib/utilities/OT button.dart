import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Firebase/currentMonth.dart';

import 'functions.dart';

class OTButton extends StatefulWidget {
  Function([int x]) notifyParent;
  int a;
  SharedPreferences my;
  OTButton(this.notifyParent,this.my,[this.a]);
  @override
  OTButtonState createState() => OTButtonState(notifyParent,this.my,this.a);
}

class OTButtonState extends State<OTButton> {
  Function([int x])  notifyParent;
  SharedPreferences my;
  int a;
  DatabaseAttendanceService d = new DatabaseAttendanceService();
  OTButtonState(this.notifyParent,this.my,[this.a]);
  int OT;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    OT=my.getInt("defaultOT")??3;
  }
  @override
  Widget build(BuildContext context) {
    return  a!=1? Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("   $OT   ",style: TextStyle(color: Colors.white,decoration: TextDecoration.underline,decorationColor: Colors.green)),
        Row(
          mainAxisAlignment:MainAxisAlignment.center,
          children: [
            getButtons(-1),
            getButtons(1)


          ],)
      ],



    ):Row(
      children: [
        getButtons(-1),
        Text("   $OT   ",style: TextStyle(color: Colors.black,decoration: TextDecoration.underline,decorationColor: Colors.green,fontSize: 25)),
        getButtons(1)
      ],
    );


  }

  Widget getButtons(int x) {
    return RawMaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

      onPressed: () async{

        int i;
        i= OT!=null?OT + x:1;
        notifyParent(i);
        setState(() {
          OT = i;
        });
        if(a==1)
          my.setInt("defaultOT", OT);
      },
      elevation: 2.0,
      fillColor: Colors.white,
      child: Icon(
        x==1?Icons.add:Icons.remove,
        size: iconSize,
      ),

      shape: CircleBorder(side: BorderSide(
        color: Colors.orange
      )),
    );
  }
}
