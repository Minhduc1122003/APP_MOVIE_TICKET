import 'package:flutter/material.dart';
import 'package:flutter_app_chat/models/Chair_modal.dart';

class CinemaSeatGrid extends StatefulWidget {
  final List<ChairModel> chairs;
  final int numberOfColumns;

  const CinemaSeatGrid({
    Key? key,
    required this.chairs,
    this.numberOfColumns = 14,
  }) : super(key: key);

  @override
  _CinemaSeatGridState createState() => _CinemaSeatGridState();
}

class _CinemaSeatGridState extends State<CinemaSeatGrid> {
  Set<int> selectedChairs = {};

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

            // Thiết lập màu sắc ghế dựa vào trạng thái
            if (selectedChairs.contains(index)) {
              seatColor = Color(0xFF6F3CD7); // Màu ghế đã chọn
              seatTextColor = Colors.white;
            } else if (chair.reservationStatus) {
              seatColor = Colors.red; // Màu ghế đã đặt
              seatTextColor = Colors.white;
            } else if (chair.defectiveChair) {
              seatColor = Colors.black; // Màu ghế hỏng
              seatTextColor = Colors.white;
            } else {
              seatColor = Colors.white; // Màu ghế trống
              seatTextColor = Colors.black;
            }

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (chair.reservationStatus) {
                    return;
                  } else if (selectedChairs.contains(index)) {
                    selectedChairs.remove(index);
                  } else {
                    selectedChairs.add(index);
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
