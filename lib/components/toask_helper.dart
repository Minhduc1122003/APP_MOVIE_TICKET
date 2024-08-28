import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  static void showToast(String message, bool isStatus) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isStatus ? Colors.green : Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
      webBgColor: isStatus
          ? 'linear-gradient(to right, #00b09b, #96c93d)'
          : 'linear-gradient(to right, #FF5F6D, #FFC371)',
      webPosition: 'bottom',
    );
  }
}
