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
  final Color? focusColor;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged; // Thêm thuộc tính onChanged
  final bool? isTimePicker;
  final List<String>? comboBoxItems;
  final bool isEdit; // Thêm thuộc tính isEdit
  final Function()? onArrowTap;

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
    this.focusColor,
    this.onSubmitted,
    this.onChanged, // Truyền giá trị cho onChanged
    this.isTimePicker,
    this.comboBoxItems,
    this.isEdit = true, // Đặt giá trị mặc định cho isEdit là true
    this.onArrowTap,
    SizedBox? suffix,
  }) : super(key: key);

  @override
  _MyTextfieldState createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  FocusNode _focusNode = FocusNode();
  bool _obscureText = true;
  bool hasText = false;
  String? selectedItem;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {}); // Rebuild UI when focus changes
    });

    // Listen to the text controller for changes
    widget.controller?.addListener(() {
      setState(() {
        hasText = widget.controller?.text.isNotEmpty ?? false;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Release focus node when not needed
    widget.controller
        ?.removeListener(() {}); // Remove listener to avoid memory leaks

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
    bool isFocused = _focusNode.hasFocus;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.comboBoxItems != null
              ? DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: widget.placeHolder,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.focusColor ?? const Color(0xFF4F75FF),
                        width: 1.0,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  value: selectedItem,
                  items: widget.comboBoxItems!
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(item),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedItem = value;
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!(value!);
                    }
                  },
                )
              : TextField(
                  controller: widget.controller,
                  obscureText: widget.isPassword ? _obscureText : false,
                  focusNode: _focusNode,
                  onSubmitted: widget.onSubmitted ?? (_) {},
                  onChanged: widget.onChanged, // Thêm onChanged ở đây
                  readOnly: widget.isTimePicker ??
                      false || !(widget.isEdit) || widget.onArrowTap != null,

                  onTap: widget.onArrowTap != null
                      ? () {
                          // Trigger the onArrowTap action when tapped
                          if (widget.onArrowTap != null) {
                            widget.onArrowTap!();
                          }
                        }
                      : widget.isTimePicker == true
                          ? () async {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );
                              if (pickedTime != null) {
                                final formattedTime =
                                    "${pickedTime.hour}:${pickedTime.minute.toString().padLeft(2, '0')}";
                                widget.controller?.text = formattedTime;
                              }
                            }
                          : null,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    labelText: widget.placeHolder,
                    hintStyle: const TextStyle(color: Color(0xFF4F75FF)),
                    labelStyle: TextStyle(
                      color: isFocused || hasText
                          ? widget.focusColor ?? const Color(0xFF4F75FF)
                          : Colors.grey,
                    ),
                    fillColor: const Color(0xFF4F75FF),
                    filled: widget.isFill,
                    prefixIcon: widget.icon != null
                        ? Icon(
                            widget.icon,
                            color: isFocused
                                ? widget.focusColor ?? const Color(0xFF4F75FF)
                                : Colors.black.withOpacity(0.6),
                            size: 20.0,
                          )
                        : null,
                    prefixText: widget.isPhone ? '+84 ' : null,
                    prefixStyle: const TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.focusColor ?? const Color(0xFF4F75FF),
                        width: 1.0,
                      ),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade400),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(8.0)),
                    ),
                    suffixIcon: widget.onArrowTap != null
                        ? IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios_outlined,
                              size: 16,
                            ),
                            onPressed:
                                widget.onArrowTap, // Call the provided function
                          )
                        : widget.isPassword
                            ? IconButton(
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
                                              final title =
                                                  'Your Email Subject';
                                              final content =
                                                  'Content of the email';
                                              final recipient =
                                                  widget.controller?.text ?? '';

                                              context.read<SendCodeBloc>().add(
                                                    SendCode(title, content,
                                                        recipient),
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
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : widget.isCode == false
                                        ? const Icon(Icons.cancel,
                                            color: Colors.red)
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
