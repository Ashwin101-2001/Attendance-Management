import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:varnam_attendance/Constants/Overall%20constants.dart';
import 'package:varnam_attendance/Constants/addEmployeeConstants.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Constants/viewConstants.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
import 'package:varnam_attendance/Firebase/attendanceDatabase.dart';
import 'package:varnam_attendance/Screens/AddEmployee.dart';
import 'package:varnam_attendance/Screens/CsvDownload.dart';
// import 'package:varnam_attendance/Screens/MarkAttendance.dart';
// import 'package:varnam_attendance/Screens/markAttendance2.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/models/InputFotmatter.dart';
import 'package:varnam_attendance/utilities/Loading.dart';
import 'package:varnam_attendance/utilities/screens_size.dart';
import 'package:varnam_attendance/utilities/functions.dart';

import 'Payments.dart';
import 'package:flutter/foundation.dart';


final key1 = new GlobalKey<_markAttendance2State>();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Employee> eList;
  List<Employee> eSearchList;

  final _formKey = GlobalKey<FormState>();
  TextEditingController sController = new TextEditingController();
  ScrollController s=new ScrollController();

  Widget myWidget;

  DatabaseListService databaseListService;
  DatabaseAttendanceService databaseAttendanceService;
  Map<String, Map<String, dynamic>> attendanceMap=Map<String, Map<String, dynamic>>();

  bool loading=true;
  double width;
  double height;

  String name;

  /// Inits
  @override
  void initState() {
    super.initState();
    print("view init");
    myWidget=getSmallMenu();
    init();
  }

  void init() async {
    await Firebase.initializeApp();
    databaseListService=DatabaseListService();
    databaseAttendanceService=DatabaseAttendanceService();
    eList = await databaseListService.getEmployeeList();
    name=eList[0].name;
    attendanceMap= await databaseAttendanceService.getAttendanceCollection();
    eSearchList = eList;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = Responsive.width(100, context);
    height = Responsive.width(100, context);

    return LayoutBuilder(builder: (context, constraint) {
      return loading != true
          ? Scaffold(
              backgroundColor: scafColor1,
              appBar: getAppBar(),
              body: Scrollbar(
                child: SingleChildScrollView(
                  child: Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: width *
                                  (getFlex()[0] /
                                      (getFlex()[0] + getFlex()[1])),
                              maxHeight: height * 5,
                              minHeight: 0.0,
                              ),
                          child: Container(
                            child: Row(
                              children: [
                                Align(
                                    alignment: Alignment.topLeft,
                                    child: getRow1()),
                                Expanded(child: getRow2()),
                                //getRow2(),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            //color:Colors.blue,
                            height: 2*height,
                            child:Column(
                              children: [
                                SizedBox(height:100),
                                Text(getName(name),style:nameStyle),
                                Container(
                                  height: height,
                                  child: Align(
                                      alignment: Alignment.topLeft,
                                      child: markAttendance2(name,key1,attendanceMap,eList)),
                                ),
                              ],
                            )
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
          : Loader();
    });
  }

  /// Widgets

  Widget getAppBar()
  {  return AppBar(
    title: Center(child: Text('Employee list')),
    leading: FlatButton.icon(
      label: Text(''),
      icon: Icon(Icons.menu, size: 20,),
      onPressed: () {
        setState(() {
          // side = !side;
          myWidget=myWidget.key==ValueKey(2)?getSmallMenu():getBigMenu();

        });
      },
    ),

  );


  }

  Widget getSmallMenu() {
    return Container(
      //color:menuColor,
      alignment: AlignmentDirectional.topStart,
      padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
      key: ValueKey(1),
      //color: Colors.white,
      width: 80,
      child: Column(
        children: [
          getMenuItems(context, addEmployee(), "Add Staff", Icons.add,1),
         SizedBox(height:menuItemsSpacing),
         //  getMenuItems(context,  markAttendance(), "Attendance", Icons.thumb_up_alt_outlined,1),
         // SizedBox(height:menuItemsSpacing),
          getMenuItems(context,  Payments(), "Payment", Icons.monetization_on_outlined,1),
         SizedBox(height:menuItemsSpacing),
          getMenuItems(context,  csvDownloader(), "Excel", Icons.file_download,1),
         SizedBox(height:menuItemsSpacing),
        ],
      ),


    );
    return Container(color: Colors.green,);
  }

  Widget getBigMenu() {
    if(!isWeb())
   return Container(key: ValueKey(2),);

    return  Container(
      //color:menuColor,
      key: ValueKey(2),
      //color: Colors.white,
      width: 175,
      child: Column(
        children: [
          getMenuItems(context,  addEmployee(), "Add Staff", Icons.add),
          SizedBox(height:menuItemsSpacing),
          // getMenuItems(context,  markAttendance(), "Attendance", Icons.thumb_up_alt_outlined),
          // SizedBox(height:menuItemsSpacing),
          getMenuItems(context,  Payments(), "Payment", Icons.monetization_on_outlined),
          SizedBox(height:menuItemsSpacing),
          getMenuItems(context,  csvDownloader(), "Get Excel/CSV", Icons.file_download),
          SizedBox(height:menuItemsSpacing),
        ],
      ),


    );
  }



  Widget getRow1()
  { return Container(
     //color:Colors.red,
    // height: height,
    child: Column(
      children: [
        AnimatedSwitcher(
          duration: Duration(milliseconds: 350),
          child: myWidget,
          transitionBuilder:
              (Widget child, Animation<double> animation) {
            return FadeTransition(child: child, opacity: animation,);
          },
        ),
        Expanded(child: Container(),)
      ],
    ),
  );}

  Widget getRow2()
  { return Container(
    //color:Colors.yellowAccent,
    padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
    //width:constraint.maxWidth >= 480 ? constraint.maxWidth / 3 : constraint.maxWidth,
    child: Column(
      children: getList(),
    ),
  );}


  Widget getSearchBar() {
    return TextFormField(
      controller: sController,
      style: textFormVStyle,
      keyboardType: TextInputType.text,

      onChanged: (val) {
        if (val != "") {
          eSearchList = List<Employee>();
          for (Employee e in eList) {
            if (e.name.toLowerCase().startsWith(val.toLowerCase())) eSearchList.add(
                e);
          }
        } else
          eSearchList = eList;

        setState(() {});
      },
      decoration: InputDecoration(
        suffixIcon: sController.text != "" ? IconButton(
          icon: Icon(Icons.cancel_outlined, color: Colors.pink, size: 18.0,),
          onPressed: () {
            eSearchList = eList;
            setState(() {
              sController.text = "";
            });
          },
        ) : null,
        labelText: "Search ",
        labelStyle: labelVStyle,
        hintText: "Search for Employee",
        hintStyle: hintVStyle,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: focusedVBorderColor, width: focusedVBorderWidth),
        ),

        /* enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: enabledBorderColor, width: enabledBorderWidth1),
        ),*/
      ),
    );
  }

  Widget getEditButton(e)
  {  return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(0),
        primary:tileColor,),
      label: Text(""),
      icon: Icon(Icons.edit),
      onPressed: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => addEmployee(e.name)),
        );

      }

  );



  }

  Widget getDeleteButton(e)
  {return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(0),
        primary:tileColor,),
      label: Text(""),
      icon: Icon(Icons.delete),
      onPressed: (){
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              'Are you sure?',
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            content: Text(
              'Do you wish to delete details of ${e.name} ?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () async {
                  await databaseListService.deleteUserData(e.name);
                  await databaseAttendanceService.deleteStaffData(e.name);
                  Navigator.pushReplacementNamed(context, "view");
                },

                child: Text(
                  'Yes',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'No',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        );


      }

  );}

  Widget getDiv() {
    return Divider(
      height: 25,
      color: Colors.black,
      thickness: 1,
      // endIndent: 100,
      // indent: 100,
    );
  }


  ///Functions


  List<Widget> getList() {
    List<Widget> a = List<Widget>();

    a.add(Container(

      padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.pink, width: 1.0),
      ),
      child: Form(
        key: _formKey,
        child: getSearchBar(),
      ),
    ));
    for (Employee e in eSearchList) {
      a.add(GestureDetector(
        onTap: ()
        {  key1.currentState.name=e.name;
           key1.currentState.init();
           setState(() {
           name=e.name;

        });
          // Navigator.push(
          // context,
          // MaterialPageRoute(builder: (context) => markAttendance2(e.name)),
      //  );



        },
        child: ListTile(
          tileColor: tileColor,
          title: Text(getName(e.name),style: tileTextStyle,),
          leading: Icon(Icons.person,color: personIconColor,),
          trailing: Wrap(
            spacing: 10,
            children: [
              getEditButton(e),
              getDeleteButton(e),
            ],
          ),
        ),
      ));
      a.add(SizedBox(
        height: 10.0,
      ));
    }

    return a;
  }

  List<int> getFlex()
  { List<int> x= List<int>();
  if(!isWeb())
    //if (width<600)
      {x=[4,0];}
  else
  {x=[3,1];}

  /// CC: Android app ?
  return x;
  }

}



class markAttendance2 extends StatefulWidget {
  String name;
  Map<String, Map<String, dynamic>> attendanceMap=Map<String, Map<String, dynamic>>();
  List<Employee> eList;
  Key key;
  markAttendance2([this.name,this.key,this.attendanceMap,this.eList]);
  @override
  _markAttendance2State createState() => _markAttendance2State(this.name,this.key,this.attendanceMap,this.eList);
}

class _markAttendance2State extends State<markAttendance2>{
  Key key;
  List<Employee> eList;
  _markAttendance2State([this.name,this.key,this.attendanceMap,this.eList]);



  /// Dimensions
  double width;
  double height;

  ///  Date variables
  String month;
  String date;
  DateTime focusDate;
  String name;
  DateTime defaultDate=DateTime(2021,12,1);

  ///  booleans
  bool loading=false;


  ///   Data Structures
  //Map<String, bool> checkedMap= Map<String, bool>();
  Map<String, Map<String, dynamic>> attendanceMap=Map<String, Map<String, dynamic>>();


  DatabaseAttendanceService databaseAttendanceService = new DatabaseAttendanceService();
  DatabaseListService databaseListService=new DatabaseListService();


  /// Controllers
  ScrollController s = new ScrollController();
  TextEditingController controller1 = new TextEditingController();
  TextEditingController controller2 = new TextEditingController();
  TextEditingController controller3 = new TextEditingController();

  /// iNITS
  @override
  void initState() {
    print("Building MA2");
    super.initState();
    if (focusDate == null) focusDate = defaultDate;
    month = "${getaddedzero(focusDate.month)}-${focusDate.year}";
    date = focusDate.day.toString();
    controller1.text="0";
    controller2.text="0";
    controller3.text="0";
    init();
  }

  void init() {
    // if(attendanceMap==null)
    // attendanceMap= await databaseAttendanceService.getAttendanceCollection();
    setTimes(month);
    // setState(() {
    //   loading = false;
    // });
  }
  @override
  Widget build(BuildContext context) {
    print("Building2");
    width = Responsive.width(100, context);
    height = Responsive.width(100, context);

    if(!loading)
      return
        //WillPopScope(
        //   onWillPop: _onWillPop,
        //   child: Scaffold(
        //     body: Center(
        //       child:
        Container(
          //color: Colors.red,
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              getFocusDate(),
              Center(child: getName(1, controller1),),
              SizedBox(height: 40,),
              Center(child: getName(2, controller2)),
              SizedBox(height: 40,),
              Center(child: getName(3, controller3)),
              SizedBox(height: 40,),
              Center(child: getSaveButton(),),
            ],
          ),
        );
    //     ),
    //   ),
    // );
    else
      return WillPopScope(
          onWillPop: _onWillPop,
          child: Loader());
  }


  /// Widgets

  Widget getSaveButton() {
    return Container(
      child: ElevatedButton(
        child: Text("Save"),
        onPressed: () async {
          if (controller1.text != "" && controller2.text != ""&&controller3.text != "") {
            Map<String, dynamic> map = {};
            map = attendanceMap[name];
            try {
              /// Contains month
              map[month][attKey] = controller1.text;
              map[month][OTKey] = controller2.text;
              attendanceMap[name] = map;
            } catch (e) {
              /// else
              map[month] = {
                attKey: controller1.text,
                OTKey: controller2.text,
              };
              attendanceMap[name] = map;
            }
            await databaseAttendanceService.updateStaffData(name, map);
            int temp=eList.indexWhere((element) => (element.name==name));
            eList[temp].advance=controller3.text;
            await databaseListService.updateStaffData(name, {"advance":controller3.text});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
               // backgroundColor: Colors.black,
                content:   Text('Saved !!',style: snackStyle1,textAlign: TextAlign.center,),
                duration: Duration(milliseconds: 1500),

              ),
            );
          } else
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.white,
                content:   Text('Enter valid values!',style: snackStyle,),
                duration: Duration(milliseconds: 1500),

              ),
            );
        },
      ),
    );
  }

  Widget getName(int i,TextEditingController controller) {
    return Container(
      width:150,
      child: TextFormField(
        controller: controller,
        style: textStyle,
        keyboardType: TextInputType.numberWithOptions(decimal: true) ,
        inputFormatters: [DecimalNumberFormatter()],
        validator: (val)=>getValidation(val),
        onChanged: (val)
        {setState(() {});},
        decoration: InputDecoration(
          suffixIcon:  controller.text!=""?IconButton(
            icon: Icon(Icons.cancel_outlined,color: Colors.blue[800],size: 18.0,),
            onPressed: () {
              setState(() {
                controller.text = "0";
              });
            },
          ):null,
          errorStyle: errorStyle,
          labelText: getLabel1(i),
          labelStyle: labelStyle,
          hintText: getHints1(i),
          hintStyle: hintStyle,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: focusedBorderColor, width: focusedBorderWidth),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: enabledBorderColor, width: enabledBorderWidth),
          ),
        ),
      ),
    );
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
                text: focusDate != null ? "  ${DateFormat.yMMM().format(focusDate)}  " : "  ${DateFormat.yMMM().format(DateTime.now())}  ",
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




  /// Functions
  String getValidation(val)
  { if (val=="")
    return "Enter valid values";
  }
  void setTimes(month)
  { print("ST");
  print(name);
  print(month);
  try
  { if(attendanceMap[name][month][attKey]!=null)
  { controller1.text=attendanceMap[name][month][attKey];
  controller2.text=attendanceMap[name][month]["OT"];}

  else
  {controller1.text="0";
  controller2.text="0";}

  }
  catch(e)
  { controller1.text="0";
  controller2.text="0";}

  Employee e =eList.where((element) => (element.name==name)).first;
  controller3.text=e.advance;


  }


  String getHints1(i)
  { if(i==1)
    return "Enter Working days";
  if(i==2)
    return "Enter OverTime Hours";
  if(i==3)
    return "Enter Advance";
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
      setTimes("${getaddedzero(picked.month)}-${picked.year}");
      setState(() {

        focusDate = picked;
        month = "${getaddedzero(picked.month)}-${picked.year}";
        date = picked.day.toString();
      });
    }
  }


  Future<bool> _onWillPop() {
    Navigator.pop(context);
  }
}




// SizedBox(height: boxHeight,),
// GestureDetector(
//   onTap: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => addEmployee()),
//     );
//   },
//   child: Column(
//     children: [
//       Icon(Icons.settings, size: menuIconSize,),
//       Text("Settings",style:menuTextStyle),
//     ],
//   ),),




// GestureDetector(
//   onTap: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => addEmployee()),
//     );
//   },
//   child: ListTile(
//     title: Text("Settings",style:menuTextStyle),
//     leading: Icon(Icons.settings),
//   ),
// ),




// GestureDetector(
// onTap: () {
// Navigator.push(
// context,
// MaterialPageRoute(builder: (context) => addEmployee()),
// );
// },
//
// child: Column(
// children: [
// Icon(Icons.add, size: menuIconSize,color: iconColor),
// Text("Add Staff",style:menuTextStyle),
// ],
// )
// ),
// getDiv(),
// GestureDetector(
// onTap: () {
// Navigator.push(
// context,
// MaterialPageRoute(builder: (context) => markAttendance()),
// );
// },
// child:
// Column(
// children: [
// Icon(Icons.thumb_up_alt_outlined, size: menuIconSize,color: iconColor),
// Text("Attendance",style:menuTextStyle),
// ],
// )
//
// ),
// getDiv(),
// GestureDetector(
// onTap: () {
// Navigator.push(
// context,
// MaterialPageRoute(builder: (context) => Payments()),
// );
// },
// child:
// Column(
// children: [
// Icon(Icons.monetization_on_outlined, size: menuIconSize,color: iconColor),
// Text("Payment",style:menuTextStyle),
// ],
// )
//
//
// ),
// getDiv(),
// GestureDetector(
// onTap: () {
// Navigator.push(
// context,
// MaterialPageRoute(builder: (context) => csvDownloader()),
// );
// },
// child: Column(
// children: [
// Icon(Icons.file_download, size: menuIconSize,color: iconColor),
// Text("Excel",style:menuTextStyle),
// ],
// ),),
// getDiv(),
