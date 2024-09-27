import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void showLoadingSpinner(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevents dismissing by tapping outside
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent, // Transparent background
        child: Center(
          child: Container(
            // Removed the additional black background

            padding:
                const EdgeInsets.all(20), // Optional: padding around spinner
            child: SpinKitSpinningLines(
              color: Colors.white, // Spinner color
              size: 50.0, // Spinner size
            ),
          ),
        ),
      );
    },
  );
}

void hideLoadingSpinner(BuildContext context) {
  Navigator.of(context).pop(); // Closes the dialog
}
