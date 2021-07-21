
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:varnam_attendance/models/Employee.dart';


class DatabaseAttendanceService {

  //final String uid;

  DatabaseAttendanceService();

  // collection reference
  final CollectionReference brewCollection = FirebaseFirestore.instance
      .collection('Attendance');

  Future<void> updateStaffData(String id,Map<String,dynamic> map ) async {
    bool x = await Check(id);
    if(x)
    await brewCollection.doc(id).update(map);
    else
      await brewCollection.doc(id).set(map);

  }
  Future<void> setStaffData(String id,Map<String,dynamic> map ) async {
    await brewCollection.doc(id).set(map);
  }


  Future<bool> Check(String id) async {
    print("a");
    QuerySnapshot x=await brewCollection.get();
    print("a");

    for (DocumentSnapshot a in x.docs) {
      if(a.id==id)
        return true;
    }

     return false;
  }

  Map<String,Map<String,dynamic>> mapFromQuery(QuerySnapshot x)
  {  Map<String,Map<String,dynamic>> y=  Map<String,Map<String,dynamic>>();
    for(QueryDocumentSnapshot d in x.docs)
    {  y[d.id]=d.data();
    }
    return y;
  }








  Stream<Map<String,Map<String,dynamic>>> get stream {
    return brewCollection.snapshots().map(mapFromQuery);
  }



}