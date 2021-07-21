import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Constants/viewConstants.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
import 'package:varnam_attendance/Screens/AddEmployee.dart';
import 'package:varnam_attendance/Screens/MarkAttendance.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/utilities/Loading.dart';
import 'package:varnam_attendance/utilities/screens_size.dart';
  class viewEmployee extends StatefulWidget {
  @override
  _viewEmployeeState createState() => _viewEmployeeState();
}

class _viewEmployeeState extends State<viewEmployee> {
  List<Employee> eList;
  List<Employee> eList1;
  bool loading;
  bool side;
  double width;
  double height;
  final _formKey = GlobalKey<FormState>();
  TextEditingController sController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("view init");
    loading = true;
    side = false;
    init();
  }
  void init() async {
    await Firebase.initializeApp();
    eList = await DatabaseListService().getEmployeeList();
    eList1=eList;
    setState(() {
      loading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    width = Responsive.width(100, context);
    height = Responsive.width(100, context);

    return LayoutBuilder(
        builder: (context,contraint)
        {return loading!=true?Scaffold(
          appBar: AppBar(
            title: Center(child: Text('Employee list')),
            leading:  FlatButton.icon(
            label:Text(''),
            icon: Icon(Icons.menu,size: 20,),
            onPressed:()
            {
              setState(() {
                side=!side;
              });

            },
          ),

          ),


          body: Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      width: contraint.maxWidth >= 480
                          ? contraint.maxWidth / 3
                          : contraint.maxWidth,
                      child: ListView(
                        children: getList(),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child:  Container(),
                  )
                ],
              ),
              /**/

              getOptionsStack(),
          ],
          ),
        ):Loader();}
    );
  }



  Widget getOptionsStack()
  {  return side==true? Container(
    color: Colors.pinkAccent[100],
      width:width/4,
    child: ListView(
      children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => addEmployee()),
                    );
                  },
                  child: ListTile(
                    title: Text("Add Staff"),
                    leading: Icon(Icons.add),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => markAttendance()),
                    );
                  },
                  child: ListTile(
                    title: Text("Attendance"),
                    leading: Icon(Icons.thumb_up_alt_outlined),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => addEmployee()),
                    );
                  },
                  child: ListTile(
                    title: Text("Payment"),
                    leading: Icon(Icons.monetization_on_outlined),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => addEmployee()),
                    );
                  },
                  child: ListTile(
                    title: Text("Get Excel/CSV"),
                    leading: Icon(Icons.file_download),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => addEmployee()),
                    );
                  },
                  child: ListTile(
                    title: Text("Settings"),
                    leading: Icon(Icons.settings),
                  ),
                ),
              ],
            ),





  ):Container();



  }



  List<Widget> getList() {
    List<Widget> a = List<Widget>();

    a.add(Container(
      padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 5.0, bottom: 5.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 1.0),
      ),
      child: Form(
        key: _formKey,
        child: getSearch(),
      ),
    ));
    for (Employee e in eList1) {
      a.add(ListTile(
        tileColor: Colors.green,
        title: Text(e.name),
        leading: Icon(Icons.person),
      ));
      a.add(SizedBox(
        height: 10.0,
      ))  ;  }

    return a;
  }

  Widget getSearch()
  {
    return TextFormField(
      controller: sController,
      style: textFormVStyle,
      keyboardType: TextInputType.text,

      onChanged: (val)
      {
        if (val != "") {
            eList1=List<Employee>();
          for (Employee e in eList) {
            if (e.name.toLowerCase().startsWith(val.toLowerCase())) eList1.add(e);
          }
        } else
          eList1 = eList;

        setState(() {});
      },
      decoration: InputDecoration(
        suffixIcon:  sController.text!=""?IconButton(
          icon: Icon(Icons.cancel_outlined,color: Colors.green,size: 18.0,),
          onPressed: () {
            eList1 = eList;
            setState(() {
              sController.text = " ";
            });
          },
        ):null,
        labelText: "Search ",
        labelStyle: labelVStyle,
        hintText: "Search for Employee",
        hintStyle: hintVStyle,
        focusedBorder:OutlineInputBorder(
          borderSide: BorderSide(color: focusedVBorderColor, width: focusedVBorderWidth),
        ),

        /* enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: enabledBorderColor, width: enabledBorderWidth1),
        ),*/
      ),
    );
  }
}
