import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:varnam_attendance/Constants/Overall%20constants.dart';
import 'package:varnam_attendance/Constants/addEmployeeConstants.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
import 'package:varnam_attendance/Firebase/attendanceDatabase.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/models/InputFotmatter.dart';
import 'package:varnam_attendance/utilities/Loading.dart';
import 'package:varnam_attendance/utilities/functions.dart';
import 'package:intl/intl.dart';
import 'package:varnam_attendance/utilities/screens_size.dart';




class markAttendance2 extends StatefulWidget {
  String name;
  Map<String, Map<String, dynamic>> attendanceMap=Map<String, Map<String, dynamic>>();
  List<Employee> eList;
  markAttendance2([this.name,this.attendanceMap,this.eList]);
  @override
  _markAttendance2State createState() => _markAttendance2State(this.name,this.attendanceMap,this.eList);
}

class _markAttendance2State extends State<markAttendance2>{

  List<Employee> eList;
  _markAttendance2State([this.name,this.attendanceMap,this.eList]);



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
    init();
  }

  void init() {
    if (focusDate == null) focusDate = defaultDate;
    month = "${getaddedzero(focusDate.month)}-${focusDate.year}";
    date = focusDate.day.toString();
    controller1.text="0";
    controller2.text="0";
    controller3.text="0";
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
            await databaseListService.updateStaffData(name, {"advance":controller3.text});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.black,
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


/// In save button for if contains month

// if (map[month][attKey] != null) {
//   map[month][attKey] = controller1.text;
//   map[month][OTKey] = controller2.text;
//
// } else {
//   map[month][attKey] = controller1.text;
//   map[month][OTKey] = controller2.text;
//}