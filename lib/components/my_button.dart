import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final double paddingText;
  final bool
      showIcon; // Thêm thuộc tính boolean để kiểm soát việc hiển thị biểu tượng
  final void Function()? onTap;
  final double fontsize;

  const MyButton({
    super.key,
    required this.text,
    required this.paddingText,
    this.showIcon = false, // Mặc định không hiển thị biểu tượng
    this.onTap,
    required this.fontsize,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Hiển thị bàn tay khi hover
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0XFF6F3CD7),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          padding: EdgeInsets.all(paddingText), // Sử dụng double cho padding
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color:
                        Colors.white, // Có thể thêm màu sắc cho văn bản nếu cần
                    fontSize: fontsize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (showIcon) ...[
                  // Hiển thị biểu tượng nếu showIcon là true
                  const SizedBox(
                      width: 8), // Khoảng cách giữa văn bản và biểu tượng
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
