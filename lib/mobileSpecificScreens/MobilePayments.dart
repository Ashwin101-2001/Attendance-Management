import 'package:flutter/material.dart';
import 'package:varnam_attendance/Constants/Overall%20constants.dart';
import 'package:varnam_attendance/Constants/PaymentConstants.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Firebase/attendanceDatabase.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/models/InputFotmatter.dart';
import 'package:varnam_attendance/utilities/functions.dart';
class mobilePayment extends StatefulWidget {
  var attendanceMap;
  var employeeList;
  String name;
  String month;
  mobilePayment(this.attendanceMap,this.employeeList,this.month,this.name);
  @override
  _mobilePaymentState createState() => _mobilePaymentState(attendanceMap,employeeList,month,name);
}

class _mobilePaymentState extends State<mobilePayment> {
  var attendanceMap;
  var employeeList;
  String name;
  String month;
  final _formKey = GlobalKey<FormState>();
  TextEditingController adController = new TextEditingController();
  DatabaseAttendanceService attendanceService = DatabaseAttendanceService();
  _mobilePaymentState(this.attendanceMap,this.employeeList,this.month,this.name);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          child: getPay(context),
        ),
      ),

    );
  }


  Widget getPay(context) {
    String s=attendanceMap[general][month][PL];
    int count= s.substring(0,s.length-1).split(",").length;

    Employee e = getEmp(name ?? employeeList[0].name, employeeList);

    double attendanceDays = getAttendance(e.name, attendanceMap, month);

    double OTHours = getOT(e.name, attendanceMap, month);

    double wages = getWages(attendanceDays, e.wage);

    double OT = OTHours * double.parse(e.overTime);

    double allowance = getAllowance(e.allowance, attendanceDays,count);

    double Total = double.parse((wages + OT + allowance).toStringAsFixed(0));

    double PF = getPf(wages,e.isPF);

    double ESI=getEsi(wages,PF,e.isESI);

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
            margin: isWeb()?EdgeInsets.fromLTRB(150, 0, 100, 0):
            EdgeInsets.fromLTRB(70, 50, 50, 0),
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
          icon: getPayIcon(attendanceMap[name ?? employeeList[0].name][month][paidKey]?? false),
          label: Text(
              (attendanceMap[name ?? employeeList[0].name][month][paidKey]??false)  == true ? "Unpay" : "Pay"),
          style: ElevatedButton.styleFrom(
            primary:
            getPayColor(attendanceMap[name ?? employeeList[0].name][month][paidKey]?? false),
          ),

          onPressed: () async {
            if (_formKey.currentState.validate()) {
              if (name != null)
              { bool b =attendanceMap[name][month][paidKey];
              if(b==null)
                b=true;
              else
                b=!b;
              attendanceMap[name][month][paidKey]= b??true;
              attendanceMap[name][month][advKey]=adController.text;
              await attendanceService.updateStaffData(name, attendanceMap[name]);

              }

              else
              {bool b =attendanceMap[employeeList[0].name][month][paidKey];
              if(b==null)
                b=true;
              else
                b=!b;
              attendanceMap[employeeList[0].name][month][paidKey]=b??true;
              attendanceMap[employeeList[0].name][month][advKey]=adController.text;
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