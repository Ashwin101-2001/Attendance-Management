import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:varnam_attendance/Constants/addEmployeeConstants.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Firebase/attendanceDatabase.dart';
import 'package:varnam_attendance/models/InputFotmatter.dart';

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
  TextEditingController t = new TextEditingController();
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
    t.text=OT.toString();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        getButtons(-0.25),
           Container( width:80,
               child: getText()),
         getButtons(0.25)
      ],
    );


  }

  Widget getText() {
    return TextFormField(
      textAlign: TextAlign.center,
      inputFormatters: [DecimalNumberFormatter()],
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      controller: t,
      onChanged: (val) {
        OT = double.parse(val);
        my.setDouble("defaultOT", OT);
        setState(() {
          notifyParent(OT);
        });
      },
      decoration: InputDecoration(

        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.pink, width: 2.0),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2.0),
        ),
      ),
    );
  }

  Widget getButtons(double x) {
    return Container(
      width: 30,
      height: 30,
      child: RawMaterialButton(
        //constraints: BoxConstraints(maxHeight: 40, maxWidth: 40,),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

        onPressed: () async{

          double i;
          i= OT!=null?OT + x:1;
          notifyParent(i);
          setState(() {
            OT = i;
            t.text=i.toString();
          });
          if(a==1)
            my.setDouble("defaultOT", OT);
        },
        elevation: 2.0,

        child: Icon(
          x>0?Icons.add:Icons.remove,
          size: iconSize,
        ),
        padding: EdgeInsets.all(5),

        shape: CircleBorder(side: BorderSide(
          color: Colors.pink,
          width: 2.0,
        )),
      ),
    );
  }
}
