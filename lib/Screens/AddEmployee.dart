import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:varnam_attendance/Constants/addEmployeeConstants.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
import 'package:varnam_attendance/Firebase/attendanceDatabase.dart';

import 'package:varnam_attendance/models/Employee.dart';
import 'package:intl/intl.dart';
import 'package:varnam_attendance/models/InputFotmatter.dart';
import 'package:varnam_attendance/utilities/functions.dart';

class addEmployee extends StatefulWidget {

  String name;
  addEmployee([this.name]);

  @override
  _addEmployeeState createState() {
    return _addEmployeeState(name);
  }
}

// ignore: camel_case_types
class _addEmployeeState extends State<addEmployee> {
  _addEmployeeState(this.name);
  TextEditingController nameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController aadharController = new TextEditingController();
  TextEditingController wageController = new TextEditingController();
  TextEditingController overTimeController = new TextEditingController();
  TextEditingController allowanceController = new TextEditingController();
  TextEditingController advanceController = new TextEditingController();
  String name;
  String gender;
  int allowance;
  int wage = 1000;
  bool per1;
  bool per2;
  String DOJ;
  String t="Save";
   Color  c=Colors.pink;
   List<bool> selections=[false,false];

  // List<String> labels

  final _formKey = GlobalKey<FormState>();
  bool loading;
  ScrollController scrollController= ScrollController();
  @override
  void initState() {
    print("add init");
    super.initState();
    //DOJ=  DateFormat.yMMMd().format(DateTime.now());
    loading = true;
    per1 = false;
    per2 = false;

    init();
    setState(() {
      loading = false;
    });
  }

  void init() async {
    await Firebase.initializeApp();
    if(name!=null)
      { DocumentReference d=DatabaseListService().getDoc(name);
           DocumentSnapshot k =await d.get();
         Employee e=Employee.fromMapObject(k.data());
         nameController.text=e.name;
         phoneController.text = e.phone;
         aadharController.text = e.aadhar;
         String s=e.wage;
         per1=s[1]=='2'?true:false;
        wageController.text = s.substring(1);
        overTimeController.text = e.overTime;
          s=e.allowance;
          per2=s[1]=='2'?true:false;
        allowanceController.text = s.substring(1);
        advanceController.text=e.advance;
        DOJ=e.DOJ;
      }
  }

  @override
  Widget build(BuildContext context) {
    if (!loading)
      return Scaffold(
        backgroundColor: BGColorScaf,

          appBar:AppBar(
           // leading: Container(),
            title: Text("Add employee"),

          ),
          body:SingleChildScrollView(
            child: Center(
              child: LayoutBuilder(
                builder: (context,contraint)
                { return Container(
                    width:contraint.maxWidth>=480?contraint.maxWidth/3:contraint.maxWidth,
                    //color: BGColor,
                    padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 40.0,bottom: 40),
                    child:Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          getName(1, nameController),
                          SizedBox(height: 10.0,),
                          ToggleButtons(
                          selectedColor: Colors.pink,
                            selectedBorderColor: Colors.pink[800],
                            borderColor: Colors.grey[600],
                            borderWidth: 2.0,
                            //fillColor: Colors.white,
                            color: Colors.blue,
                            children: [
                             Container(
                               width:toggleWidth,
                               child: Center(child: Text("Male")),
                             ),
                              Container(
                                width:toggleWidth,
                                child: Center(child: Text("Female")),
                              ),

                            ],
                            onPressed: (int index)
                            {  gender=index==0?"Male":"Female";
                              if(index==0)
                                {gender="Male";
                                selections[1]=false;
                                }
                              else
                                {gender="Female";
                                selections[0]=false;}

                                selections[index]=!selections[index];
                                setState(() {

                                });
                            },
                            isSelected: selections,
                          ),
                          SizedBox(height: 10.0,),
                          getName(2, phoneController),
                          SizedBox(height: 10.0,),
                          getName(3, aadharController),
                          SizedBox(height: 10.0,),
                          getOTandWage(4, wageController),
                          SizedBox(height: 10.0,),
                          getOTandWage(5, overTimeController),
                          SizedBox(height: 10.0,),
                          getOTandWage(6, allowanceController),
                          SizedBox(height: 10.0,),
                          getName(7, advanceController),
                          SizedBox(height: 20.0,),
                          Center(
                            child: ElevatedButton(
                              style: b,
                              child: Text(
                                DOJ != null ? DOJ : "Enter Date of joining",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                _selectDate(context);
                              },
                            ),
                          ),
                          SizedBox(height: 20.0,),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: c),
                            child: Text(
                              t,
                              style: TextStyle(color:Colors.white),
                            ),
                            onPressed: () async {
                               if(gender==null)
                                 {  Scaffold.of(context).showSnackBar(SnackBar(
                                   duration: Duration(milliseconds: 1500),
                                   content: Row(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Text("Pick a  Gender",style:snackStyle),
                                     ],
                                   ),
                                   backgroundColor: Colors.red,
                                 ));

                                 }
                               else
                                 { if (_formKey.currentState.validate()&&t!="Saved !!") {
                                     print(nameController.text);
                                     await Sync();
                                     setState(() {
                                       t="Saved !!";
                                       c=Colors.green;
                                     });

                                   }
                                   else{
                                   setState(() {
                                     c=Colors.red[800];
                                   });
                                     Scaffold.of(context).showSnackBar(SnackBar(
                                   duration: Duration(milliseconds: 1500),
                                   content: Row(
                                     mainAxisAlignment: MainAxisAlignment.center,
                                     children: [
                                       Text("Enter valid fields",style:snackStyle),
                                     ],
                                   ),
                                   backgroundColor: Colors.red,
                                 ));}

                                 }




                            },
                          ),
                        ],
                      ),
                    ));},

              ),
            ),
          )

      );


    else
      return Container(
        color: Colors.red,
      );
  }

  Future Sync() async {
    Employee e = new Employee(nameController.text,
        aadharController.text,
        DOJ==""?"NA":DOJ,
        phoneController.text,
       getBoolValue(per2)+allowanceController.text.substring(3),
       getBoolValue(per1)+wageController.text.substring(3),
       overTimeController.text.substring(3),
       advanceController.text.substring(3),
        gender);





    await DatabaseListService().insertUserData(e.name, e.map);
    await DatabaseAttendanceService().setStaffData(e.name, {});

  }

  Widget getOTandWage(
    int type,
    TextEditingController t,
  ) {
    return Row(
      children: [
        Expanded(flex: 6, child: getName(type, t)),
        Expanded(flex:1,
        child: Container(),),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style:  b,
            onPressed: () {
              if (type == 4)
                setState(() {
                  per1 = !per1;
                });
              if (type == 6)
                setState(() {
                  per2 = !per2;
                });
            },
            child: Text(
              type == 4 ? getPer(per1) : (type == 6 ? getPer(per2) : "/hour"),
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  TextFormField getName(int type, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: textStyle,
      keyboardType:
          (type != 1) ? TextInputType.numberWithOptions() : TextInputType.text,
      inputFormatters:
          (type != 1) ?getFormatters(type): null,
      validator: (val) {
        return getValidation(type, val);
      },
      onChanged: (val)
      {setState(() {

      });},
      decoration: InputDecoration(
        suffixIcon:  controller.text!=""?IconButton(
          icon: Icon(Icons.cancel_outlined,color: Colors.green,size: 18.0,),
        onPressed: () {
          setState(() {
          controller.text = " ";
        });
      },
    ):null,
        errorStyle: errorStyle,
        labelText: getLabel(type),
        labelStyle: labelStyle,
        hintText: getHints(type),
        hintStyle: hintStyle,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: focusedBorderColor, width: focusedBorderWidth),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: enabledBorderColor, width: enabledBorderWidth),
        ),
      ),
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    print('selectDate');
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null) {
      {
        setState(() {
          DOJ = DateFormat.yMMMd().format(picked);
        });
      }
    }
  }
}






