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
  String val1;
  int count;
  double width;
  double height;

  @override
  void initState() {
    // TODO: implement initState
    print('init');
    super.initState();

    DateTime now = DateTime.now();
    month = "${getaddedzero(now.month)}-${now.year}";

    init();
  }

  void init() async {
    employeeList = await listService.getEmployeeList();
    name=employeeList[0].name;
    print('init2');
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = Responsive.width(100, context);
    height = Responsive.width(100, context);
    print('build');
    return loading != true
        ? StreamBuilder(
        stream: DatabaseAttendanceService().stream,
        builder: (context, Item) {
          if(Item.hasData)
            { print("$name");
            attendanceMap= Item.data;
             String s=attendanceMap[general][month][PL];
             s=s.substring(0,s.length-1);
             var x=s.split(",");
             count=x.length;
            for(String n in attendanceMap.keys)
            {if(!attendanceMap[n].containsKey(month))
              attendanceMap[n][month]={};
            }
            if(Item.data[name][month].containsKey("ADVANCE"))
              adController.text=Item.data[name][month]["ADVANCE"];
            else
              adController.text=employeeList[getInt(employeeList,name)].advance;

            return Scaffold(
              appBar: AppBar(
                title: Text("Payments"),
              ),
              body: Container(
                padding: isWeb()==true?EdgeInsets.all(50):EdgeInsets.all(20),
                 child: Scrollbar(
                   isAlwaysShown: true,
                   controller: scroll,
                   child: ListView(
                     controller: scroll,
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
                                   // decoration: BoxDecoration(
                                   //     border: Border.all(
                                   //         color: Colors.pink,
                                   //         width: 3.0)),
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
                                 child: (isWeb())?Column(

                                   children: [
                                     Padding(
                                       padding:  EdgeInsets.only(top: 50),
                                       child: Container(
                                         child: (isWeb())?getPay(context):
                                                Container(),

                                       ),
                                     ),
                                     Expanded(child: Container())                                    ],
                                 ):Container(),

                               )
                             ],
                           ),
                         ),
                         constraints: BoxConstraints(
                             maxHeight: 3*height
                         ),
                       ),
                     ],
                   ),
                 ),
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
              ),
            );}
          else
            {return Loader();}
            })
        : Loader();
  }


  List<int> getFlex()
  { List<int> x= List<int>();
  if(!isWeb())
    //if (width<600)
      {x=[1,0];
  }
  else
  {x=[1,1];

  }


  return x;
  }

  List<Widget> getList() {
    List<Widget> w = List<Widget>();
    w.add(SizedBox(
      height: 10,
    ));
    w.add(getSearchBar());
    w.add(SizedBox(
      height: 10,
    ));
    for (Employee s in employeeList) {
      if (searchList == null || searchList.contains(s.name))
        w.add(GestureDetector(
          onTap: () {
            if(isWeb())
              { setState(() {
                // print("llll");
                name = s.name;
              });}

            else
              { Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => mobilePayment(attendanceMap, employeeList, month, s.name)),
              );



              }

          },
          child: ListTile(
            tileColor: Colors.orange,
            title: Text(s.name),
            leading: Icon(Icons.person),
            trailing: (attendanceMap[s.name][month]["PAID"]??false)== true
                ? Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                : Text(""),
          ),
        ));

      w.add(SizedBox(
        height: 10,
      ));
    }

    return w;
  }

  Widget getPay(context) {
    print("name:$name");
    Employee e = getEmp(name ?? employeeList[0].name, employeeList);

    double attendanceDays = getAttendance(e.name, attendanceMap, month);

    double OTHours = getOT(e.name, attendanceMap, month);

    double wages = getWages(attendanceDays, e.wage);

    double OT = OTHours * double.parse(e.overTime);

    double allowance = getAllowance(e.allowance, attendanceDays,count);

    double Total = double.parse((wages + OT + allowance).toStringAsFixed(0));

    double PF = getPf(wages,e.isPF);

    double ESI=getEsi(Total,PF,e.isESI);

    double netTotal = (Total - PF - ESI).floorToDouble();
    int Rounded = roundToTens(netTotal.round());

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
                        if (val == "") return "Empty !!";
                        try {
                          // ignore: missing_return
                          double b = double.parse(val);
                          if (b <= double.parse("${e.advance}"))
                            setState(() {});
                          else
                            return "Enter  a Valid number ";
                        } catch (a) {
                          return "Enter  a Valid number ";
                        }
                      },
                      textAlign: TextAlign.center,
                      controller: adController,
                      style: payStyle,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [DecimalNumberFormatter()],
                      onEditingComplete: () {
                        if (_formKey.currentState.validate()) setState(() {});
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
            "Amount to be paid :  ${netTotal - (adController.text == "" ? (double.parse("${e.advance}")>=0?double.parse("${e.advance}"):"0") : double.parse(adController.text))}",
            style: payStyle),
        getDiv(),
        ElevatedButton.icon(
          icon: getPayIcon(attendanceMap[name ?? employeeList[0].name][month]["PAID"]?? false),
          label: Text(
              (attendanceMap[name ?? employeeList[0].name][month]["PAID"]??false)  == true ? "Unpay" : "Pay"),
          style: ElevatedButton.styleFrom(
            primary:
                getPayColor(attendanceMap[name ?? employeeList[0].name][month]["PAID"]?? false),
          ),

          onPressed: () async {
            if (_formKey.currentState.validate()) {
              if (name != null)
                { bool b =attendanceMap[name][month]["PAID"];
                if(b==null)
                  b=true;
                else
                  b=!b;
                attendanceMap[name][month]["PAID"]= b??true;
                attendanceMap[name][month]["ADVANCE"]=adController.text;
                await attendanceService.updateStaffData(name, attendanceMap[name]);

                }

              else
                {bool b =attendanceMap[employeeList[0].name][month]["PAID"];
                if(b==null)
                  b=true;
                else
                  b=!b;
                attendanceMap[employeeList[0].name][month]["PAID"]=b??true;
                attendanceMap[employeeList[0].name][month]["ADVANCE"]=adController.text;
                await attendanceService.updateStaffData(employeeList[0].name, attendanceMap[employeeList[0].name]);

                }

              setState(() {});
            } else {
              ///show snacks
              ///
            }
          },
        )
      ],
    );
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
        searchList = List<String>();
        for (Employee k in employeeList) {
          if (k.name.toLowerCase().startsWith(val.toLowerCase()))
            searchList.add(k.name);
        }


        setState(() {});
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