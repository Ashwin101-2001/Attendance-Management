import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:varnam_attendance/Constants/addEmployeeConstants.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Firebase/currentMonth.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
import 'package:varnam_attendance/utilities/screens_size.dart';

class markAttendance extends StatefulWidget {
  @override
  _markAttendanceState createState() => _markAttendanceState();
}

class _markAttendanceState extends State<markAttendance> {
  List<Employee> eList;
  bool loading;
  int defaultOT = 2;
  bool checkbox = false;
  double width;
  double height;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loading = true;
    init();
  }

  void init() async {
    await Firebase.initializeApp();
    eList = await DatabaseListService().getEmployeeList();

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
                          child: Center(child: Text("ABC")),
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
                              "MARK ATTENDANCE",
                              style: textStyle,
                            ),
                            onPressed: () async {
                              await SyncAttendance();
                              print("abc");
                            },
                          ),
                          SizedBox(width: 50),
                          FlatButton(
                            child: Text(
                              "STORE ATTENDANCE",
                              style: textStyle,
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
    for (Employee e in eList) {
      a.add(CheckboxListTile(
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
      ));
      a.add(SizedBox(
        height: 10.0,
      ));
    }

    return a;
  }

  Color getTileColor(int attendance) {
    switch (attendance) {
      case 0:
        Colors.red;
        break;
      case 1:
        return Colors.yellow;
        break;

      case 2:
        return Colors.green;
        break;
    }
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
        String s = "${e.attendance}${e.overTime}";
        map = {
          date: int.parse(s),
        };

        await d.updateUserData(e.name,
            map); //L:was making a mistake here used update for 1st time set

      }

      i++;
    }
  }

  bool doStore(Employee e) {
    if (e.attendance == 2 && e.overTime == defaultOT) return true;

    return false;
  }
}
