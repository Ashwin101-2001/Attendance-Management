import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:varnam_attendance/Constants/Overall%20constants.dart';
import 'package:varnam_attendance/Constants/viewConstants.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/models/InputFotmatter.dart';



/// Strings
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
      return "Enter Overtime per hour";
    case 6:
      return "Enter employee allowance";
    case 7:
      return "Enter Advance given";
  }
}

String getLabel(int type) {
  switch (type) {
    case 1:
      return " Name *";
    case 2:
      return " Phone Number *";

    case 3:
      return "Aadhar Number";

    case 4:
      return "Wage *";
      break;
    case 5:
      return "Overtime per hour *";
    case 6:
      return " Employee allowance ";
    case 7:
      return "Advance *";
  }
}

String getLabel1(i)
{  if(i==1)
  return "Working days";
  if(i==2)
  return "OverTime Hours";
  if(i==3)
    return "Advance";

}

String getPer(bool per) {
  return per == false ? "/day" : "/month";
}

String getValidation(int type, String val) {
  switch (type) {
    case 1:
      if (val != "") {
      } else
        return "Field is empty !!";
      break;
    case 2:
      //  if (val != "") {
      //   if (!(val.length == 11)) return "Enter a valid 10 digit phone number";
      // } else
      //   return "Field is empty !!";
     break;

    case 3:
         if (val != "") {
        if (!(val.length == 14)) return "Enter a valid 12 digit Aadhar number";
      } else
        return null;

      break;
    case 4:
    case 5:
    case 7:
      if (val != "") {
      } else
        return "Field is empty !!";
      break;
  }

  return null;
}

String getBoolValue(bool x) {
  return x == true ? "2" : "1";
}

String getaddedzero(int x, [int y]) {
  String s = "";
  if (y == null) {
    if (x < 10) {
      s = "0$x";
      return s;
    } else
      return "$x";
  } else if (y == 3) {
    if (x < 10) {
      s = "00$x";
      return s;
    } else if (x >= 10 && x < 100)
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


String getit(type) {
  switch (type) {
    case 0:
      return "No filters";

    case 1:
      return "Attendance";

    case 2:
      return "OverTime";
    case 3:
      return "Gender";
  }
}

String getName(name) {
  List<String> s = name.split(" ");

  int i = 0;
  name = "";
  while (i < s.length) {
    if (s[i] != "") {
      name += s[i][0].toUpperCase() + s[i].substring(1).toLowerCase() + " ";
    }
    i++;
  }
  return name;
}


/// Double ints
double getAttendance(String name,attendanceMap,month) {
  double res=0.0;
  try {
    res=double.parse(attendanceMap[name][month][attKey]);
  }
  catch(e)
  {}
  return res;

}   /// CI

double getOT(name, attendanceMap,month) {

  double res=0.0;
  try {
    res=double.parse(attendanceMap[name][month][OTKey]);
  }
  catch(e)
  {}
  return res;



}

double getWages(hours, wage) {
  int s = int.parse(wage.substring(0, 1));
  var w = double.parse(wage.substring(1));
  return s == 1 ? hours * w : w;
}

double getAllowance(allowance,days,[paidLeaves]) {
  if(paidLeaves==null)
    paidLeaves=0;
  int s = int.parse(allowance.substring(0, 1));
  double all=double.parse(allowance.substring(1));
  return s == 1 ? all * (days.floor()-paidLeaves) : all;   ///CI
}

double getPf(wages,bool) {
  if(!bool)
    return 0;

  double num1 = double.parse(( wages * 0.096).toStringAsFixed(2));
  if(num1>1800)
    num1=1800;
  return num1;
}

double getEsi(wages,PF,bool) {
  if(!bool||(PF>1800))
    return 0;

  double num1 = double.parse(( wages * 0.0075).toStringAsFixed(2));
  return num1;
}

int getInt(list,name)
{  int i=0;
while(i<list.length)
{  if(list[i].name==name)
  return i;
i++;
}


}

int roundToTens(int n) {
  int a = ((n / 10).floor() * 10);
  int b = a + 10;
  return (n - a > b - n) ? b : a;
}


  /// List
List<TextInputFormatter> getFormatters(int type) {
  List<TextInputFormatter> y = List<TextInputFormatter>();
  switch (type) {
    case 2:
      y.add(LengthLimitingTextInputFormatter(11));
      y.add(FilteringTextInputFormatter.digitsOnly);
      y.add(SpaceFormatter(5));
      return y;

    case 3:
      y.add(LengthLimitingTextInputFormatter(14));
      y.add(FilteringTextInputFormatter.digitsOnly);
      y.add(SpaceFormatter(4));
      return y;

    case 4:
    case 5:
    case 6:

    case 7:
      y.add(DecimalNumberFormatter());
      y.add(RsFormatter());
      return y;
  }
}


  /// Misc

Color getTileColor(int attendance) {
  switch (attendance) {
    case 0:
      return Red;

    case 1:
      return Orange;

    case 2:
      return Green;

    default:
      return Colors.white;
  }
}

Employee getEmp(String name, List<Employee> l) {
  for (Employee e in l) {
    if (e.name == name) return e;
  }
}

bool isWeb()
{ if((kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android))==true)
  { return false;}

  return true;



}


/// Widgets

Widget getMenuItems(context,fn,title,icon,[i])
  {return  GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder:(context)=>fn ),
      );
    },
    child: i!=1?ListTile(
      title: Text(title,style:menuTextStyle),
      leading: Icon(icon,color: menuIconColor,size: menuIconSize,),
    ):Column(children: [
      Icon(icon,color: menuIconColor,size: menuIconSize,),
      Text(title,style:menuTextStyle)
    ],),
  );}











  /// getAtt
// double count = 0.0;
// //print("map: ${attendanceMap[name][month].toString()}");
// Map<String,dynamic> map1=Map.from(attendanceMap[name][month]);
// ///  map1.remove("ADVANCE");
// double sh=0.0;
// if( map1.containsKey("ADVANCE"))
// { try{ sh=double.parse(attendanceMap[name][month]["ADVANCE"].substring(0,1));}
// catch(e)
// {}}
//
//
// if(map1==null)
// return count;
// else if(map1.values==null)
// return count;
// else
// {  for (var s in map1.values) {
// try{   count += int.parse(s.substring(0, 1));}///-1-1 no problem
// catch(a)
// { ///print("a");
// }
//
//
// }
//
// return (count -sh)/ 2; }
// //0,1,2

 /// getOt

//
// double count = 0.0;
//
// Map<String,dynamic> map1=attendanceMap[name][month];
// double sh=0.0;
// if( map1.containsKey("ADVANCE"))
// { try{ sh=double.parse(map1["ADVANCE"].substring(1));}
// catch(e)
// {}}
//
//
// if(map1==null)
// return count;
// else if(map1.values==null)
// return count;
// else
// { for (var s in map1.values) {
// try{  count += double.parse(s.substring(1));}
// catch(a)
// { /// print("a");
// }
//
// }
//
// return count-sh;}