import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/models/InputFotmatter.dart';

String getHints(int type) {
  switch (type) {
    case 1:
      return "Enter Name";
    case 2:
      return "Enter Phone Number";

    case 3:
      return "Enter Aadhar Number";

    case 4:
      return "Enter wage per day";
      break;
    case 5:
      return "Enter OverTime per hour";
    case 6:
      return "Enter employee allowance";
    case 7:
      return "Enter Advance given";
  }
}


String getLabel(int type) {
  switch (type) {
    case 1:
      return " Name";
    case 2:
      return " Phone Number";

    case 3:
      return "Aadhar Number";

    case 4:
      return "Wage";
      break;
    case 5:
      return "OverTime per hour";
    case 6:
      return " Employee allowance";
    case 7:
      return "Advance";

  }
}

String getPer(bool per) {
  return per == false ? "/day" : "/month";
}

List<TextInputFormatter> getFormatters(int type) {
  List<TextInputFormatter> y = List<TextInputFormatter>();
  switch (type) {
    case 2:
      //y.add(LengthLimitingTextInputFormatter(11));
      y.add(FilteringTextInputFormatter.digitsOnly);
      y.add(CustomInputFormatter(5));
      return y;

    case 3:
      //y.add(LengthLimitingTextInputFormatter(14));
      y.add(FilteringTextInputFormatter.digitsOnly);
      y.add(CustomInputFormatter(4));
      return y;

    case 4:
    case 5:
    case 6:
    case 7:
      y.add(FilteringTextInputFormatter.digitsOnly);
      y.add(CustomInputFormatter1());
      return y;
  }
}


String getValidation(int type,String val) {
  switch (type) {
    case 1:
      if (val != "") {
      } else
        return "Field is empty !!";

      break;
    case 2:
    /* if (val != "") {
        if (!(val.length == 11)) return "Enter a valid 10 digit phone number";
      } else
        return "Field is empty !!"; */
      break;

    case 3:
    /*   if (val != "") {
        if (!(val.length == 14)) return "Enter a valid 12 digit Aadhar number";
      } else
        return "Field is empty !!"*/

      break;
    case 4:
    case 5:
    case 7:
      if (val != "") {
      } else
        return "Field is empty !!";
      break;
  }

  return (val != "" ? null : "Enter a valid name");
}


String getBoolValue(bool x)
{return x==true?"2":"1";}


Color getTileColor(int attendance) {
  switch (attendance) {
    case 0:
     return  Colors.red;

    case 1:
      return Colors.orangeAccent;


    case 2:
      return Colors.green;

  }
}


String getaddedzero(int x,[int y])
{
  String s="";
  if(y==null)
  { if(x<10) {
    s = "0$x";
    return s;
  }
  else
    return "$x";}
  else if(y==3)
  {


    if(x<10) {
      s = "00$x";
      return s;
    }
    else if(x>=10&&x<100)
      return "0$x";
    else
      return "$x";
  }




}


String getAtt(int val) {
  switch (val) {
    case 0:
      return "  Absent  ";

    case 1:
      return "  Half-day  ";

    case 2:
      return "  Present  ";
  }
}



