import 'dart:io';

import 'package:custom_switch/custom_switch.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:varnam_attendance/Constants/Overall%20constants.dart';
import 'package:varnam_attendance/Constants/addEmployeeConstants.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Firebase/attendanceDatabase.dart';
import 'package:varnam_attendance/Screens/Home.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
import 'package:varnam_attendance/utilities/Loading.dart';
import 'package:varnam_attendance/utilities/OT%20button.dart';
import 'package:varnam_attendance/utilities/functions.dart';
import 'package:varnam_attendance/utilities/getAttendanceButton.dart';
import 'package:varnam_attendance/utilities/screens_size.dart';
import 'package:intl/intl.dart';

class markAttendance extends StatefulWidget {
  DateTime focusDate;

  markAttendance([this.focusDate]);

  @override
  _markAttendanceState createState() => _markAttendanceState(this.focusDate);
}

class _markAttendanceState extends State<markAttendance> {
  final _formKey = GlobalKey<FormState>();

  _markAttendanceState([this.focusDate]);



  /// OT and Attendance
  double defaultOT;
  int defaultAttendance;
  double selectOT;
  int selectAttendance;

  /// Dimensions
  double width;
  double height;

  ///  Date variables
  String month;
  String date;
  DateTime focusDate;

  Widget myWidget;

  ///  Filters
  int filter=0;
  int filter1;
  double filterOT;
  int filterAttendance;
  String filterGender="Male";


  ///  booleans
  bool loading=true;
  bool checkAll=false;
  bool settings=false;
  bool isPaidLeave=false;
  bool noChange=false;

  ///   Data Structures
  Map<String, bool> checkedMap= Map<String, bool>();
  Map<String, Map<String, dynamic>> map=Map<String, Map<String, dynamic>>();
  List<String> searchList;
  List<Employee> eList;

  SharedPreferences myPrefs;
  DatabaseAttendanceService databaseAttendanceService = new DatabaseAttendanceService();
  DatabaseListService databaseListService=DatabaseListService();

  /// Controllers
  ScrollController s = new ScrollController();
  TextEditingController sController = new TextEditingController();



  @override
  void initState() {
    super.initState();
    if (focusDate == null) focusDate = DateTime.now();
    month = "${getaddedzero(focusDate.month)}-${focusDate.year}";
    date = focusDate.day.toString();
    init();
  }

  void init() async {
    myPrefs = await SharedPreferences.getInstance();
    eList = await databaseListService.getEmployeeList();

    // myPrefs.remove("defaultOT");
    // myPrefs.remove("defaultAttendance");

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
    setState(() {
      loading = false;
    });
  }

  Future<bool> _onWillPop() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = Responsive.width(100, context);
    height = Responsive.width(100, context);
    if (loading == true) {
      return Loader();
    }
    if (!noChange)
      return StreamBuilder(
        stream: DatabaseAttendanceService().stream,
        builder: (context, Item) {
          print("Ila da ");
          if (Item.hasData) {
            map = Item.data;
            setUp();
            return getScaffold();
          } else
            return Loader();
        },
      );
    else {
      print("saved");
      noChange = false;
      return getScaffold();

    }
  }

  void setUp() {
    Map<String, dynamic> map1 = map[general];
    if (map1 != null) {
      String temp;
      if (!map1.containsKey(month)) {
        temp = "";
      } else
        temp = map1[month][PL];
      if ((temp.contains(date)))
        isPaidLeave = true;
      else
        isPaidLeave = false;

      map.remove(general);
      map1.clear();
      bool x = false;
      if (searchList == null) {
        x = true;
        searchList = List<String>();
      }
      for (String k in map.keys) {
        if (x == true) searchList.add(k);
      }
    }
  }

  Widget getScaffold()
  {  return Scaffold(
    backgroundColor: BGColor1,
    appBar: AppBar(
      //leading: Container(),
      title: Center(child: Text('Mark attendance')),
      actions: [
        Padding(
          padding:  EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: IconButton(
            icon: Icon(Icons.settings),
            onPressed: ()
            {setState(() {
              noChange=true;
              myWidget=myWidget??getStatsWidget();
              myWidget=myWidget.key==ValueKey(2)?getStatsWidget():settingsStack();
            });},
          ),
        )
      ],
    ),
    body: Center(
      child: LayoutBuilder(
        builder: (context1, contraint) {
          return Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),

            child: Scrollbar(
              isAlwaysShown: true,
              controller: s,
              child: ListView(
                controller: s,
                children: [

                  ConstrainedBox(

                    child: Container(
                      child: Row(

                        children: [
                          Expanded(
                            flex: getFlex()[0],
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.pink,width:switchWidth)
                              ),
                              margin: EdgeInsets.only(
                                top: 20,
                              ),
                              padding: EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                              ),
                              child: Column(
                                children: [Column(
                                  children: getList(),),
                                  ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxHeight: 3*height
                                      ),
                                      child: Container()),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: getFlex()[1],
                            child: (isWeb())?Column(

                              children: [
                                Padding(
                                  padding:  EdgeInsets.only(top: 100),
                                  child: Container(
                                    child: AnimatedSwitcher(
                                      duration: Duration(milliseconds: 350),
                                      child: myWidget??getStatsWidget(),
                                      transitionBuilder:
                                          (Widget child, Animation<double> animation) {
                                        return FadeTransition(child: child, opacity: animation,);
                                      },
                                    ),

                                  ),
                                ),
                                Expanded(child: Container())                                    ],
                            ):Container(),

                          )
                        ],
                      ),
                    ),
                    constraints: BoxConstraints(
                        maxHeight: 6*height
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
    bottomNavigationBar: Builder(
      builder:(context1)
      {return getBottomAppBar(context1);},),
  );



  }

  /// Widget Functions
  List<Widget> getList() {
    List<Widget> a = List<Widget>();

    a.add(Container(
      height: 10.0,
      color: BGColor1,
    ));


    ///  Focus Date
    a.add( Center(
      child:getFocusDate(),
    ));

    /// Search bar
    a.add(Container(
      padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0),

      child: Form(
        key: _formKey,
        child: getSearchBar(),
      ),
    ));
    a.add(Container(
      height: 10.0,
      color: BGColor1,
    ));


    ///  FilterAndPLRow()
    a.add(getFilterAndPLRow());
    a.add(Container(
      height: 10.0,
      color: BGColor1,
    ));


    /// List of staffs
    ///
    print("FILTERRR : $filter");
    for (String k in searchList) {

      double OT;
      int att;
      String  g;
      try{
        OT=double.parse(getOT(k));
        att=int.parse(getAttendance(k));
      }
      catch(e)
     {  OT=-1;
      att=-1;}

      g=getGender(k);



      if (( OT== (filterOT) ||
             att == (filterAttendance))||(g==filterGender)||filter==0) {

        print("$OT :: $filterOT");
        print("$att :: $filterAttendance");
        print("$g :: $filterGender");


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
              noChange=true;
              checkedMap[k] = val;
            });
            print(checkedMap.toString());
          },
          activeColor: Colors.red,
        ));
        a.add(Container(
          height: 10.0,
          color: BGColor1,
        ));
      }
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
        setState(() {
          noChange=true;
        });
      },
      decoration: InputDecoration(
        suffixIcon: sController.text != ""
            ? IconButton(
                icon: Icon(
                  Icons.cancel_outlined,
                  color: getTileColor(defaultAttendance ?? 2),
                  size: 18.0,
                ),
                onPressed: () {
                  setSearchList("");
                  setState(() {
                    noChange=true;
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
              color: focusedBorderColor1,
              width: focusedBorderWidth1),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: enabledBorderColor1,
              width: enabledBorderWidth1),
        ),
      ),
    );
  }

  Widget getBottomAppBar(c) {
    return Container(
        color: bottomColor,
        padding: EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              flex: getFlex()[0],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FlatButton(
                    child: Text("  MARK ATTENDANCE  ", style: textStyle1,),
                    onPressed: () async {

                      if(checkedMap.values.contains(true))
                      getShowDialog();

                      else
                      { Scaffold.of(c).showSnackBar(SnackBar(
                        duration: Duration(milliseconds: 1500),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Pick Staffs for Marking Attendance",style:snackStyle),
                          ],
                        ),
                        backgroundColor: Colors.red,
                      ),
                      );

                      }

                    },
                  ),
                ],
              ),
            ),
            Expanded(
                flex: getFlex()[1],
                child: Container(
                  child: Text(""),
                ))
          ],
        ));
  }

  void getShowDialog() {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: AlertDialog(
            backgroundColor: dailogColor,
            title: Center(
              child: Text(
                'Mark Attendance',
                style: dailogHeadStyle,
              ),
            ),
            // content: Text('Do you want to exit App ?',style: TextStyle(color: Colors.white70),),

            content: Container(
              height: 250.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  getDiv(),
                  Center(
                    child: Text(
                      'Pick Attendance',
                      style: dailogSubHeadStyle,
                    ),
                  ),
                  // getAttendanceDDButton(),
                  attendanceButton(refresh, selectAttendance??2,myPrefs),
                  getDiv(),
                  Center(
                    child: Text(
                      'Pick overtime',
                      style: dailogSubHeadStyle,
                    ),
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin:EdgeInsets.only(left:45),
                      child: OTButton(ref, myPrefs, 1)),
                  getDiv(),
                  //  SizedBox(height: 30,),

                  Container(
                    width: 80,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.pink),
                      onPressed: () async {
                        print("Mark");
                           if(checkAll)
                             checkAll=false;

                            for (String k in map.keys) {
                            if (checkedMap[k] == true) {
                              Map<String, dynamic> a;

                              if (map[k].containsKey(month)) {
                                a = Map.from(map[k][month]);
                                a[date] = "${selectAttendance}${selectOT}";
                              } else {
                                a = {date: "${selectAttendance}${selectOT}"};
                              }
                              Map<String, dynamic> a1 = {month: a};

                              databaseAttendanceService.updateStaffData(k, a1);
                              checkedMap[k] = false;
                            }



                          }
                           setState(() {});
                         /// catch
                          Navigator.pop(context);


                      },
                      child: Text(
                        'Mark ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }


  /// Filter Widgets
  Widget getFilterAndPLRow() {
    List<Widget> list = List<Widget>();

    ///  FilterType
    list.add(FilterType());
    list.add(SizedBox(width: 10.0));

    /// FilterSelection
    if (filter != 0) list.add(FilterSelection());

    /// Check all box
    list.add(SizedBox(width: 10.0));
    list.add(Checkbox(
      activeColor: Colors.red,
      value: checkAll,
      onChanged: (val) {
        checkedMap=Map<String,bool>();
        checkAll = val;

       if(val)
         {  for (String k in searchList) {
           double OT;
           int att;
           String  g;
           try{
             OT=double.parse(getOT(k));
             att=int.parse(getAttendance(k));
           }
           catch(e)
           {  OT=-1;
           att=-1;}

           g=getGender(k);


           if (( OT== (filterOT) ||
               att == (filterAttendance))||(g==filterGender)||filter==0)
           {checkedMap[k] = val;}

         }}




        noChange = true;
        setState(() {});
      },
    ));
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.pink, width: switchWidth)),
          child: Row(
            /// Paid leave Button
            children: [
              Text("Paid Leave  :   ", style: pesiStyle),
              CustomSwitch(
                activeColor: activeColor,
                value: isPaidLeave,
                onChanged: (value) async {
                  change(value);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: list,
        )
      ],
    );
  }


  Widget FilterType() {
    return DropdownButton<int>(
      value: filter,
      icon: const Icon(Icons.filter_alt_outlined,color: Colors.pink,),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.blue),
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
      onChanged: (int newValue) async {
        setState(() {
          print("${getit(newValue)}");
          noChange=true;
          filter = newValue;
          filterAttendance=null;
          filterOT= null;
          filterGender=null;
          switch(newValue)
          { case 1:
            filterAttendance=2;
            break;
            case 2:
              filterOT= 3;
              break;
            case 3:
              filterGender="Male";



          }
          if(filter==1)
            { filterAttendance=filterAttendance??2;
            }
          else if(filter==2)
            {filterOT=filterOT??3;}
        });
      },
      items: <int>[0, 1, 2, 3].map<DropdownMenuItem<int>>((int value) {
        return DropdownMenuItem<int>(
          value: value,
          child:
              Text(getit(value), style: TextStyle(color: filterTextColor)),
        );
      }).toList(),
    );
  }

  Widget FilterSelection() {
    if(filter!=3)
    return filter == 1
        ? attendanceButton(refresh2, filterAttendance??2,myPrefs)
        : OTButton(ref2, myPrefs, 1);
    else
      return genderButton();

  }


  Widget genderButton() {
    return DropdownButton<String>(
      value: filterGender,
      icon: const Icon(Icons.filter_alt_outlined,color: Colors.pink,),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.blue),
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
      onChanged: ( newValue)   {
        setState(() {
          noChange=true;
          filterGender = newValue;
        });
      },
      items: <String>[
        "Male", "Female"].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: filterTextColor)),
        );
      }).toList(),
    );
  }



  ///  Utility Functions

  String getAttendance(String k) {
    switch (getType(k)) {
      case 1:
        if(map[k][month][date]==Na)
          return "5";
        else
          return map[k][month][date].substring(0,1);
        break;
      case 0:
        return "5";

      case -1:
        return "5";   /// Instead of NA to parse later
    }
  }

  int getType(String k) {
    if (map[k].containsKey(month)) {
      if (map[k][month].containsKey(date)) {
        return 1;
      } else
        return 0;
    } else {
      return -1;
      //return default;

    }
  }

  String getOT(String k) {
    switch (getType(k)) {
      case 1:
        if(map[k][month][date]==Na)
          return "NA";
        else
        return map[k][month][date].substring(1);
        break;
      case 0:
        return "NA";   /// White color

      case -1:
        return "NA";
    }
  }

  String getGender(k) {
    for (Employee e in eList) {
      if (e.name == k)
        return e.gender;
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

  void change (value) async{
    await databaseAttendanceService.updatePaidLeave(month,date,value);
    String aot;
    int pos=1;
    if (value == true) {
      aot="20";
    } else {
      aot=Na;
    }

    for (String k in map.keys) {
      Map<String, dynamic> a;

      if (map[k].containsKey(month)) {
        a =Map.from(map[k][month]) ;
        a[date] ="$aot" ;
      } else {
        a = {date: "$aot"};
      }
      Map<String, dynamic> a1 = {month: a};
      databaseAttendanceService.updateStaffData(k, a1);

      setState(() {
        if (pos == 1) {
          pos++;
          isPaidLeave = value;
        }
      });
      /// catch

    }


  }



  /// Refresh Functions
  refresh([int x]) {
    setState(() {
      noChange=true;
      selectAttendance = x;
    });
  }

  ref([double x]) {
    setState(() {
      noChange=true;
      selectOT = x;
    });
  }

  refresh1([int x]) {
    setState(() {
      noChange=true;
      defaultAttendance = x;
    });
  }

  ref1([double x]) {
    setState(() {
      noChange=true;
      defaultOT = x;
    });
  }

  ref2([double x]) {
    setState(() {
      noChange=true;
      filterAttendance = null;
      filterOT = x;
    });
  }

  refresh2([int x]) {
    setState(() {
      noChange=true;
      filterOT = null;
      filterAttendance = x;
    });
  }

  /// mISC



  List<int> getStats() {
    List<int> x = [0, 0, 0];
    for (String k in map.keys) {
      if (int.parse(getAttendance(k)) != 5) x[int.parse(getAttendance(k))]++;
    }

    return x;
  }

  Widget getStatsWidget() {
    return Container(
      margin: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black,width:switchWidth)
      ),
      key: ValueKey(1),

      width: width / 4,

      child: Column(
        children: [
          Container(
              width: width / 4,
              padding: EdgeInsets.only(
                  right: 10.0, left: 10.0, top: 5.0, bottom: 5.0),

              decoration: BoxDecoration(),
              child: Center(
                  child: Text(
                    " Statistics",
                    style: TextStyle(fontSize: 25,color: Colors.blue[800]),
                  ))),
          getDiv(),
          Container(
              width: width / 4,
              padding: EdgeInsets.only(
                  right: 20.0, left: 20.0, top: 5.0, bottom: 5.0),
              decoration: BoxDecoration(
              ),
              child: Text("Present :  ${getStats()[2]}",style:TextStyle(color: Green))),
          getDiv(),
          Container(
              width: width / 4,
              padding: EdgeInsets.only(
                  right: 10.0, left: 10.0, top: 5.0, bottom: 5.0),

              decoration: BoxDecoration(),
              child: Text("  Absent :  ${getStats()[0]}",style:TextStyle(color: Red))),
          getDiv(),
          Container(
              width: width / 4,
              padding: EdgeInsets.only(
                  right: 20.0, left: 20.0, top: 5.0, bottom: 5.0),
              decoration: BoxDecoration(

              ),
              child: Text("Halfday :  ${getStats()[1]}",style:TextStyle(color: Orange))),
          getDiv(),
        ],
      ),
    );
  }

  Widget settingsStack()
  {
    return  Container(
      margin: EdgeInsets.only(left: 30),
      padding: EdgeInsets.only(top: 100.0,bottom: 100),
      key:ValueKey(2),
      color: Colors.white,
      //width: width / 5,
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: [ Text("Default Values",textAlign: TextAlign.left,style: settingsStyle,),
          getDiv(),
          Text("Attendance",style: settingsStyle1,),
          getDiv(),
          attendanceButton(refresh1, selectAttendance??2, myPrefs,1),
          SizedBox(height: 15,),
          Text("OverTime",style: settingsStyle1,),
          getDiv(),
          Center(
            child: Container(
                padding: EdgeInsets.only(left:60),
                child: OTButton(ref1, myPrefs, 1)),
          ),
          getDiv(),],
      ),


    );







  }


  Future<Null> _selectDate(BuildContext context) async {
    print('selectDate');

    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: focusDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        noChange=true;
        focusDate = picked;
        month = "${getaddedzero(picked.month)}-${picked.year}";
        date = picked.day.toString();
      });
    }
  }
  Widget getFocusDate() {
    return Container(
      margin: EdgeInsets.all(10.0),
      width: 200,
      child: FlatButton(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: focusDate != null
                    ? "  ${DateFormat.yMMMd().format(focusDate)}  "
                    : "  ${DateFormat.yMMMd().format(DateTime.now())}  ",
                style: dateStyle,
              ),
              WidgetSpan(
                child: Icon(
                  Icons.arrow_drop_down,
                  color: arrowColor,
                ),
              ),
            ],
          ),
        ),
        onPressed: () {
          _selectDate(context);
        },
      ),
    );
  }

}


List<int> getFlex() {
  List<int> x = List<int>();
  if (!isWeb())
  //if (width<600)
  {
    x = [4, 0];
  } else {
    x = [3, 1];
  }

  return x;
}



Widget getDiv() {
  return Divider(
    height: 20,
    color: Colors.black,
    thickness: 1,
    endIndent: 20,
    indent: 20,
  );
}




// void saveFirst(String k, Map<String, dynamic> m) async {
//   if (map[k].containsKey(month)) {
//     if (!map[k][month].containsKey(date)) {
//       await databaseAttendanceService.updateStaffData(k, m);
//     }
//   } else {
//     await databaseAttendanceService.updateStaffData(k, m);
//   }
// }


         /// In get List
//print("k:$k l:${searchList.length}   contains:${searchList.contains(k)}");
//if((searchList.length!=0&&searchList.contains(k)))
//if(DateTime.focusDate().day!=int.parse(date))


/* */

/* */

/* */

/* */



//  else {
//
//   Map<String, dynamic> m;
//   switch (getType(k)) {
//     case 1:
//       break;
//     case 0:
//       m =Map.from(map[k][month]) ;
//       m[date] = "${defaultAttendance}${defaultOT}";
//       break;
//     case -1:
//       m = {date: "${defaultAttendance}${defaultOT}"};
//       break;
//   }
//   m={month:m};  // Updating month
//   print(k);
//   print(map.toString());
//   print("dt:${getType(k)}");
//   if (DateTime.now().day == int.parse(date)) //today
//       {
//     if (getType(k) != 1)   databaseAttendanceService.updateStaffData(k, m);
//   }
// }

