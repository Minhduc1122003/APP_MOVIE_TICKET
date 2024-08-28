import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onPressed;

  CustomIconButton({
    required this.icon,
    required this.size,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
        icon: Icon(icon, size: size, color: color),
        onPressed: onPressed,
      ),
    );
  }
}
