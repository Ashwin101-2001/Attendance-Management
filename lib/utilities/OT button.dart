import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Firebase/attendanceDatabase.dart';

import 'functions.dart';

class OTButton extends StatefulWidget {
  Function([double x]) notifyParent;
  int a;
  SharedPreferences my;
  OTButton(this.notifyParent,this.my,[this.a]);
  @override
  OTButtonState createState() => OTButtonState(notifyParent,this.my,this.a);
}

class OTButtonState extends State<OTButton> {
  Function([double x])  notifyParent;
  SharedPreferences my;
  int a;
  DatabaseAttendanceService d = new DatabaseAttendanceService();
  OTButtonState(this.notifyParent,this.my,[this.a]);
  double OT;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    OT=my.getDouble("defaultOT")??3.0;
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
            getButtons(-0.25),
            getButtons(0.25)


          ],)
      ],



    ):Row(
      children: [
        getButtons(-0.25),
        Text("   $OT   ",style: TextStyle(color: Colors.black,decoration: TextDecoration.underline,decorationColor: Colors.green,fontSize: 25)),
        getButtons(0.25)
      ],
    );


  }

  Widget getButtons(double x) {
    return RawMaterialButton(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

      onPressed: () async{

        double i;
        i= OT!=null?OT + x:1;
        notifyParent(i);
        setState(() {
          OT = i;
        });
        if(a==1)
          my.setDouble("defaultOT", OT);
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
