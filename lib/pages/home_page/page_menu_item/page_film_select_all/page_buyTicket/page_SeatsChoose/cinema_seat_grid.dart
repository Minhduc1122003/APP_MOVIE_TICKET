import 'package:flutter/material.dart';
import 'package:flutter_app_chat/models/Chair_modal.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Ensure this import is present
import 'dart:async'; // Import the dart:async library for Timer

class CinemaSeatGrid extends StatefulWidget {
  final List<ChairModel> chairs;
  final int numberOfColumns;
  final Function(int) onCountChanged;

  const CinemaSeatGrid({
    Key? key,
    required this.chairs,
    this.numberOfColumns = 14,
    required this.onCountChanged,
  }) : super(key: key);

  @override
  _CinemaSeatGridState createState() => _CinemaSeatGridState();
}

class _CinemaSeatGridState extends State<CinemaSeatGrid> {
  Set<int> selectedChairs = {};
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
              seatColor = Color(0xFF6F3CD7); // Selected seat color
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
                    return; // Do nothing if the seat is reserved
                  } else if (selectedChairs.contains(index)) {
                    selectedChairs.remove(index);
                    widget.onCountChanged(-1); // Decrease count
                  } else {
                    if (selectedChairs.length >= 5) {
                      // Show toast if the limit is exceeded and debounce logic
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

                        // Start the timer for 2 seconds
                        _toastTimer = Timer(Duration(seconds: 2), () {
                          _toastTimer = null; // Reset the timer
                        });
                      }
                      return; // Do not add more chairs if limit is exceeded
                    }
                    selectedChairs.add(index);
                    widget.onCountChanged(1); // Increase count
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: seatColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Color(0xFF6F3CD7), width: 0.5),
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
