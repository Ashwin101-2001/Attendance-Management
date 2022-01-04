import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpaceFormatter extends TextInputFormatter {
  int x;
  SpaceFormatter(this.x);
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex %(this.x) == 0 && nonZeroIndex != text.length) {
        buffer.write(' '); // Replace this with anything you want to put after each 4 numbers
      }
    }

    var string = buffer.toString();

    return newValue.copyWith(
        text: string,
        selection: new TextSelection.collapsed(offset: string.length)
    );
  }
}


class RsFormatter extends TextInputFormatter {
  int x;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }


    return newValue.copyWith(
        text: "Rs "+text,
        selection: new TextSelection.collapsed(offset: text.length+3)
    );
  }
}


class DecimalNumberFormatter extends TextInputFormatter {


  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    var text1="";

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

     int i=0;
    while (i < text.length) {
      // if(!((text[i].contains(new RegExp(r'[A-Z]'))||text[i].contains(new RegExp(r'[a-z]')))))
      if (text[i].contains(new RegExp(r'[0-9]'))) {
        text1 += text[i];

      } else if (text[i] == ".") {
        if (!text.substring(0, i).contains(".")) {
          text1 += text[i];

        }
      }
      i++;
    }
    return newValue.copyWith(
        text: text1,
        selection: new TextSelection.collapsed(offset: text1.length)
    );
  }
}


class IntegerFormatter extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    var text1="";

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    int i=0;
    while (i < text.length) {
      if (text[i].contains(new RegExp(r'[0-9]'))) {
        text1 += text[i];

      }
      i++;
    }
    return newValue.copyWith(
        text: text1,
        selection: new TextSelection.collapsed(offset: text1.length)
    );
  }
}


