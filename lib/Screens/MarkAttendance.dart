import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:varnam_attendance/Constants/addEmployeeConstants.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Firebase/attendanceDatabase.dart';
import 'package:varnam_attendance/Screens/viewEmployee.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
import 'package:varnam_attendance/utilities/Loading.dart';
import 'package:varnam_attendance/utilities/OT%20button.dart';
import 'package:varnam_attendance/utilities/functions.dart';
import 'package:varnam_attendance/utilities/getAttendanceButton.dart';
import 'package:varnam_attendance/utilities/screens_size.dart';
import 'package:intl/intl.dart';

class markAttendance extends StatefulWidget {
  DateTime now;
  markAttendance([this.now]);
  @override
  _markAttendanceState createState() => _markAttendanceState(this.now);
}

class _markAttendanceState extends State<markAttendance> {

  final _formKey = GlobalKey<FormState>();

  _markAttendanceState([this.now]);
  TextEditingController sController = new TextEditingController();

  /// OT and Att
  double defaultOT;
  int defaultAttendance;
  double selectOT;
  int selectAttendance;
  double width;
  double height;

  String month;
  String date;
  bool loading;
  DateTime now;

  ///   DS
  Map<String, bool> checkedMap;
  Map<String, Map<String, dynamic>> map;
  List<String> searchList;

  SharedPreferences myPrefs;
  DatabaseAttendanceService d = new DatabaseAttendanceService();


  //=  List<String>();

  @override
  void initState() {
    print("mark init");
    // TODO: implement initState
    super.initState();
    if(now==null)
      now = DateTime.now();
    month = "${getaddedzero(now.month)}-${now.year}";
    date = now.day.toString();
    map = Map<String, Map<String, dynamic>>();
    checkedMap = Map<String, bool>();
    loading = true;
    init();
    setState(() {
      loading = false;
    });
  }

  void init() async {
    myPrefs = await SharedPreferences.getInstance();
    myPrefs.remove("defaultOT");
    myPrefs.remove("defaultAttendance");
    double s1 = myPrefs.getDouble("defaultOT");
    if (s1 == null) {
      s1 = 3.0;
      myPrefs.setDouble("defaultOT", 3.0);
    }

    int s2 = myPrefs.getInt("defaultAttendance");
    if (s2 == null) {
      s2 = 2;
      myPrefs.setInt("defaultAttendance", 2);
    }
    defaultOT = s1;
    defaultAttendance = s2;
    selectAttendance = s2;
    selectOT = s1;
  }

  Future<bool> _onWillPop() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => viewEmployee()),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = Responsive.width(100, context);
    height = Responsive.width(100, context);

    return loading == true
        ? Loader()
        : Scaffold(
            backgroundColor: BGColor1,
            appBar: AppBar(
              //leading: Container(),
              title: Center(child: Text('Mark attendance')),
            ),
            body: StreamBuilder(
              stream: DatabaseAttendanceService().stream,
              builder: (context, Item) {
                if (Item.hasData) {
                  map = Item.data;
                  bool x = false;
                  if (searchList == null) {
                    x = true;
                    searchList = List<String>();
                  }
                  for (String k in map.keys) {
                    print(k);
                    if (x == true) searchList.add(k);

                    print(map[k].toString());
                    print("");
                  }
                  return SingleChildScrollView(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, contraint) {
                          return Container(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Column(

                             children: [
                               Center(
                                 child: Container(
                                   margin: EdgeInsets.all(20.0),
                                   child: FlatButton(
                                     child:
                                     RichText(
                                       text: TextSpan(
                                         children: [
                                           TextSpan(
                                             text:   now != null ?  "  ${DateFormat.yMMMd().format(now)}  " : "  Enter Date of joining  ",
                                             style: dateStyle,
                                           ),
                                           WidgetSpan(
                                             child: Icon(Icons.arrow_drop_down,color: arrowColor,),
                                           ),

                                         ],
                                       ),
                                     ),

                                     onPressed: () {
                                       _selectDate(context);
                                     },
                                   ),
                                 ),
                               ),
                                Row(
                               children: [
                                 Expanded(
                                   flex: 3,
                                   child: Column(
                                     children: getList(),
                                   ),
                                 ),
                                 Expanded(
                                   flex: 1,
                                   child: getStatsWidget(),
                                 )
                               ],
                             ),],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                } else
                  return Loader();
              },
            ),
            bottomNavigationBar: BottomAppBar(
                child: getBottomAppBar()),
          );
  }


   /// Widget Functions
  List<Widget> getList() {
    List<Widget> a = List<Widget>();
    a.add(Container(
      decoration: BoxDecoration(
        border:
        Border.all(color: getTileColor(defaultAttendance ?? 2), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          attendanceButton(refresh1, myPrefs, 1),
          OTButton(ref1, myPrefs, 1),
        ],
      ),
    ));

    a.add(Container(
      padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0),
      decoration: BoxDecoration(
        border:
        Border.all(color: getTileColor(defaultAttendance ?? 2), width: 1.0),
      ),
      child: Form(
        key: _formKey,
        child: getSearchBar(),
      ),
    ));
    for (String k in searchList) {
      //print("k:$k l:${searchList.length}   contains:${searchList.contains(k)}");
      //if((searchList.length!=0&&searchList.contains(k)))
      //if(DateTime.now().day!=int.parse(date))
      a.add(CheckboxListTile(
        tileColor: getTileColor(int.parse(getAttendance(k))),
        //get attendance
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Text(k),
            ),
            Expanded(
              flex: 4,
              child: Text(getOT(k)),
            )
          ],
        ),
        secondary: Icon(Icons.person),
        controlAffinity: ListTileControlAffinity.trailing,
        value: checkedMap[k] ?? false,
        onChanged: (val) {
          setState(() {
            checkedMap[k] = val;
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
  Widget getSearchBar() {
    return TextFormField(
      controller: sController,
      style: textFormStyle,
      keyboardType: TextInputType.text,
      onChanged: (val) {
        setSearchList(val);
        setState(() {});
      },
      decoration: InputDecoration(
        suffixIcon: sController.text != ""
            ? IconButton(
          icon: Icon(
            Icons.cancel_outlined,
            color: Colors.green,
            size: 18.0,
          ),
          onPressed: () {
            setSearchList("");
            setState(() {
              sController.text = "";
            });
          },
        )
            : null,
        labelText: "Search ",
        labelStyle: labelStyle1,
        hintText: "Search for Employee",
        hintStyle: hintStyle1,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: focusedBorderColor1, width: focusedBorderWidth1),
        ),

        /* enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: enabledBorderColor, width: enabledBorderWidth1),
        ),*/
      ),
    );
  }

  Widget getBottomAppBar()
  {   return  Container(
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
                    "  Select all  ",
                    style: textStyle1,
                  ),
                  onPressed: () {
                    for (String k in map.keys) {
                      checkedMap[k] = true;
                    }
                    setState(() {});
                  },
                ),
                FlatButton(
                  child: Text(
                    "  MARK ATTENDANCE  ",
                    style: textStyle1,
                  ),
                  onPressed: () async {
                    getShowDialog();
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
      )); }

  Widget getStatsWidget() {
    return Container(
      width: width / 4,
      padding: EdgeInsets.only(
        left: 20.0,
      ),
      child: Column(
        children: [
          Container(
              width: width / 4,
              padding: EdgeInsets.only(
                  right: 20.0, left: 20.0, top: 5.0, bottom: 5.0),
              decoration: BoxDecoration(
                border: Border.all(
                    color: getTileColor(
                        defaultAttendance != null ? defaultAttendance : 2),
                    width: width2),
              ),
              child: Text("Present :  ${getStats()[2]}")),
          Container(
              width: width / 4,
              padding: EdgeInsets.only(
                  right: 10.0, left: 10.0, top: 5.0, bottom: 5.0),
              decoration: BoxDecoration(
                border: Border.all(
                    color: getTileColor(
                        defaultAttendance != null ? defaultAttendance : 2),
                    width: width2),
              ),
              child: Text("Absent :  ${getStats()[0]}")),
          Container(
              width: width / 4,
              padding: EdgeInsets.only(
                  right: 20.0, left: 20.0, top: 5.0, bottom: 5.0),
              decoration: BoxDecoration(
                border: Border.all(
                    color: getTileColor(defaultAttendance ?? 2), width: width2),
              ),
              child: Text("Halfday :  ${getStats()[1]}")),
        ],
      ),
    );
  }

  void getShowDialog() {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'Mark attendance?',
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            // content: Text('Do you want to exit App ?',style: TextStyle(color: Colors.white70),),

            content: Container(
              height: 200.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // getAttendanceDDButton(),
                  attendanceButton(refresh, myPrefs),
                  OTButton(ref, myPrefs),

                  FlatButton(
                    onPressed: () async {
                      for (String k in map.keys) {
                        if (checkedMap[k] == true) {
                          Map<String, dynamic>a;

                          if (map[k].containsKey(month)) {
                            a = map[k][month];
                            a[date] = "${selectAttendance}${selectOT}";
                          }
                          else
                          { a={
                            date:"${selectAttendance}${selectOT}"};
                          }
                          Map<String,dynamic> a1={month:a};

                          await d.updateStaffData(k, a1);
                          checkedMap[k] = false;
                        } else {
                          Map<String, dynamic> m;
                          switch (getType(k)) {
                            case 1:
                              break;
                            case 0:
                              m = map[k][month];
                              m[date] = "${defaultAttendance}${defaultOT}";
                              break;
                            case -1:
                              m={
                                date:"${defaultAttendance}${defaultOT}"
                              };
                              break;
                          }





                          if(DateTime.now().day==int.parse(date))   //today
                            { if(getType(k)!=1)
                              await d.updateStaffData(k, m);}

                        }

                        setState(() {});
                      }

                      Navigator.pop(context);
                    },
                    child: Text(
                      'Mark ',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }










   ///  Utility Functions

  Future<Null> _selectDate(BuildContext context) async {
    print('selectDate');

    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: now,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null) {
        setState(() {
          now=picked;
          month = "${getaddedzero(picked.month)}-${picked.year}";
          date = picked.day.toString();
        });
    }
  }

  void saveFirst(String k, Map<String, dynamic> m) async {
    if (map[k].containsKey(month)) {
      if (!map[k][month].containsKey(date)) {
        await d.updateStaffData(k, m);
      }
    } else {
      await d.updateStaffData(k, m);
    }
  }






  void setSearchList(String val) {
    searchList = List<String>();
    for (String k in map.keys) {
      if (val != "") {
        if (k.toLowerCase().startsWith(val.toLowerCase())) searchList.add(k);
      } else
        searchList.add(k);
    }
  }


  String getAttendance(String k) {
    switch(getType(k))
    {case 1:
      return map[k][month][date].substring(0, 1);
      case 0:
        return DateTime.now().day==int.parse(date)?defaultAttendance.toString():"5";
      case -1:
        return DateTime.now().day==int.parse(date)?defaultAttendance.toString():"5";
    }
    /* if (map[k].containsKey(month)) {
      if (map[k][month].containsKey(date))
        return map[k][month][date].substring(0, 1);
      else {
        return DateTime.now().day==int.parse(date)?defaultAttendance.toString():"5";
      }
    } else {
      return  DateTime.now().day==int.parse(date)?defaultAttendance.toString():"5";
      //return default;

    } */

  }

  int getType(String k) {
    if (map[k].containsKey(month)) {
      if (map[k][month].containsKey(date))
        return 1;
      else {
        return 0;
      }
    } else {
      return  -1;
      //return default;

    }
  }


  String getOT(String k) {
    switch(getType(k))
    {case 1:
      return map[k][month][date].substring(1);
      case 0:
        return DateTime.now().day==int.parse(date)?defaultOT.toString():"NA";
      case -1:
        return DateTime.now().day==int.parse(date)?defaultOT.toString():"NA";


    }
    /*  if (map[k].containsKey(month)) {
      if (map[k][month].containsKey(date))
        return map[k][month][date].substring(1);
      else {
        return DateTime.now().day==int.parse(date)?defaultOT.toString():"NA";
      }
    } else {
      return DateTime.now().day==int.parse(date)?defaultOT.toString():"NA";
    }*/

  }
  List<int> getStats() {
    List<int> x = [0, 0, 0];
    for (String k in map.keys) {
      if(int.parse(getAttendance(k))!=5)
      x[int.parse(getAttendance(k))]++;
    }

    return x;
  }



    /// Refresh Functions
  refresh([int x]) {
    setState(() {
      selectAttendance = x;
    });
  }

  ref([double x]) {
    setState(() {
      selectOT = x;
    });
  }

  refresh1([int x]) {
    setState(() {
      defaultAttendance = x;
    });
  }

  ref1([double x]) {
    setState(() {
      defaultOT = x;
    });
  }
}

/*

             */
