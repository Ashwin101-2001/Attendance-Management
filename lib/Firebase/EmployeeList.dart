
 import 'dart:async';

import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
   import 'dart:async';

import 'package:varnam_attendance/models/Employee.dart';

class DatabaseListService {

  final String uid;

  DatabaseListService({ this.uid });

  // collection reference
  final CollectionReference Employees= FirebaseFirestore.instance.collection('Staff details');

  void updateStaffData(String id, Map<String, dynamic> map) async {  //Do not call update on new documents
    await Employees.doc(id).update(map);
  }

  void insertUserData(String name, Map<String, dynamic> map) async {
    await Employees.doc(name).set(map);
  }

  void deleteUserData(String id) async {
    await Employees.doc(id).delete();
  }

  Future<List<Employee>> getEmployeeList() async {
    print("a");
    QuerySnapshot x=await Employees.get();
    List<Employee> list = List<Employee>();
    print("a");

      for (DocumentSnapshot a in x.docs) {
        list.add(Employee.fromMapObject(a.data()));
      }

    return list;
  }
 DocumentReference getDoc(String id)
  {  DocumentReference d= Employees.doc(id);
      return d;

  }
}


