import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:varnam_attendance/Constants/Overall%20constants.dart';
import 'package:varnam_attendance/Constants/PaymentConstants.dart';
import 'package:varnam_attendance/Constants/addEmployeeConstants.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
import 'package:varnam_attendance/Firebase/attendanceDatabase.dart';
import 'package:varnam_attendance/mobileSpecificScreens/MobilePayments.dart';

import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/models/InputFotmatter.dart';
import 'package:varnam_attendance/utilities/Loading.dart';
import 'package:varnam_attendance/utilities/functions.dart';
import 'package:varnam_attendance/utilities/screens_size.dart';
import 'package:intl/intl.dart';

class Payments extends StatefulWidget {
  @override
  _PaymentsState createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {



  Map<String, Map<String, dynamic>> attendanceMap = Map<String, Map<String, dynamic>>();
  List<Employee> employeeList = List<Employee>();
  List<String> searchList;

  DatabaseListService listService = DatabaseListService();
  DatabaseAttendanceService attendanceService = DatabaseAttendanceService();


  String name;
  String month;


  int count;
  DateTime focusDate;
  DateTime defaultDate=DateTime(2021,12,1);

  bool loading = true;
  bool noChange = false;

  TextEditingController PLController = new TextEditingController();
  TextEditingController sController = new TextEditingController();
  TextEditingController adController = new TextEditingController();
  TextEditingController cashController = new TextEditingController();
  ScrollController scroll = new ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();

  double width;
  double height;

  ///bool paid=false;

  /// Inits

  @override
  void initState() {
    // TODO: implement initState
    print('init');
    super.initState();
    focusDate=defaultDate;
    month = "${getaddedzero(focusDate.month)}-${focusDate.year}";
    PLController.text="0";
    count=0;
    init();
  }

  void init() async {
    employeeList = await listService.getEmployeeList();
    name = employeeList[0].name;
    setState(() {
      loading = false;
    });
  }

  /// Widgets

  @override
  Widget build(BuildContext context) {
    width = Responsive.width(100, context);
    height = Responsive.width(100, context);
    if (loading)
      return Loader();
    else {
      if (noChange)
        { noChange=false;
          return getScaffold();}

      else
        return StreamBuilder(
            stream: DatabaseAttendanceService().stream,
            builder: (context, Item) {
              if (Item.hasData) {
                attendanceMap = Item.data;
               // adController.text=getAdv1(name)??"";
                setUp();
                return getScaffold();
              } else {
                return Loader();
              }
            });
    }
  }



  Widget getScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payments"),
      ),
      body: Container(
        padding: isWeb() == true ? EdgeInsets.all(10) : EdgeInsets.all(20),
        child: Scrollbar(
          isAlwaysShown: true,
          controller: scroll,
          child: ListView(
            controller: scroll,
            children: [
              Container(child: getFocusDate1()),
              SizedBox(height: 10),
              Container(
                width: 150,
                child: Column(
                  children: [ getName(1, PLController),
                    SizedBox(height: 10),
                    getSaveButton(),
                    SizedBox(height: 10),],
                ),
              ),


              ConstrainedBox(

                child: Container(
                  child: Row(

                    children: [
                      Expanded(
                        flex: getFlex()[0],
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.pink, width: switchWidth)
                          ),
                          // margin: EdgeInsets.only(
                          //   top: 20,
                          // ),
                          padding: EdgeInsets.only(left: 15.0, right: 15.0,),
                          child: Column(
                            children: [Column(
                              children: getList(),),
                              ConstrainedBox(
                                  constraints: BoxConstraints(
                                      maxHeight: height
                                  ),
                                  child: Container()),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: getFlex()[1],
                        child: (isWeb()) ? Column(

                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Container(
                                child: (isWeb()) ? getPay(context) :
                                Container(),

                              ),
                            ),
                            Expanded(child: Container())],
                        ) : Container(),

                      )
                    ],
                  ),
                ),
                constraints: BoxConstraints(
                    maxHeight: 5 * height
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }

  Widget getName(int i,TextEditingController controller) {
    return Container(
      width:150,
      child: TextFormField(
        controller: controller,
        style: textStyle,
        keyboardType: TextInputType.numberWithOptions() ,
        inputFormatters: [IntegerFormatter()],
        onChanged: (val)
        {setState(() {noChange=true;});},
        validator: (val)=>getValidation(val),
        decoration: InputDecoration(
          suffixIcon:  controller.text!=""?IconButton(
            icon: Icon(Icons.cancel_outlined,color: Colors.blue[800],size: 18.0,),
            onPressed: () {
              setState(() {
                noChange=true;
                controller.text = "0.0";
              });
            },
          ):null,
          errorStyle: errorStyle,
          labelText: "Paid Leaves",
          labelStyle: labelStyle,
          hintText: "Enter Paid Leaves",
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
  Widget getSaveButton()
  {  return  Container(
    child: ElevatedButton(
      child: Text("Save"),
      onPressed: ()  async {
        if(PLController.text!="")
          {  await attendanceService.setStaffData(general,{PL:PLController.text});
          try{count=int.parse(PLController.text);}
          catch(e)
          {}
          noChange=true;
          setState(() {

          });}
        else
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.white,
              content:   Text('Enter valid values!',style: snackStyle,),
              duration: Duration(milliseconds: 1500),

            ),
          );



      },
    ),
  ) ;



  }

  Widget getSearchBar() {
    return TextFormField(
      controller: sController,
      style: textFormStyle,
      keyboardType: TextInputType.text,
      onChanged: (val) {
        searchBarPress(val);
      },
      decoration: InputDecoration(
        suffixIcon: getClearSuffix(),
        labelText: "Search ",
        labelStyle: labelStyle1,
        hintText: "Search for Employee",
        hintStyle: hintStyle1,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pink, width: focusedBorderWidth1),),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pink, width: enabledBorderWidth1),
        ),
      ),
    );
  }

  Widget getClearSuffix() {
    return sController.text != ""
        ? IconButton(
      icon: Icon(
        Icons.cancel_outlined,
        color: Colors.pink,
        size: 18.0,
      ),
      onPressed: () {
        searchList = null;
        setState(() {
          noChange = true;
          sController.text = "";
        });
      },
    )
        : null;
  }

  Widget getFocusDate1() {
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


  /// Functions

    String getValidation(val)
    { if (val=="")
      return "Enter valid values";
    }

  void setUp() {
    if(attendanceMap[general][PL]!=null)
      {  try{
        PLController.text=attendanceMap[general][PL];
        count=int.parse(attendanceMap[general][PL]);

      }
      catch(e)
       {}



      }
    // for (String n in attendanceMap.keys) {
    //   if (!attendanceMap[n].containsKey(month))
    //     attendanceMap[n][month] = {};
    // }
    //
    //
    // if (attendanceMap[name][month].containsKey(advKey))
    //   adController.text = attendanceMap[name][month][advKey];
    // else
    //   adController.text = employeeList[getInt(employeeList, name)].advance;
    //
    //
    // if (attendanceMap[name][month].containsKey(cashKey))
    //   cashController.text = attendanceMap[name][month][cashKey];
    // else
    //   cashController.text ="";

    adController.text=getAdvPaidAndCash(name, advKey)?? employeeList[getInt(employeeList, name)].advance;
    cashController.text=getAdvPaidAndCash(name, cashKey)??"";

  }





  Widget getPay(context) {
    Employee e = getEmp(name ?? employeeList[0].name, employeeList);
    if(adController.text=="")
      {adController.text=e.advance;}

    double attendanceDays = getAttendance(e.name, attendanceMap, month);


    double OTHours = getOT(e.name, attendanceMap, month);

    double wages = getWages(attendanceDays, e.wage);

    double OT = OTHours * double.parse(e.overTime);
    print("count::: $count");

    double allowance = getAllowance(e.allowance, attendanceDays,count);
    /// CI   ,count

    double Total = double.parse((wages + OT + allowance).toStringAsFixed(0));


    double PF = getPf(wages, e.isPF);

    double ESI = getEsi(wages, PF, e.isESI);

    double netTotal = (Total - PF - ESI).floorToDouble();
    /// print("w:$wages o:$OT T:$Total n:$netTotal");

    if(cashController.text=="")cashController.text="${netTotal - getAdvNumber(adController.text)}";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Text(
          "Salary for $month ",
          style: payStyle1,
        ),
        getDiv(),
        Text("Name : ${name ?? employeeList[0].name} ", style: payStyle),
        getDiv(),
        Text("Total :  $netTotal", style: payStyle),
        getDiv(),
        Text("Advance :  ${e.advance}", style: payStyle),
        getDiv(),


        Container(
            //margin: EdgeInsets.fromLTRB(150, 0, 100, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Advance Deduction:  ", style: payStyle),
                Container(
                  width: 100,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      validator: (val) {
                        return formValidator(val, e);
                      },
                      textAlign: TextAlign.center,
                      controller: adController,
                      style: payStyle,
                      keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [DecimalNumberFormatter()],
                      onChanged: (val) {
                        if(val=="")
                          adController.text="0";
                        if (_formKey.currentState.validate()) setState(() {
                          noChange = true;
                        });
                      },
                      decoration: getDecor(),
                    ),
                  ),
                )
              ],
            )),

        getDiv(),
        Text(
            "Amount to be paid :  ${netTotal - getAdvNumber(adController.text)}",
            style: payStyle),
        getDiv(),
        Container(
          //margin: EdgeInsets.fromLTRB(150, 0, 100, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Cash paid:  ", style: payStyle),
                Container(
                  width: 100,
                  child: Form(
                    key: _formKey1,
                    child: TextFormField(
                      validator: (val) {
                      return formValidator1(val, "${netTotal - getAdvNumber(adController.text)}");
                      },
                      textAlign: TextAlign.center,
                      controller: cashController,
                      style: payStyle,
                      keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [DecimalNumberFormatter()],
                      onChanged: (val) {
                        // if (_formKey.currentState.validate()) setState(() {
                        //   noChange = true;
                        // });
                        if(val=="")
                          cashController.text="0";
                        print("OEC");
                        setState(() {
                          noChange=true;
                        });
                      },
                      decoration: getDecor(),
                    ),
                  ),
                )
              ],
            )),
        getDiv(),
        Text(
            "Transfer amount :  ${netTotal - getAdvNumber(adController.text)-double.parse(cashController.text)}",
            style: payStyle),
        getDiv(),
        ElevatedButton.icon(
          icon: getPayIcon(getAdvPaidAndCash(name, paidKey)??false),
          label: Text(
              (getAdvPaidAndCash(name,paidKey)??false) == true ? "Unpay" : "Pay"),
          style: ElevatedButton.styleFrom(
            primary:
            getPayColor(getAdvPaidAndCash(name,paidKey)??false),
          ),

          onPressed: () {
            change(context);
          },
        )
      ],
    );
  }





  String formValidator(val, e) {
    if (val == "") return "Empty !!";
    try {
      double b = double.parse(val);
      if (b <= double.parse("${e.advance}"))
        setState(() {
          noChange = true;
        });
      else
        return "";
    } catch (a) {
       return "";
    }
  }


  String formValidator1(val,x) {
    if (val == "") return "Empty !!";
    try {
      double b = double.parse(val);
      if (b <= double.parse(x))
        setState(() {
          noChange = true;
        });
      else
        return "";
    } catch (a) {
      return "";
    }
  }



  List<Widget> getList() {
    List<Widget> w = List<Widget>();
    w.add(SizedBox(
      height: 10,
    ));

    /// SEARCH BAR
    w.add(getSearchBar());
    w.add(SizedBox(
      height: 10,
    ));


    /// LIST
    for (Employee s in employeeList) {
      if (searchList == null || searchList.contains(s.name))
      {  w.add(GestureDetector(
        onTap: () {
          if (isWeb()) {
            setState(() {
              noChange = true;
              name = s.name;
              adController.text=getAdvPaidAndCash(s.name,advKey)??"";
              cashController.text="";
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      mobilePayment(
                          attendanceMap, employeeList, month, s.name)),
            );
          }
        },
        child: ListTile(
          tileColor: Colors.orange,
          title: Text(s.name),
          leading: Icon(Icons.person),
          trailing: (getAdvPaidAndCash(s.name,paidKey)??false) == true
              ? Icon(
            Icons.check,
            color: Colors.green,
          )
              : Text(""),
        ),
      ));

      w.add(SizedBox(
        height: 10,
      ));}

    }

    return w;
  }

  void change(context) async {
    if (_formKey.currentState.validate()&&_formKey1.currentState.validate()) {
      String n = employeeList[0].name;
      double x;

      if (name != null)
        n = name;

      DocumentSnapshot d =await listService.getDoc(n).get();
      Map<String,dynamic> map1=d.data();

      bool b = attendanceMap[n][month][paidKey];
      if (b == null)
        b = true;
      else
        b = !b;

      if(b??true)  /// Pay
        {   attendanceMap[n][month][paidKey] =  true;
        attendanceMap[n][month][advKey] = adController.text;
        attendanceMap[n][month][cashKey] = cashController.text;

        try{
          x=double.parse(map1["advance"]);
          x=x-double.parse(adController.text);

        }
        catch(e)
        {x=0;
          ///
        }}
      else    ///Unpay
        {  attendanceMap[n][month][paidKey] =  false;
           attendanceMap[n][month][advKey] = "0";
          attendanceMap[n][month][cashKey] = "";


          try{
          x=double.parse(map1["advance"]);
          x=x+double.parse(adController.text);
          adController.text="0";

        }
        catch(e)
        {x=0;

        }}

      // print("RAEDAY");
      // print(map1.toString());
      // map1["advance"]=x.toString();
      // print(map1.toString());

      await attendanceService.updateStaffData(n, attendanceMap[n]);
      await listService.updateStaffData(n, map1);

      setState(() {

      });

      /// catch
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:   Text('Enter a valid number!'),
          duration: Duration(milliseconds: 1500),

        ),
      );
    }
  }

  void searchBarPress(val) {
    searchList = List<String>();
    for (Employee k in employeeList) {
      if (k.name.toLowerCase().startsWith(val.toLowerCase()))
        searchList.add(k.name);
    }
    setState(() {
      noChange = true;
    });
  }

  MaterialColor getPayColor(pay) {
    if (pay)
      return Colors.red;
    else
      return Colors.green;
  }


  Icon getPayIcon(pay) {
    if (pay)
      return Icon(Icons.cancel_outlined);
    else
      return Icon(Icons.check);
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
        /// noChange = true;
        focusDate = picked;
        month = "${getaddedzero(picked.month)}-${picked.year}";
      });
    }
  }


  // bool getPaid(name) {
  //   bool paid = false;
  //   // print(name);
  //  /// print(attendanceMap[name ?? employeeList[0].name].toString());
  //   if (attendanceMap[name ?? employeeList[0].name][month].containsKey(
  //       paidKey)) {
  //     paid = attendanceMap[name][month][paidKey];
  //   }
  //   return paid;
  // }


   getAdvPaidAndCash(name,k)
  {   print(name);
  // print(attendanceMap[name][month].toString());
   print(k);
   try{
     print(attendanceMap[name][month][k]);
     if(attendanceMap[name][month][k]==""&&k==advKey)
       return null;
      return attendanceMap[name][month][k];}
   catch(e)
   { print(e.toString());
     print(null);
     return null;}

  }
}


Widget getDiv() {
  return Divider(
    height: 40,
    color: Colors.black,
    thickness: 1,
    endIndent: 100,
    indent: 100,
  );
}



double getAdvNumber(s)
{
  try{
    double k= double.parse(s);
    return k;
  }
  catch(e)
  {}

}

List<int> getFlex() {
  List<int> x = List<int>();
  if (!isWeb())
  //if (width<600)
  {
    x = [1, 0];
  } else {
    x = [1, 1];
  }

  return x;
}


InputDecoration getDecor()
  {  return InputDecoration(

    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
          color: Colors.pink, width: focusedBorderWidth1),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
          color: Colors.pink, width: enabledBorderWidth1),
    ),
  );





  }



//Row(
//   children: [
//     Expanded(
//       flex: getFlex()[0],
//       child: Container(
//         decoration: BoxDecoration(
//             border: Border.all(
//                 color: Colors.pink, width: 2.0)),
//         padding: EdgeInsets.all(20),
//         child: ListView(
//           children: getList(),
//         ),
//       ),
//     ),
//     Expanded(
//       flex: getFlex()[1],
//       //child:Text("a"),
//       child: (isWeb())?getPay(context):
//       Container(),
//     ),
//     // ignore: missing_return
//   ],
// ),



// else {
//   bool b = attendanceMap[employeeList[0].name][month]["PAID"];
//   if (b == null)
//     b = true;
//   else
//     b = !b;
//   attendanceMap[employeeList[0].name][month]["PAID"] = b ?? true;
//   attendanceMap[employeeList[0].name][month][advKey] =
//       adController.text;
//   await attendanceService.updateStaffData(
//       employeeList[0].name, attendanceMap[employeeList[0].name]);
// }



// (adController.text == "" ? (double.parse("${e.advance}") >= 0
// ? double.parse("${e.advance}")
// : "0") : double.parse(adController.text))


/// Paid Leave Set up part
// String s;
// try {
// s = attendanceMap[general][month][PL];
// if (s == "") {
// count = 0;
// }
// else {
// s = s.substring(0, s.length - 1);
// var x = s.split(",");
// count = x.length;
// }
// }
// catch (e) {
// count = 0;
// }





// Container(
//     margin: EdgeInsets.fromLTRB(150, 0, 100, 0),
//     child: Row(
//       children: [
//         Text("Advance Deduction:  ", style: payStyle),
//         Container(
//           width: 100,
//           child: Form(
//             key: _formKey,
//             child: TextFormField(
//               validator: (val) {return formValidator(val, e);},
//               textAlign: TextAlign.center,
//               controller: adController,
//               style: payStyle,
//               keyboardType:
//               TextInputType.numberWithOptions(decimal: true),
//               inputFormatters: [DecimalNumberFormatter()],
//               onEditingComplete: () {
//                 if (_formKey.currentState.validate()) setState(() {
//                   noChange = true;
//                 });
//               },
//               decoration:  getDecor(),
//             ),
//           ),
//         )
//       ],
//     )),
// getDiv(),