import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:varnam_attendance/Constants/addEmployeeConstants.dart';
import 'package:varnam_attendance/Firebase/currentMonth.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
class markAttendance extends StatefulWidget {
  @override
  _markAttendanceState createState() => _markAttendanceState();
}

class _markAttendanceState extends State<markAttendance> {
  List<Employee> eList;
  bool loading;
  int defaultOT=2;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loading=true;
    init();
  }

  void init ()async
  {  await Firebase.initializeApp();
    eList=await DatabaseListService().getEmployeeList();

    setState(() {
      loading=false;
    });

  }
  @override
  Widget build(BuildContext context) {

    if(!loading) {
      for (Employee e in eList) {
        print("name : ${e.name}");
        print("phone : ${e.phone}");
        print("add : ${e.aadhar}");
      }
      return Container(color: Colors.black,
        child: ListView(
          children: [
            FlatButton(
              child: Text("pRESS",style:textStyle,),
              onPressed: ()async
              { await SyncAttendance();
              print("abc");

              },
            )


          ],
        ),



      );} else
      return Container(
        color: Colors.red,
      );
  }


  void SyncAttendance() async
  {
    DatabaseService d=new DatabaseService();
    int i=0;
    String date=DateTime.now().day.toString();
    Map<String,dynamic> map;
    for(Employee e in eList)
    {

      if(i==0)
      {    map={
        date:defaultOT,

      };

        await d.updateUserData("DefaultOT", map);

      }
      if(!doStore(e))
      {
        String s="${e.attendance}${e.overTime}";
       map={
         date:int.parse(s),

      };

        await d.updateUserData(e.name, map);  //L:was making a mistake here used update for 1st time set

      }

    i++;


    }




  }

  bool doStore(Employee e)
  { if(e.attendance==2&&e.overTime==defaultOT)
    return true;

   return false;
  }





}
