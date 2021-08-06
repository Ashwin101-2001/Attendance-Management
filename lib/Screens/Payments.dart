import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:varnam_attendance/Constants/PaymentConstants.dart';
import 'package:varnam_attendance/Constants/addEmployeeConstants.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
import 'package:varnam_attendance/Firebase/attendanceDatabase.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/models/InputFotmatter.dart';
import 'package:varnam_attendance/utilities/Loading.dart';
import 'package:varnam_attendance/utilities/functions.dart';

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
  List<Employee> employeeList = List<Employee>();
  DatabaseListService listService = DatabaseListService();
  DatabaseAttendanceService attendanceService = DatabaseAttendanceService();
  final _formKey = GlobalKey<FormState>();

  List<String> searchList;
  String month;
  bool loading = true;
  Map<String, bool> paidMap;
  String val1;

  @override
  void initState() {
    // TODO: implement initState
    print('init');
    super.initState();
    paidMap = Map<String, bool>();
    DateTime now = DateTime.now();
    month = "${getaddedzero(now.month)}-${now.year}";

    init();
  }


  void init() async {
    //await Firebase.initializeApp();
    attendanceMap = await attendanceService.getAttendanceCollection();
    employeeList = await listService.getEmployeeList();
    print(attendanceMap.toString());
    for (Employee e in employeeList) {
      print(e.name);
    }
    print('init2');
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return loading != true ? Scaffold(
      appBar: AppBar(
        title: Text("Payments"),
      ),
      body: Container(
        padding: EdgeInsets.all(50),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.pink,
                        width: 2.0
                    )
                ),
                padding: EdgeInsets.all(20),
                child: ListView(
                  children: getList(),
                ),
              ),

            ),
            Expanded(
              flex: 1,
              //child:Text("a"),
              child: getPay(context),
            ),
          ],
        ),
      ),
    ) : Loader();
  }

  List<Widget> getList() {
    List<Widget> w = List<Widget>();
    w.add(getSearchBar());
    w.add(SizedBox(height: 10,));
    for (Employee s in employeeList) {
      if (searchList == null || searchList.contains(s.name))
        w.add(GestureDetector(
          onTap: () {
            setState(() {
              name = s.name;
            });
          },
          child: ListTile(
            tileColor: Colors.orange,
            title: Text(s.name),
            leading: Icon(Icons.person),
            trailing: paidMap[s.name] == true ? Icon(
              Icons.check, color: Colors.green,) : Text(""),
          ),
        ));

      w.add(SizedBox(height: 10,));
    }


    return w;
  }

  Widget getPay(context) {
    Employee e = getEmp(name ?? employeeList[1].name, employeeList);
    print("working");
    double attendanceDays = getAttendance(e.name, attendanceMap, month);
    print("working");
    double OTHours = getOT(e.name, attendanceMap, month);
    print("working");
    double wages = getWages(attendanceDays, e.wage);
    print("working");
    double OT = OTHours * double.parse(e.overTime);
    print("working");
    double allowance = getAllowance(e.allowance, attendanceDays);
    print("working");
    double Total = double.parse((wages + OT + allowance).toStringAsFixed(0));
    // print("${}")
    //Total=Total.floorToDouble();
    double PF = getPf(wages);
    print("working");
    double ESI = getEsi(Total);
    print("working");
    double netTotal = (Total - PF - ESI).floorToDouble();
    int Rounded = roundToTens(netTotal.round());



    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
      /*   Text("         Wages :  $wages"),
        getDiv(),
        Text("+        OverTime :  $OT"),
        getDiv(),
        Text("+        Allowance :  $allowance"),
        getDiv(), */
      Text("Salary for $month ", style: payStyle1,),
      getDiv(),
      Text("Name : ${name??employeeList[1].name} ",style: payStyle),
      getDiv(),

      Text("Total :  $netTotal",style: payStyle),
      getDiv(),
        Text("Advance :  ${e.advance}",style: payStyle),
      getDiv(),
      Container(
        margin:EdgeInsets.fromLTRB(150, 0, 100, 0),
      child: Row(
      children: [ Text("Advance Deduction:  ",style: payStyle),
      Container(
      width:100,
      child: Form(
        key: _formKey,
      child: TextFormField(
        validator: (val){
         try{
           // ignore: missing_return
           double b=double.parse(val);
           if(b<=double.parse("${e.advance}"))
             setState(() {

             });
           else
             return "Enter  a Valid number ";
         }
         catch(a){
           return "Enter  a Valid number ";
         }

        },
        textAlign: TextAlign.center,
      controller: adController,
      style: payStyle,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
       inputFormatters: [DecimalNumberFormatter()],
       onEditingComplete: () {
         if(_formKey.currentState.validate())
       setState(() {

       });
    },
    decoration: InputDecoration(
      // suffixIcon: adController.text != ""
      //     ? IconButton(
      //   icon: Icon(
      //     Icons.cancel_outlined,
      //     color: Colors.pink,
      //     size: 18.0,
      //   ),
      //   onPressed: () {
      //     setState(() {
      //       adController.text = "";
      //     });
      //   },
      // )
      //     : null,

    focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(
    color: Colors.pink,
    width: focusedBorderWidth1),
    ),
    enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(
    color:Colors.pink,
    width: enabledBorderWidth1),
    ),
    ),
    ),
    ),
    )


    ],
    )
    ),
        getDiv(),

    Text("Amount to be paid :  ${netTotal-(adController.text==""?double.parse("${e.advance}"):double.parse(adController.text))}",style: payStyle),
    getDiv(),
    ElevatedButton.icon(
    icon: getPayIcon(paidMap[name??employeeList[1].name]??false),
    label: Text(paidMap[name??employeeList[1].name]==true?"Unpay":"Pay"),
    style: ElevatedButton.styleFrom(
    primary:getPayColor(paidMap[name??employeeList[1].name]??false),),

    onPressed: ()
    { if(adController.text!="")
      {if(name!=null)
        paidMap[name]=paidMap[name]!=null?(!paidMap[name]):true;
      else
        paidMap[employeeList[1].name]=paidMap[employeeList[1].name]!=null?(!paidMap[employeeList[1].name]):true;
      setState(() {

      });}



    },
    )
    ]
    ,
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
          if (k.name.startsWith(val))
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