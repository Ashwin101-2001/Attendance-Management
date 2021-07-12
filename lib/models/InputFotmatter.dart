import 'package:flutter/services.dart';

class CustomInputFormatter extends TextInputFormatter {
  int x;
  CustomInputFormatter(this.x);
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


class CustomInputFormatter1 extends TextInputFormatter {
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



