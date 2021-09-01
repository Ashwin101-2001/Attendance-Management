import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:varnam_attendance/Constants/markAttendanceConstants.dart';
import 'package:varnam_attendance/Constants/viewConstants.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
import 'package:varnam_attendance/Firebase/attendanceDatabase.dart';
import 'package:varnam_attendance/Screens/AddEmployee.dart';
import 'package:varnam_attendance/Screens/CsvDownload.dart';
import 'package:varnam_attendance/Screens/MarkAttendance.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/utilities/Loading.dart';
import 'package:varnam_attendance/utilities/screens_size.dart';
import 'package:varnam_attendance/utilities/functions.dart';

import 'Payments.dart';
import 'package:flutter/foundation.dart';

class viewEmployee extends StatefulWidget {
  @override
  _viewEmployeeState createState() => _viewEmployeeState();
}

class _viewEmployeeState extends State<viewEmployee> {
  List<Employee> eList;
  List<Employee> eSearchList;
  bool loading;
  //bool side;
  double width;
  double height;
  Widget myWidget;
  final _formKey = GlobalKey<FormState>();
  TextEditingController sController = new TextEditingController();
  ScrollController s=new ScrollController();
  DatabaseListService databaseListService;
  DatabaseAttendanceService databaseAttendanceService;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("view init");
    loading = true;

    myWidget=getOp2();
    init();
  }

  void init() async {
    await Firebase.initializeApp();
    databaseListService=DatabaseListService();
    databaseAttendanceService=DatabaseAttendanceService();
    eList = await databaseListService.getEmployeeList();
    eSearchList = eList;
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    width = Responsive.width(100, context);
    height = Responsive.width(100, context);
    // print("width:$width  :: height: $height");


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


            body: Scrollbar(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: height/4,
                    maxHeight: 4*height
                  ),

                  child: Container(
                    child: Row(
                      children: [
                        Expanded(
                          flex: getFlex()[0],
                          child: Row(
                            children: [
                              ///
                             Align(
                               alignment: Alignment.topLeft,
                               child: Container(
                                 height: height,
                                 child: AnimatedSwitcher(
                                      duration: Duration(milliseconds: 350),
                                      child: myWidget,
                                      transitionBuilder:
                                          (Widget child, Animation<double> animation) {
                                        return FadeTransition(child: child, opacity: animation,);
                                      },
                                    ),
                               ),
                             ),

                              Expanded(
                                child: Container(
                                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                                width:contraint.maxWidth >= 480 ? contraint.maxWidth / 3
                                    : contraint.maxWidth,
                                //
                                child: Column(
                                  children: getList(),
                                ),
                            ),
                              ),],

                          ),
                        ),
                        Expanded(
                          flex: getFlex()[1],
                          child: Container(
                             ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ) : Loader();
        }
    );
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


  Widget getOptionsStack() {
    if(!isWeb())
   {return Container(
     key: ValueKey(2),
   );
   }
    return  Container(
      color:menuColor,
      key: ValueKey(2),
      //color: Colors.white,
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
              leading: Icon(Icons.add,color: iconColor),
            ),
          ),
          getDiv(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => markAttendance()),
              );
            },
            child: ListTile(
              title: Text("Attendance",style:leftStyle),
              leading: Icon(Icons.thumb_up_alt_outlined,color: iconColor),
            ),
          ),
          getDiv(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Payments()),
              );

            },
            child: ListTile(
              title: Text("Payment",style:leftStyle),
              leading: Icon(Icons.monetization_on_outlined,color: iconColor),
            ),
          ),
          getDiv(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => csvDownloader()),
              );
            },
            child: ListTile(
              title: Text("Get Excel/CSV",style:leftStyle),
              leading: Icon(Icons.file_download,color: iconColor),
            ),
          ),
          getDiv(),
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
      color:menuColor,
      alignment: AlignmentDirectional.topStart,
      padding: EdgeInsets.all(5),
      key: ValueKey(1),
      //color: Colors.white,
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
                  Icon(Icons.add, size: leftIconSize,color: iconColor),
                  Text("Add Staff",style:leftStyle),
                ],
              )
          ),
         getDiv(),
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
                  Icon(Icons.thumb_up_alt_outlined, size: leftIconSize,color: iconColor),
                  Text("Attendance",style:leftStyle),
                ],
              )

          ),
         getDiv(),
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
                  Icon(Icons.monetization_on_outlined, size: leftIconSize,color: iconColor),
                  Text("Payment",style:leftStyle),
                ],
              )


          ),
         getDiv(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => csvDownloader()),
              );
            },
            child: Column(
              children: [
                Icon(Icons.file_download, size: leftIconSize,color: iconColor),
                Text("Excel",style:leftStyle),
              ],
            ),),
          getDiv(),
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
        { Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => addEmployee(e.name)),
        );



        },
        child: ListTile(
          tileColor: tileColor,
          title: Text(getName(e.name),style: tileStyle,),
          leading: Icon(Icons.person,color: personIconColor,),
          trailing: ElevatedButton.icon(
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

          ),
        ),
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
          icon: Icon(Icons.cancel_outlined, color: Colors.green, size: 18.0,),
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
  String getName(name)
  {  List<String> s= name.split(" ");
   int i=0;
     name="";
    while(i<s.length)
      { name+= s[i][0].toUpperCase()+s[i].substring(1).toLowerCase();
        i++;
      }
      return name;
  }


  Widget getDiv() {
    return Divider(
      height: 25,
      color: Colors.black,
      thickness: 1,
      // endIndent: 100,
      // indent: 100,
    );
  }
}
