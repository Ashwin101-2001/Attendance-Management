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
import 'package:varnam_attendance/Screens/MobilePayments.dart';
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
  String name;
  Map<String, Map<String, dynamic>> attendanceMap = Map<String,
      Map<String, dynamic>>();
  TextEditingController sController = new TextEditingController();
  TextEditingController adController = new TextEditingController();
  ScrollController scroll = new ScrollController();
  List<Employee> employeeList = List<Employee>();
  DatabaseListService listService = DatabaseListService();
  DatabaseAttendanceService attendanceService = DatabaseAttendanceService();
  final _formKey = GlobalKey<FormState>();

  List<String> searchList;
  String month;
  bool loading = true;
  bool noChange = false;

  String val1;
  int count;
  double width;
  double height;
  DateTime focusDate = DateTime.now();

  ///bool paid=false;

  @override
  void initState() {
    // TODO: implement initState
    print('init');
    super.initState();
    month = "${getaddedzero(focusDate.month)}-${focusDate.year}";
    init();
  }

  void init() async {
    employeeList = await listService.getEmployeeList();
    name = employeeList[0].name;
    setState(() {
      loading = false;
    });
  }

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
                adController.text=getAdv1(name)??"";
                setUp();
                return getScaffold();
              } else {
                return Loader();
              }
            });
    }
  }

  void setUp() {
    String s;
    try {
      s = attendanceMap[general][month][PL];
      if (s == "") {
        count = 0;
      }
      else {
        s = s.substring(0, s.length - 1);
        var x = s.split(",");
        count = x.length;
      }
    }
    catch (e) {
      count = 0;
    }


    for (String n in attendanceMap.keys) {
      if (!attendanceMap[n].containsKey(month))
        attendanceMap[n][month] = {};
    }


    if (attendanceMap[name][month].containsKey("ADVANCE"))
      adController.text = attendanceMap[name][month]["ADVANCE"];
    else
      adController.text = employeeList[getInt(employeeList, name)].advance;
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
                adController.text=getAdv1(s.name)??"";
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
            trailing: getPaid(s.name) == true
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

  Widget getPay(context) {
    Employee e = getEmp(name ?? employeeList[0].name, employeeList);
    if(adController.text=="")
      {adController.text=e.advance;}

    double attendanceDays = getAttendance(e.name, attendanceMap, month);


    double OTHours = getOT(e.name, attendanceMap, month);

    double wages = getWages(attendanceDays, e.wage);

    double OT = OTHours * double.parse(e.overTime);

    double allowance = getAllowance(e.allowance, attendanceDays, count);

    double Total = double.parse((wages + OT + allowance).toStringAsFixed(0));


    double PF = getPf(wages, e.isPF);

    double ESI = getEsi(wages, PF, e.isESI);

    double netTotal = (Total - PF - ESI).floorToDouble();
    /// print("w:$wages o:$OT T:$Total n:$netTotal");


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
            margin: EdgeInsets.fromLTRB(150, 0, 100, 0),
            child: Row(
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
                      onEditingComplete: () {
                        if (_formKey.currentState.validate()) setState(() {
                          noChange = true;
                        });
                      },
                      decoration: InputDecoration(

                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.pink, width: focusedBorderWidth1),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.pink, width: enabledBorderWidth1),
                        ),
                      ),
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
        ElevatedButton.icon(
          icon: getPayIcon(getPaid(name)),
          label: Text(
              getPaid(name) == true ? "Unpay" : "Pay"),
          style: ElevatedButton.styleFrom(
            primary:
            getPayColor(getPaid(name)),
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


  void change(context) async {
    if (_formKey.currentState.validate()) {
      String n = employeeList[0].name;
      double x;

      if (name != null)
        n = name;

      DocumentSnapshot d =await listService.getDoc(n).get();
      Map<String,dynamic> map1=d.data();

      bool b = attendanceMap[n][month]["PAID"];
      if (b == null)
        b = true;
      else
        b = !b;

      if(b??true)
        {   attendanceMap[n][month]["PAID"] =  true;
        attendanceMap[n][month]["ADVANCE"] = adController.text;



          try{
          x=double.parse(map1["advance"]);
          x=x-double.parse(adController.text);

        }
        catch(e)
        {x=0;
          ///
        }}
      else
        {  attendanceMap[n][month]["PAID"] =  false;
          attendanceMap[n][month]["ADVANCE"] = "0";

          try{
          x=double.parse(map1["advance"]);
          x=x+double.parse(adController.text);
          adController.text="0";

        }
        catch(e)
        {x=0;

        }}
      print("RAEDAY");
      print(map1.toString());
      map1["advance"]=x.toString();
      print(map1.toString());

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


  Widget getSearchBar() {
    return TextFormField(
      controller: sController,
      style: textFormStyle,
      keyboardType: TextInputType.text,
      onChanged: (val) {
        searchBarPress(val);
      },
      decoration: InputDecoration(
        suffixIcon: sController.text != ""
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
            : null,
        labelText: "Search ",
        labelStyle: labelStyle1,
        hintText: "Search for Employee",
        hintStyle: hintStyle1,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.pink,
              width: focusedBorderWidth1),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.pink,
              width: enabledBorderWidth1),
        ),
      ),
    );
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


  bool getPaid(name) {
    bool paid = false;
    // print(name);
   /// print(attendanceMap[name ?? employeeList[0].name].toString());
    if (attendanceMap[name ?? employeeList[0].name][month].containsKey(
        "PAID")) {
      paid = attendanceMap[name][month]["PAID"];
    }
    return paid;
  }


  String getAdv1(name)
  {   print(name);
  print(attendanceMap[name][month].toString());

  if(attendanceMap[name][month].containsKey("ADVANCE"))
  {  return attendanceMap[name][month]["ADVANCE"];
  }
  return null;
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
//   attendanceMap[employeeList[0].name][month]["ADVANCE"] =
//       adController.text;
//   await attendanceService.updateStaffData(
//       employeeList[0].name, attendanceMap[employeeList[0].name]);
// }



// (adController.text == "" ? (double.parse("${e.advance}") >= 0
// ? double.parse("${e.advance}")
// : "0") : double.parse(adController.text))