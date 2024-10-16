import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_chat/models/Chair_modal.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CinemaSeatGrid extends StatefulWidget {
  final List<ChairModel> chairs;
  final int numberOfColumns;
  final Function(int) onCountChanged;
  final Function(int, String)
      onChairSelected; // Callback for selected chair info

  const CinemaSeatGrid({
    Key? key,
    required this.chairs,
    this.numberOfColumns = 14,
    required this.onCountChanged,
    required this.onChairSelected, // Include the new parameter
  }) : super(key: key);

  @override
  _CinemaSeatGridState createState() => _CinemaSeatGridState();
}

class _CinemaSeatGridState extends State<CinemaSeatGrid> {
  Set<int> selectedChairs = {};
  List<int> seatIDList = []; // Khai báo seatIDList
  Timer? _toastTimer; // Timer for debounce

  @override
  void dispose() {
    _toastTimer?.cancel(); // Cancel timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double gridWidth = MediaQuery.of(context).size.width;
    double cellSize =
        (gridWidth - (widget.numberOfColumns - 1) * 5) / widget.numberOfColumns;

    return Stack(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.numberOfColumns,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: widget.chairs.length,
          itemBuilder: (context, index) {
            final chair = widget.chairs[index];
            String seatLabel = chair.chairCode;

            Color seatColor;
            Color seatTextColor;

            // Set chair color based on its status
            if (selectedChairs.contains(index)) {
              seatColor = mainColor; // Selected seat color
              seatTextColor = Colors.white;
            } else if (chair.reservationStatus) {
              seatColor = Colors.red; // Reserved seat color
              seatTextColor = Colors.white;
            } else if (chair.defectiveChair) {
              seatColor = Colors.black; // Defective seat color
              seatTextColor = Colors.white;
            } else {
              seatColor = Colors.white; // Available seat color
              seatTextColor = Colors.black;
            }

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (chair.reservationStatus) {
                    // Show a toast message if the chair is already reserved
                    if (_toastTimer == null || !_toastTimer!.isActive) {
                      Fluttertoast.showToast(
                        msg: "Ghế này đã được đặt trước!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black.withOpacity(0.8),
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      _toastTimer = Timer(Duration(seconds: 2), () {
                        _toastTimer = null;
                      });
                    }
                    return; // Exit the function to prevent any further action
                  } else if (selectedChairs.contains(index)) {
                    // Remove the selected chair
                    selectedChairs.remove(index);
                    widget.onCountChanged(
                        -1); // Decrease the count of selected chairs
                    widget.onChairSelected(chair.seatID,
                        chair.chairCode); // Send chair info for deselection
                    seatIDList
                        .remove(chair.seatID); // Remove ID from seatIDList
                  } else {
                    // Check if another chair can be added
                    if (selectedChairs.length >= 5) {
                      if (_toastTimer == null || !_toastTimer!.isActive) {
                        Fluttertoast.showToast(
                          msg: "Chỉ được tối đa 5 ghế trong 1 lần đặt vé!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black.withOpacity(0.8),
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        _toastTimer = Timer(Duration(seconds: 2), () {
                          _toastTimer = null;
                        });
                      }
                      return; // Exit the function to prevent adding more seats
                    }
                    // Add the selected chair
                    selectedChairs.add(index);
                    widget.onCountChanged(
                        1); // Increase the count of selected chairs
                    widget.onChairSelected(
                        chair.seatID, chair.chairCode); // Send chair info
                    seatIDList.add(chair.seatID); // Add ID to seatIDList
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: seatColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: mainColor, width: 0.5),
                ),
                child: Center(
                  child: Text(
                    seatLabel,
                    style: TextStyle(fontSize: 9, color: seatTextColor),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
