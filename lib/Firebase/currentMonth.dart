
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:varnam_attendance/models/Employee.dart';


class DatabaseService {

  final String uid;

  DatabaseService({ this.uid });

  // collection reference
  final CollectionReference brewCollection = FirebaseFirestore.instance
      .collection('brews');

  Future<void> updateUserData(String id,Map<String,dynamic> map ) async {
    bool x = await Check(id);
    if(x)
    await brewCollection.doc(id).update(map);
    else
      await brewCollection.doc(id).set(map);

  }
  Future<void> setUserData(String id,Map<String,dynamic> map ) async {

  }


  Future<bool> Check(String id) async {
    print("a");
    QuerySnapshot x=await brewCollection.get();
    List<Employee> list = List<Employee>();
    print("a");

    for (DocumentSnapshot a in x.docs) {
      if(a.id==id)
        return true;
    }

     return false;
  }





}