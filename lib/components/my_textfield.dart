import 'package:flutter/material.dart';
import 'package:flutter_app_chat/pages/register_page/sendCodeBloc/sendcode_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MyTextfield extends StatefulWidget {
  final String? title;
  final bool isPassword;
  final bool isFill;
  final bool sendCode;
  final bool isPhone;
  final TextEditingController? controller;
  final String? placeHolder;
  final bool? isCode; // Nullable boolean

  const MyTextfield({
    Key? key,
    this.title,
    this.isPassword = false,
    this.isFill = false,
    this.sendCode = false,
    this.isPhone = false,
    this.controller,
    this.placeHolder = '',
    this.isCode, // Nullable boolean
  }) : super(key: key);

  @override
  _MyTextfieldState createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  bool _obscureText = true;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MyTextfield oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isCode != oldWidget.isCode) {
      // Perform actions if isCode has changed
      print('isCode has changed: ${widget.isCode}');
      // Update UI based on new isCode value
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
            focusNode: _focusNode,
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              labelText: widget.placeHolder,
              hintStyle: const TextStyle(color: Colors.black26),
              fillColor: const Color(0xfff3f3f4),
              filled: widget.isFill,
              prefixText: widget.isPhone ? '+84 ' : null,
              prefixStyle: const TextStyle(color: Colors.black),
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
                          padding: const EdgeInsets.only(
                              right: 10.0,
                              top:
                                  15), // Adjust padding to not overlap the text field
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                final title = 'Your Email Subject';
                                final content = 'Content of the email';
                                final recipient = widget.controller?.text ?? '';

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
                        )
                      : widget.isCode == true
                          ? const Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Icon(
                                Icons.check_circle,
                                color:
                                    Colors.green, // Tích xanh cho giá trị true
                              ),
                            )
                          : widget.isCode == false
                              ? const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  child: Icon(
                                    Icons.cancel,
                                    color: Colors
                                        .red, // Dấu x đỏ cho giá trị false
                                  ),
                                )
                              : null, // Không hiển thị gì nếu isCode là null
            ),
          ),
        ],
      ),
    );
  }
}
