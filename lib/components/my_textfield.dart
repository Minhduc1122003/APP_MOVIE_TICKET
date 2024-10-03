import 'package:flutter/material.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyTextfield extends StatefulWidget {
  final String? title;
  final bool isPassword;
  final bool isFill;
  final bool sendCode;
  final bool isPhone;
  final TextEditingController? controller;
  final String? placeHolder;
  final bool? isCode;
  final FocusNode? focusNode;
  final String? errorMessage;
  final IconData? icon;
  final Color? focusColor; // Màu khi focus

  const MyTextfield({
    Key? key,
    this.title,
    this.isPassword = false,
    this.isFill = false,
    this.sendCode = false,
    this.isPhone = false,
    this.controller,
    this.placeHolder = '',
    this.isCode,
    this.focusNode,
    this.errorMessage,
    this.icon,
    this.focusColor, // Thêm thuộc tính focusColor
  }) : super(key: key);

  @override
  _MyTextfieldState createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  FocusNode _focusNode = FocusNode();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {}); // Rebuild UI khi focus thay đổi
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Giải phóng focus node khi không cần thiết
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MyTextfield oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isCode != oldWidget.isCode) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: widget.controller,
            obscureText: widget.isPassword ? _obscureText : false,
            focusNode: widget.focusNode,
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              labelText: widget.placeHolder,
              hintStyle: const TextStyle(color: Color(0xFF4F75FF)),
              labelStyle: TextStyle(
                color: _focusNode
                        .hasFocus // Kiểm tra nếu trường đang được focus
                    ? const Color(0xFF4F75FF) // Màu khi được focus
                    : (widget.controller?.text.isNotEmpty ??
                            false) // Nếu trường không rỗng
                        ? const Color(0xFF4F75FF) // Màu khi có text
                        : Colors.grey, // Màu khi không có text và không focus
              ),
              // Các thuộc tính khác của InputDecoration
              fillColor: const Color(0xFF4F75FF),
              filled: widget.isFill,
              prefixIcon: widget.icon != null
                  ? Icon(
                      widget.icon,
                      color: Colors.black.withOpacity(0.6),
                      size: 20.0,
                    )
                  : null,
              prefixText: widget.isPhone ? '+84 ' : null,
              prefixStyle: const TextStyle(color: Colors.black),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: widget.focusColor ?? const Color(0xFF4F75FF),
                  // Màu khi focus
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              ),
              focusColor: widget.focusColor ?? Color(0xFF4F75FF),
              suffixIcon: widget.isPassword
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    )
                  : widget.sendCode
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SizedBox(
                            width: 60,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () {
                                    final title = 'Your Email Subject';
                                    final content = 'Content of the email';
                                    final recipient =
                                        widget.controller?.text ?? '';

                                    context.read<SendCodeBloc>().add(
                                          SendCode(title, content, recipient),
                                        );
                                  },
                                  child: const Text(
                                    'Gửi mã',
                                    style: TextStyle(
                                      color: Color(0XFF6F3CD7),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : widget.isCode == true
                          ? const Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            )
                          : widget.isCode == false
                              ? const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                )
                              : null,
            ),
          ),
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 5),
            Text(
              widget.errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
