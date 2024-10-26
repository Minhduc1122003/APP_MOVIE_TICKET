import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/components/my_textfield.dart';
import 'package:flutter_app_chat/models/Shift_modal.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ShiftEditPage extends StatefulWidget {
  final bool isEdit; // Thuộc tính xác định chế độ sửa
  final Shift? shift; // Đối tượng Shift cần sửa hoặc hiển thị

  const ShiftEditPage({
    Key? key,
    required this.isEdit, // Đánh dấu thuộc tính này là bắt buộc
    this.shift, // Đánh dấu thuộc tính này là bắt buộc
  }) : super(key: key);

  @override
  State<ShiftEditPage> createState() => _ShiftEditPageState();
}

class _ShiftEditPageState extends State<ShiftEditPage> {
  late ApiService _APIService;
  TextEditingController idController = TextEditingController();
  TextEditingController createDateController = TextEditingController();

  TextEditingController shiftNameController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  String? selectedShiftType;
  String? selectedStatus;
  double totalHours = 0.0;

  @override
  void initState() {
    super.initState();
    _APIService = ApiService();
    if (widget.isEdit && widget.shift != null) {
      idController.text = widget.shift!.shiftId.toString();
      createDateController.text = widget.shift!.createDate.toString();

      shiftNameController.text = widget.shift!.shiftName;
      startTimeController.text = widget.shift!.startTime;
      endTimeController.text = widget.shift!.endTime;
      selectedShiftType =
          widget.shift!.isCrossDay ? 'Qua đêm' : 'Không qua đêm';
      selectedStatus = widget.shift!.status;
    }
    startTimeController.addListener(_calculateTotalHours);
    endTimeController.addListener(_calculateTotalHours);
  }

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  void _calculateTotalHours() {
    setState(() {
      // Lấy giờ bắt đầu và giờ kết thúc từ các controller
      final startTime = startTimeController.text;
      final endTime = endTimeController.text;

      if (startTime.isNotEmpty && endTime.isNotEmpty) {
        try {
          final start = DateTime.parse("2024-01-01 $startTime:00");
          final end = DateTime.parse("2024-01-01 $endTime:00");
          totalHours = end.difference(start).inMinutes / 60.0;
          totalHours = double.parse(totalHours.toStringAsFixed(1));
        } catch (e) {
          print("Error parsing time: $e");
          totalHours = 0.0;
        }
      } else {
        totalHours = 0.0;
      }
    });
  }

  Future<void> _submitShift() async {
    if (shiftNameController.text.isEmpty ||
        startTimeController.text.isEmpty ||
        endTimeController.text.isEmpty ||
        selectedShiftType == null ||
        selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng điền đầy đủ thông tin!')),
      );
      return;
    }

    // Tạo một đối tượng Shift từ dữ liệu đã nhập
    Shift shift = Shift(
      shiftName: shiftNameController.text,
      startTime: _formatTime(startTimeController.text),
      endTime: _formatTime(endTimeController.text),
      isCrossDay: selectedShiftType == 'Qua đêm',
      status: selectedStatus!,
    );

    try {
      // Gọi API để gửi dữ liệu và lấy message
      String message = await _APIService.createShift(shift);

      // Kiểm tra nếu message là "Shift created successfully"
      if (message == 'Shift created successfully') {
        EasyLoading.showSuccess('Tạo ca làm thành công!');
        Future.delayed(Duration(seconds: 1), () {
          Navigator.of(context).pop(true); // Trả về true khi tạo ca thành công
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tạo ca làm: $message')),
        );
      }

      print(shift.startTime);
      print(shift.endTime);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tạo ca làm: $e')),
      );
    }
  }

// Hàm định dạng thời gian
  String _formatTime(String time) {
    // Tách giờ và phút
    List<String> parts = time.split(':');
    String hour = parts[0].padLeft(2, '0'); // Thêm '0' nếu giờ chỉ có 1 ký tự
    String minute = parts.length > 1 ? parts[1] : '00';

    // Trả về thời gian với định dạng 'HH:mm:ss'
    return '$hour:$minute:00';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        top: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: mainColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_outlined,
                  color: Colors.white, size: 16),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              widget.isEdit
                  ? 'Sửa ca làm'
                  : 'Tạo ca làm', // Kiểm tra isEdit để đặt tiêu đề
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                if (widget.isEdit)
                  Row(
                    children: [
                      Expanded(
                        child: MyTextfield(
                          controller: idController,
                          placeHolder: "ID ca làm",
                          icon: Icons.info_outline_rounded,
                          isEdit: false,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MyTextfield(
                          controller: createDateController,
                          placeHolder: "Ngày tạo",
                          icon: Icons.calendar_month,
                          isEdit: false,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 15),
                MyTextfield(
                  controller: shiftNameController,
                  placeHolder: 'Tên ca làm',
                  icon: Icons.drive_file_rename_outline,
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: MyTextfield(
                        controller: startTimeController,
                        isTimePicker: true,
                        placeHolder: "Giờ bắt đầu",
                        icon: Icons.timer_sharp,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MyTextfield(
                        controller: endTimeController,
                        isTimePicker: true,
                        placeHolder: "Giờ kết thúc",
                        icon: Icons.access_time,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    labelText: 'Loại ca làm',
                  ),
                  value: selectedShiftType, // Giá trị được chọn
                  items: const [
                    DropdownMenuItem(
                      value: 'Không qua đêm',
                      child: Text('Không qua đêm'),
                    ),
                    DropdownMenuItem(
                      value: 'Qua đêm',
                      child: Text('Qua đêm'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedShiftType = value; // Cập nhật giá trị đã chọn
                    });
                  },
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    labelText: 'Trạng thái',
                  ),
                  value: selectedStatus, // Giá trị được chọn
                  items: const [
                    DropdownMenuItem(
                      value: 'Đang hoạt động',
                      child: Text('Đang hoạt động'),
                    ),
                    DropdownMenuItem(
                      value: 'Ngưng hoạt động',
                      child: Text('Ngưng hoạt động'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value; // Cập nhật giá trị đã chọn
                    });
                  },
                ),
                const SizedBox(height: 15),
                Spacer(),
                if (widget.isEdit)
                  Row(
                    children: [
                      Expanded(
                        child: MyButton(
                          color: Colors.red,
                          fontsize: 20,
                          paddingText: 10,
                          text: 'Xóa ca',
                          onTap: () {
                            // Xử lý sự kiện xóa
                          },
                        ),
                      ),
                      const SizedBox(width: 10), // Khoảng cách giữa hai nút
                      Expanded(
                        child: MyButton(
                          fontsize: 20,
                          paddingText: 10,
                          text: 'Hoàn tất',
                          onTap: _submitShift, // Gọi hàm _submitShift
                        ),
                      ),
                    ],
                  )
                else
                  MyButton(
                    fontsize: 20,
                    paddingText: 10,
                    text: 'Hoàn tất',
                    onTap: _submitShift, // Gọi hàm _submitShift
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
