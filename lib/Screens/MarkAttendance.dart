import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:varnam_attendance/Constants/addEmployeeConstants.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Firebase/currentMonth.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
import 'package:varnam_attendance/utilities/OT%20button.dart';
import 'package:varnam_attendance/utilities/functions.dart';
import 'package:varnam_attendance/utilities/getAttendanceButton.dart';
import 'package:varnam_attendance/utilities/screens_size.dart';

class markAttendance extends StatefulWidget {
  @override
  _markAttendanceState createState() => _markAttendanceState();
}

class _markAttendanceState extends State<markAttendance> {
  List<Employee> eList;
  List<Employee> eList1;
  TextEditingController sController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();



  bool loading;
  int defaultOT ;
  int defaultAttendance;
  bool checkbox = false;
  double width;
  double height;
  int selectAttendance;
  int selectOT;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      defaultOT = 2;
      defaultAttendance=2;
      selectAttendance=2;
      selectOT=defaultOT;
    loading = true;
    init();
  }

  void init() async {
    await Firebase.initializeApp();
    eList = await DatabaseListService().getEmployeeList();
    eList1=eList;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = Responsive.width(100, context);
    height = Responsive.width(100, context);
    if (!loading) {
      /*  for (Employee e in eList) {
        print("name : ${e.name}");
        print("phone : ${e.phone}");
        print("add : ${e.aadhar}");
      }*/
      return Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Mark attendance')),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: LayoutBuilder(
              builder: (context, contraint) {
                return Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: getList(),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: width/4,
                          padding: EdgeInsets.only(
                              left: 20.0,
                          ),
                          child: Column
                          (
                          children: [
                              Container(
                              width: width/4,
                              padding: EdgeInsets.only(
                                  right: 20.0,
                                  left: 20.0,
                                  top: 5.0,
                                  bottom: 5.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: getTileColor(defaultAttendance),
                                    width: width2),
                              ),
                              child: Text("Present :  ${getStats()[2]}")),

                          Container(
                            width: width/4,
                            padding: EdgeInsets.only(
                                right: 10.0,
                                left: 10.0,
                                top: 5.0,
                                bottom: 5.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: getTileColor(defaultAttendance),
                                  width: width2),
                            ),
                            child: Text("Absent :  ${getStats()[0]}")),
                          Container(
                            width: width/4,
                            padding: EdgeInsets.only(
                                right: 20.0,
                                left: 20.0,
                                top: 5.0,
                                bottom: 5.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: getTileColor(defaultAttendance),
                                  width:width2),
                            ),
                            child: Text("Halfday :  ${getStats()[1]}")),
                          ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            child: Container(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FlatButton(
                            child: Text(
                              "  MARK ATTENDANCE  ",
                              style: textStyle1,
                            ),
                            onPressed: () async {
                              getShowDialog();
                            },
                          ),
                          SizedBox(width: 50),
                          FlatButton(
                            child: Text(
                              "  STORE ATTENDANCE  ",
                              style: textStyle1,
                            ),
                            onPressed: () async {
                              await SyncAttendance();
                              print("abc");
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                          child: Text(""),
                        ))
                  ],
                ))),
      );
    } else
      return Container(
        color: Colors.red,
      );
  }

  List<Widget> getList() {
    List<Widget> a = List<Widget>();

    a.add(Container(
      decoration: BoxDecoration(
          border: Border.all(color:getTileColor(defaultAttendance),width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          attendanceButton(refresh1,1),
          OTButton(ref1,1),
        ],
      ),
    ));

    a.add(
      Container(

        padding: EdgeInsets.only(right: 20.0, left: 20.0,top: 5.0,bottom: 5.0),
        decoration: BoxDecoration(
          border: Border.all(color:getTileColor(defaultAttendance),width: 1.0),
        ),
        child: Form(
          key: _formKey,
          child: getSearch(),
        ),
      )
    );
    for (Employee e in eList1) {
      a.add(GestureDetector(
        onTap: ()
        { print('b');


        },
        child: CheckboxListTile(
          tileColor: getTileColor(e.attendance),
          title: Text(e.name),
          secondary: Icon(Icons.person),

          controlAffinity: ListTileControlAffinity.trailing,
          value: e.checked,
          onChanged: (val) {
            setState(() {
              e.checked = val;

            });
          },
          activeColor: Colors.red,
        ),
      ));
      a.add(SizedBox(
        height: 10.0,
      ));
    }

    return a;
  }





  void SyncAttendance() async {
    DatabaseService d = new DatabaseService();
    int i = 0;
    String date = DateTime.now().day.toString();
    Map<String, dynamic> map;
    for (Employee e in eList) {
      if (i == 0) {
        map = {
          date: defaultOT,
        };

        await d.updateUserData("DefaultOT", map);
      }
      if (!doStore(e)) {
        String s = "${e.attendance}${e.overTimeHours}";
        map = {
          date: s,
        };

        await d.updateUserData(e.name,
            map); //L:was making a mistake here used update for 1st time set

      }

      i++;
    }
  }




  void getShowDialog()
  {

    showDialog(
      context: context,
      builder: (context) => Center(
        child: AlertDialog(
          backgroundColor: Colors.black,
          title: Text('Mark attendance?',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
         // content: Text('Do you want to exit App ?',style: TextStyle(color: Colors.white70),),

           content: Container(
             height: 200.0,
             child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // getAttendanceDDButton(),
                  attendanceButton(refresh),
                  OTButton(ref),
                  

                  FlatButton(
                    onPressed: () {
                      for (Employee e in eList) {
                        if (e.checked == true) {
                          e.attendance = selectAttendance;
                          e.overTimeHours = selectOT;
                          e.checked=false;
                        }
                        setState(() {

                        });
                      }
                      Navigator.pop(context);
                    },
                    child: Text('Mark ',style: TextStyle(color: Colors.green),),
                  ),
                ],
              ),
           )



        ),
      ),
    );
  }

  Widget getAttendanceDDButton()
  {
    return DropdownButton<int>(
      value: selectAttendance,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style:  TextStyle(color: getTileColor(selectAttendance)),
      underline: Container(
        height: 2,
        color:getTileColor(selectAttendance) ,
      ),
      onChanged: (int newValue) {
        print("set");
        setState(() {
          print('a');
          selectAttendance = newValue;
        });
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


  bool doStore(Employee e) {
    if (e.attendance == 2 && e.overTime == defaultOT) return true;

    return false;
  }

  refresh([int x]) {

    setState(() {
      selectAttendance=x;
    });
  }
  ref([int x]) {

    setState(() {
      selectOT=x;
    });
  }

  refresh1([int x]) {
    for (Employee e in eList) {
      e.attendance = x;
    }
    setState(() {
      defaultAttendance = x;
    });
  }

  ref1([int x]) {
    for (Employee e in eList) {
      e.overTimeHours = x;
    }
    setState(() {
      defaultOT = x;
    });
  }


  Widget getSearch()
  {
    return TextFormField(
      controller: sController,
      style: textFormStyle,
      keyboardType: TextInputType.text,

      onChanged: (val)
      {
        if (val != "") {
          eList1 = List<Employee>();
          for (Employee e in eList) {
            if (e.name.toLowerCase().startsWith(val.toLowerCase())) eList1.add(e);
          }
        } else
          eList1 = eList;

        setState(() {});
      },
      decoration: InputDecoration(
        suffixIcon:  sController.text!=""?IconButton(
          icon: Icon(Icons.cancel_outlined,color: Colors.green,size: 18.0,),
          onPressed: () {
            eList1 = eList;
            setState(() {
              sController.text = " ";
            });
          },
        ):null,
        labelText: "Search ",
        labelStyle: labelStyle1,
        hintText: "Search for Employee",
        hintStyle: hintStyle1,
        focusedBorder:OutlineInputBorder(
          borderSide: BorderSide(color: focusedBorderColor1, width: focusedBorderWidth1),
        ),

        /* enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: enabledBorderColor, width: enabledBorderWidth1),
        ),*/
      ),
    );
  }

  List<int> getStats() {
    List<int> x = [0, 0, 0];
    for (Employee e in eList) {
      x[e.attendance] += 1;
    }

    return x;
  }
}
