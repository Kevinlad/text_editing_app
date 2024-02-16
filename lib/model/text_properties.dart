import 'package:flutter/material.dart';

class TextProperties {
  String text;
  Offset position;
  String fontFamily;
  double fontSize;
  Color fontColor;

  TextProperties({
    required this.text,
    required this.position,
    required this.fontFamily,
    required this.fontSize,
    required this.fontColor,
  });
  TextProperties clone() {
    return TextProperties(
      text: this.text,
      position: Offset(this.position.dx, this.position.dy),
      fontFamily: this.fontFamily,
      fontSize: this.fontSize,
      fontColor: this.fontColor,
    );
  }
}
