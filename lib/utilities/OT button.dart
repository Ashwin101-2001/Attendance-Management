import 'package:flutter/material.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';

import 'functions.dart';

class OTButton extends StatefulWidget {
  Function([int x]) notifyParent;
  int a;
  OTButton(this.notifyParent,[this.a]);
  @override
  OTButtonState createState() => OTButtonState(notifyParent,this.a);
}

class OTButtonState extends State<OTButton> {
  Function([int x])  notifyParent;
  int a;
  OTButtonState(this.notifyParent,[this.a]);
  int OT=2;
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
      onPressed: () {
        int a;
        a= OT!=null?OT + x:1;
        notifyParent(a);
        setState(() {
          OT = a;
        });
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
