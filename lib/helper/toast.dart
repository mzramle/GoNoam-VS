import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast({
  required String message,
  ToastGravity gravity = ToastGravity.BOTTOM,
  Toast toastLength = Toast.LENGTH_SHORT,
  Color backgroundColor = Colors.black,
  Color textColor = Colors.white,
  double fontSize = 16.0,
}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: toastLength,
    gravity: gravity,
    backgroundColor: backgroundColor,
    textColor: textColor,
    fontSize: fontSize,
  );
}

void showSuccessToast(String message) {
  showToast(
    message: message,
    backgroundColor: Colors.green,
    textColor: Colors.white,
  );
}

void showErrorToast(String message) {
  showToast(
    message: message,
    backgroundColor: Colors.red,
    textColor: Colors.white,
  );
}

void showWarningToast(String message) {
  showToast(
    message: message,
    backgroundColor: Colors.orange,
    textColor: Colors.white,
  );
}

void showNormalToast(String message) {
  showToast(
    message: message,
    backgroundColor: Colors.blue,
    textColor: Colors.white,
  );
}
