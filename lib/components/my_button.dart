import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final double paddingText;
  final bool showIcon;
  final IconData? customIcon; // Thêm thuộc tính này
  final void Function()? onTap;
  final double fontsize;
  final Color color;
  final Color colorText;
  final bool border;
  final bool isBold;

  const MyButton({
    super.key,
    required this.text,
    required this.paddingText,
    this.showIcon = false,
    this.customIcon, // Thêm parameter này
    this.border = false,
    this.onTap,
    required this.fontsize,
    this.color = const Color(0xFF4F75FF),
    this.colorText = Colors.white,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            border: border ? Border.all(color: Colors.grey, width: 1.0) : null,
          ),
          padding: EdgeInsets.all(paddingText),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: colorText,
                    fontSize: fontsize,
                    fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
                  ),
                ),
                if (showIcon) ...[
                  const SizedBox(width: 8),
                  Icon(
                    customIcon ??
                        Icons.shopping_cart, // Sử dụng customIcon nếu có
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
