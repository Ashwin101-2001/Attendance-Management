import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:varnam_attendance/Constants/addEmployeeConstants.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Firebase/currentMonth.dart';
import 'package:varnam_attendance/Screens/viewEmployee.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
import 'package:varnam_attendance/utilities/Loading.dart';
import 'package:varnam_attendance/utilities/OT%20button.dart';
import 'package:varnam_attendance/utilities/functions.dart';
import 'package:varnam_attendance/utilities/getAttendanceButton.dart';
import 'package:varnam_attendance/utilities/screens_size.dart';

class markAttendance extends StatefulWidget {
  @override
  _markAttendanceState createState() => _markAttendanceState();
}

class _markAttendanceState extends State<markAttendance> {
  Map<String,Map<String,dynamic>> map;
  TextEditingController sController = new TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int defaultOT;
  int defaultAttendance;
  bool checkbox = false;
  double width;
  double height;
  int selectAttendance;
  String month;
  String date;
  int selectOT;
  Map<String,bool> checkedMap;
  SharedPreferences myPrefs;
  //int date;
  DatabaseAttendanceService d = new DatabaseAttendanceService();
  bool loading;
  List<String> searchList=  List<String>();

  @override
  void initState() {
    print("mark init");
    // TODO: implement initState
    super.initState();
    DateTime now=DateTime.now();
    month="${getaddedzero(now.month)}-${now.year}";
    date=now.day.toString();
    map = Map<String,Map<String,dynamic>>();
    checkedMap= Map<String,bool>();
    loading = true;
    init();
    setState(() {
      loading = false;
    });

  }

  void init() async {
      myPrefs = await SharedPreferences.getInstance();
    int s1 = myPrefs.getInt("defaultOT");
    if (s1 == null) {
      s1 = 3;
      myPrefs.setInt("defaultOT", 3);
    }

    int s2 = myPrefs.getInt("defaultAttendance");
    if (s2 == null) {
      s2 = 1;
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

    return loading==true?Loader():Scaffold(
      backgroundColor: Colors.teal[100],
      appBar: AppBar(
        //leading: Container(),
        title: Center(child: Text('Mark attendance')),
      ),
      body: StreamBuilder(
        stream: DatabaseAttendanceService().stream,
        builder: (context, Item) {
          if (Item.hasData) {
              map = Item.data;
              bool x= false;
              if(searchList.isEmpty)
                x=true;
            for(  String k in  map.keys)
              {  print(k);
               if(x==true)searchList.add(k);
                print(map[k].toString());
                print("");}
           return  SingleChildScrollView(
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
                             width: width / 4,
                             padding: EdgeInsets.only(
                               left: 20.0,
                             ),
                             child: Column
                               (
                               children: [
                                 Container(
                                     width: width / 4,
                                     padding: EdgeInsets.only(
                                         right: 20.0,
                                         left: 20.0,
                                         top: 5.0,
                                         bottom: 5.0),
                                     decoration: BoxDecoration(
                                       border: Border.all(
                                           color: getTileColor(
                                               defaultAttendance!=null?defaultAttendance:2),
                                           width: width2),
                                     ),
                                     child: Text(
                                         "Present :  ${getStats()[2]}")),

                                 Container(
                                     width: width / 4,
                                     padding: EdgeInsets.only(
                                         right: 10.0,
                                         left: 10.0,
                                         top: 5.0,
                                         bottom: 5.0),
                                     decoration: BoxDecoration(
                                       border: Border.all(
                                           color: getTileColor(
                                               defaultAttendance!=null?defaultAttendance:2),
                                           width: width2),
                                     ),
                                     child: Text(
                                         "Absent :  ${getStats()[0]}")),
                                 Container(
                                     width: width / 4,
                                     padding: EdgeInsets.only(
                                         right: 20.0,
                                         left: 20.0,
                                         top: 5.0,
                                         bottom: 5.0),
                                     decoration: BoxDecoration(
                                       border: Border.all(
                                           color: getTileColor(
                                               defaultAttendance??2),
                                           width: width2),
                                     ),
                                     child: Text(
                                         "Halfday :  ${getStats()[1]}")),
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
           );
          }
          else
            return Loader();
        },

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
                            "  Select all  ",
                            style: textStyle1,
                          ),
                          onPressed: ()  {
                            for(String k in map.keys)
                            {checkedMap[k]=true;}
                            setState(() {

                            });
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
              ))),
    );
  }


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
          attendanceButton(refresh1,myPrefs,1),
          OTButton(ref1,myPrefs,1),
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
        child: getSearch(),
      ),
    ));
    for (String k in map.keys) {
          print("k:$k l:${searchList.length}   contains:${searchList.contains(k)}");
      if((searchList.length!=0&&searchList.contains(k)))
        {      a.add(   CheckboxListTile(
          tileColor: getTileColor(int.parse(getAttendance(k))),  //get attendance
          title:Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Expanded(
              flex: 6,
              child:  Text(k),
            ),
              Expanded(
                flex: 4,
                child:  Text(getOT(k)),
              )],
          ),
          secondary: Icon(Icons.person),
          controlAffinity: ListTileControlAffinity.trailing,
          value: checkedMap[k]??false,
          onChanged: (val) {
            setState(() {
              checkedMap[k] = val;
            });
          },
          activeColor: Colors.red,
        ));
        a.add(SizedBox(
          height: 10.0,
        ));}

    }

    return a;
  }





  /* void SyncAttendance() async {
    DatabaseAttendanceService d = new DatabaseAttendanceService();
    int i = 0;
    String date = DateTime.now().day.toString();
    Map<String, dynamic> map;
    for (String k in  map.keys) {
      if (i == 0) {
        map = {
          date: defaultOT,
        };
        await d.updateStaffData("DefaultOT", map);
        map = {
          date: defaultAttendance,
        };

        await d.updateStaffData("DefaultAttendance", map);


      }
      if (!doStore(e)) {
        String s = "${e.attendance}${e.overTimeHours}";
        map = {
          date: s,
        };

        await d.updateStaffData(e.name,
            map); //L:was making a mistake here used update for 1st time set

      }

      i++;
    }
  } */

  String getAttendance(String k) {


    if (map[k].containsKey(month)) {
      if (map[k][month].containsKey(date))
        return map[k][month][date].substring(0, 1);
      else {
        return defaultAttendance.toString();
      }
    } else {
      return defaultAttendance.toString();
      //return default;

    }
  }

  String getOT(String k) {

    if (map[k].containsKey(month)) {
      if(map[k][month].containsKey(date))
        return map[k][month][date].substring(1);
      else
      {  return defaultOT.toString();
      }

    } else {
      return defaultOT.toString();


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
                  attendanceButton(refresh,myPrefs),
                  OTButton(ref,myPrefs),


                  FlatButton(
                    onPressed: () async {
                      for (String k in map.keys) {
                        if (checkedMap[k] == true) {
                          print('x');
                          Map<String, dynamic> a = {
                            month: {
                              date: "${selectAttendance}${selectOT}",
                            }};
                          await d.updateStaffData(k, a);
                          checkedMap[k] = false;
                        } else {
                          Map<String, dynamic> m = {
                            month: {
                              date: "${defaultAttendance}${defaultOT}",
                            }
                          };
                          await saveFirst(k, m);
                        }

                        setState(() {});
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
      value: selectAttendance??2,
      icon: const Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style:  TextStyle(color: getTileColor(selectAttendance??2)),
      underline: Container(
        height: 2,
        color:getTileColor(selectAttendance??2) ,
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

  void saveFirst(String k,Map<String,dynamic> m) async
  {
    if (map[k].containsKey(month)) {
      if (!map[k][month].containsKey(date)) {
        await d.updateStaffData(k, m);
      }
    } else {
      await d.updateStaffData(k, m);
    }
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

    setState(() {
      defaultAttendance = x;
    });
  }

  ref1([int x]) {

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
      {  searchList=List<String>();
        if (val != "") {
          for (String k in map.keys) {
            print("val:$val    k:$k");
            if (k.toLowerCase().startsWith(val.toLowerCase())) searchList.add(k);
          }
          print(searchList.toString());
        }

        setState(() {});
      },
      decoration: InputDecoration(
        suffixIcon:  sController.text!=""?IconButton(
          icon: Icon(Icons.cancel_outlined,color: Colors.green,size: 18.0,),
          onPressed: () {
            searchList=List<String>();
            setState(() {
              sController.text = "";
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
    for (String k in map.keys) {
      x[int.parse(getAttendance(k))]++;
    }

    return x;
  }
}

/*

             */






