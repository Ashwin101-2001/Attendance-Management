import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Constants/viewConstants.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
import 'package:varnam_attendance/Screens/AddEmployee.dart';
import 'package:varnam_attendance/Screens/CsvDownload.dart';
import 'package:varnam_attendance/Screens/MarkAttendance.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/utilities/Loading.dart';
import 'package:varnam_attendance/utilities/screens_size.dart';

import 'Payments.dart';

class viewEmployee extends StatefulWidget {
  @override
  _viewEmployeeState createState() => _viewEmployeeState();
}

class _viewEmployeeState extends State<viewEmployee> {
  List<Employee> eList;
  List<Employee> eList1;
  bool loading;
  //bool side;
  double width;
  double height;
  Widget myWidget;
  final _formKey = GlobalKey<FormState>();
  TextEditingController sController = new TextEditingController();
  ScrollController s=new ScrollController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("view init");
    loading = true;
    //side = false;
    myWidget=getOp2();
    init();
  }

  void init() async {
    await Firebase.initializeApp();
    eList = await DatabaseListService().getEmployeeList();
    eList1 = eList;
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = Responsive.width(100, context);
    height = Responsive.width(100, context);

    return LayoutBuilder(
        builder: (context, contraint) {

          return loading != true ? Scaffold(
            backgroundColor: scafColor1,
            appBar: AppBar(
              title: Center(child: Text('Employee list')),
              leading: FlatButton.icon(
                label: Text(''),
                icon: Icon(Icons.menu, size: 20,),
                onPressed: () {
                  setState(() {
                   // side = !side;
                    myWidget=myWidget.key==ValueKey(2)?getOp2():getOptionsStack();

                  });
                },
              ),

            ),


            body: Container(

              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                       Align(
                         alignment: Alignment.topLeft,
                         child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 350),
                              child: myWidget,
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return FadeTransition(child: child, opacity: animation,);
                              },
                            ),
                       ),

                        Expanded(
                          child: Container(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                          width:contraint.maxWidth >= 480 ? contraint.maxWidth / 3
                              : contraint.maxWidth,
                          //
                          child: DraggableScrollbar.rrect(
                            controller: s,
                             alwaysVisibleScrollThumb: true,
                              heightScrollThumb: height/30,
                              //scrollbarAnimationDuration: Duration(milliseconds: 500),
                              backgroundColor: Colors.pink,
                            child: ListView(
                              controller: s,
                              children: getList(),
                            ),
                          ),
                      ),
                        ),],

                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(//color: Colors.red,
                       ),
                  )
                ],
              ),
            ),
          ) : Loader();
        }
    );
  }




  Widget getOptionsStack() {

    return  Container(
      key: ValueKey(2),
      color: Colors.white,
      width: width / 4,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => addEmployee()),
              );
            },
            child: ListTile(
              title: Text("Add Staff",style:leftStyle),
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
              title: Text("Attendance",style:leftStyle),
              leading: Icon(Icons.thumb_up_alt_outlined),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Payments()),
              );

            },
            child: ListTile(
              title: Text("Payment",style:leftStyle),
              leading: Icon(Icons.monetization_on_outlined),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => csvDownloader()),
              );
            },
            child: ListTile(
              title: Text("Get Excel/CSV",style:leftStyle),
              leading: Icon(Icons.file_download),
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => addEmployee()),
          //     );
          //   },
          //   child: ListTile(
          //     title: Text("Settings",style:leftStyle),
          //     leading: Icon(Icons.settings),
          //   ),
          // ),
        ],
      ),


    );
  }

  Widget getOp2() {
    return Container(
      alignment: AlignmentDirectional.topStart,
      padding: EdgeInsets.all(5),
      key: ValueKey(1),
      color: Colors.white,
      width: 80,
      child: Column(
        children: [
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => addEmployee()),
                );
              },

              child: Column(
                children: [
                  Icon(Icons.add, size: leftIconSize),
                  Text("Add Staff",style:leftStyle),
                ],
              )
          ),
          SizedBox(height: boxHeight,),
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => markAttendance()),
                );
              },
              child:
              Column(
                children: [
                  Icon(Icons.thumb_up_alt_outlined, size: leftIconSize,),
                  Text("Attendance",style:leftStyle),
                ],
              )

          ),
          SizedBox(height: boxHeight,),
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Payments()),
                );
              },
              child:
              Column(
                children: [
                  Icon(Icons.monetization_on_outlined, size: leftIconSize,),
                  Text("Payment",style:leftStyle),
                ],
              )


          ),
          SizedBox(height: boxHeight),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => csvDownloader()),
              );
            },
            child: Column(
              children: [
                Icon(Icons.file_download, size: leftIconSize,),
                Text("Excel",style:leftStyle),
              ],
            ),),
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
          //       Icon(Icons.settings, size: leftIconSize,),
          //       Text("Settings",style:leftStyle),
          //     ],
          //   ),),

        ],
      ),


    );
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
        child: getSearchBar(),
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
      ));
    }

    return a;
  }

  Widget getSearchBar() {
    return TextFormField(
      controller: sController,
      style: textFormVStyle,
      keyboardType: TextInputType.text,

      onChanged: (val) {
        if (val != "") {
          eList1 = List<Employee>();
          for (Employee e in eList) {
            if (e.name.toLowerCase().startsWith(val.toLowerCase())) eList1.add(
                e);
          }
        } else
          eList1 = eList;

        setState(() {});
      },
      decoration: InputDecoration(
        suffixIcon: sController.text != "" ? IconButton(
          icon: Icon(Icons.cancel_outlined, color: Colors.green, size: 18.0,),
          onPressed: () {
            eList1 = eList;
            setState(() {
              sController.text = " ";
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
}
