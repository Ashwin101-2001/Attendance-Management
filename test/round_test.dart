

import 'package:flutter_test/flutter_test.dart';
import 'package:varnam_attendance/utilities/functions.dart';

void main()
{ test(
  "test it",
    (){
    double initial=65989.9;
    int finalv = roundToTens(initial.round());
        expect(finalv,65990);




    }
);



}