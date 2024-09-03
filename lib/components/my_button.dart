import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final double paddingText;
  final bool showIcon; // Kiểm soát việc hiển thị biểu tượng
  final void Function()? onTap;
  final double fontsize;
  final Color color; // Màu nền
  final Color colorText; // Màu văn bản
  final bool border; // Kiểm soát việc hiển thị đường viền

  const MyButton({
    super.key,
    required this.text,
    required this.paddingText,
    this.showIcon = false, // Mặc định không hiển thị biểu tượng
    this.border = false, // Mặc định không có đường viền
    this.onTap,
    required this.fontsize,
    this.color = const Color(
        0XFF6F3CD7), // Mặc định là màu 0XFF6F3CD7 nếu không được truyền vào
    this.colorText = Colors.white, // Màu văn bản mặc định
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Hiển thị bàn tay khi hover
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            border: border
                ? Border.all(
                    color: Colors.grey,
                    width: 1.0) // Đường viền màu xám khi `border` là true
                : null, // Không có đường viền khi `border` là false
          ),
          padding: EdgeInsets.all(paddingText), // Sử dụng double cho padding
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: colorText, // Màu sắc văn bản
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
