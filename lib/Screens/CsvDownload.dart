import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:varnam_attendance/Constants/CsvDownloadConstants.dart';
import 'package:varnam_attendance/Firebase/EmployeeList.dart';
import 'package:varnam_attendance/Firebase/attendanceDatabase.dart';
import 'package:varnam_attendance/Screens/MarkAttendance.dart';
import 'package:varnam_attendance/models/Employee.dart';
import 'package:varnam_attendance/utilities/functions.dart';
import 'package:varnam_attendance/utilities/screens_size.dart';

class csvDownloader extends StatefulWidget {
  @override
  _csvDownloaderState createState() => _csvDownloaderState();
}

class _csvDownloaderState extends State<csvDownloader> {
  CalendarController _controller=  CalendarController();
  DateTime date1;

  double width;
  double height;
  bool loading=true;
  Map<String, Map<String, dynamic>> attendanceMap;
  List<Employee> employeeList;
  DatabaseListService listService=DatabaseListService();
  DatabaseAttendanceService attendanceService=DatabaseAttendanceService();
  String month;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    date1=DateTime.now();
    init();
    setState(() {
      loading=false;
    });
  }

  void init() async{
    attendanceMap= await attendanceService.getAttendanceCollection();
    employeeList=await listService.getEmployeeList();
    print(attendanceMap.toString());




  }
  @override
  Widget build(BuildContext context) {
    width = Responsive.width(100, context);
    height = Responsive.width(100, context);
    return Scaffold(
      appBar: AppBar(
        title:Text('Export CSV'),
      ),
      body:SingleChildScrollView(
        child: Center(
          child: Container(
            margin: EdgeInsets.only(top:width/20),
            width: width/2,
            height: height*3/4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TableCalendar(
                  initialCalendarFormat: CalendarFormat.month,
                  calendarStyle: CalendarStyle(
                      todayColor: Colors.orange,
                      selectedColor: Theme.of(context).primaryColor,
                      todayStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.white)),
                  headerStyle: HeaderStyle(
                    centerHeaderTitle: true,
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    formatButtonTextStyle: TextStyle(color: Colors.white),
                    formatButtonShowsNext: false,
                  ),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  onDaySelected: (date,_,a){
                    setState(() {
                      date1=date;
                    });
                  },
                  builders: CalendarBuilders(
                    selectedDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: TextButton(
                         child:Text(date.day.toString(),
                           style: TextStyle(color: Colors.white),) ,
                          onPressed: ()
                          {  Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => markAttendance(date)),
                          );


                          },
                        )),
                    todayDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  calendarController: _controller,
                ),
                Center(
                  child: TextButton(
                    child:  RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:  "Download Excel file",
                            style: downloadStyle
                          ),
                          WidgetSpan(
                            child: Icon(Icons.file_download,color: iconColor,),
                          ),

                        ],
                      ),
                    ),
                    onPressed: () async
                    { List<List<dynamic>> list1=List<List<dynamic>>();
                       list1.add(d1);
                      for (Employee e in employeeList) {
                        list1.add(getRow(e.name));
                      }
                    String csv = const ListToCsvConverter().convert(list1);
                    print(csv);
                    final content = base64Encode(csv.codeUnits);
                    final url = 'data:application/vnd.ms-excel;base64,$content';
                    await launch(url);

                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  List<dynamic> getRow(String name)
  {  List<dynamic> list=List<dynamic>();
     month = "${getaddedzero(date1.month)}-${date1.year}";
    ///Assigning values
    Employee e=getEmp(name,employeeList );
     double attendanceDays =getAttendance(name,attendanceMap,month);
     double OTHours=getOT(name,attendanceMap,month);
     double wages=getWages(attendanceDays,e.wage) ;
     double OT=OTHours*double.parse(e.overTime);
     double allowance=getAllowance(e.allowance,attendanceDays);
      double Total=wages+OT+allowance;
     double PF= getPf(wages);
     double ESI=getEsi(Total);
     double netTotal=Total-PF-ESI;
     int Rounded=roundToTens(netTotal.round());


     /// Adding to list
    list.add(e.name);
    list.add(attendanceDays);  //hrs
    list.add(e.wage.substring(1));
    list.add(OTHours);  //hrs
    list.add(e.overTime);
    list.add(wages); //wages of month
    list.add(OT);
    list.add(allowance); //allowance
    list.add(Total);
    list.add(e.advance);
    list.add(PF);
    list.add(ESI);
    list.add(netTotal);
    list.add(Rounded);
    list.add(0);
    list.add(0);


    return list;








  }

}





 const List<dynamic> d1=[
   "Name",
   "Working days",
   "Wage/day",
   "OT hours",
   "OT/hour",
   "Wages",
   "OT",
   "Allowance",
   "Total",
   "Advance",
   "PF",
   "ESI",
   "Total",
   "Rounded Total",
   "Transfer",
   "Cash paid"

 ];
Employee getEmp(String name, List<Employee> l) {
  for (Employee e in l) {
    if (e.name == name) return e;
  }
}