import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

class UtilitySection extends StatefulWidget {
  final String title;
  final List<UtilityButton> buttons;

  const UtilitySection({
    Key? key,
    required this.title,
    required this.buttons,
  }) : super(key: key);

  @override
  _UtilitySectionState createState() => _UtilitySectionState();
}

class _UtilitySectionState extends State<UtilitySection> {
  bool _showAllButtons = false;
  final Map<int, bool> _toggleStates = {};
  final Map<int, bool> _expandStates = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.buttons.length; i++) {
      _toggleStates[i] = widget.buttons[i].isToggled;
      _expandStates[i] = false;
    }
  }

  void _handleToggleChanged(int index, bool newState) {
    setState(() {
      _toggleStates[index] = newState;
      if (widget.buttons[index].title == 'Ngôn ngữ') {
        print('Trạng thái toggle hiện tại của "Ngôn ngữ": $newState');
      }
    });
  }

  void _handleExpand(int index) {
    setState(() {
      _expandStates[index] = !(_expandStates[index] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final showMoreButton = widget.buttons.length > 5;
    final visibleButtons =
        _showAllButtons ? widget.buttons : widget.buttons.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
          child: Text(
            widget.title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Column(
                  children: visibleButtons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final button = entry.value;
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: (_expandStates[index] ?? false)
                                    ? Colors.pink.withOpacity(0.4)
                                    : Colors.transparent,
                                width: 2.0,
                              ),
                            ),
                          ),
                          child: UtilityButton(
                            title: button.title,
                            icon: button.icon,
                            onPressed: () {
                              if (button.isExpandable) {
                                _handleExpand(index);
                              } else {
                                button.onPressed();
                              }
                            },
                            color: button.color,
                            colorText: button.colorText,
                            trailingIconType: button.isExpandable
                                ? (_expandStates[index] ?? false
                                    ? TrailingIconType.expandLess
                                    : TrailingIconType.expandMore)
                                : button.trailingIconType,
                            isToggled: _toggleStates[index] ?? false,
                            onToggleChanged: (newState) =>
                                _handleToggleChanged(index, newState),
                            isExpandable: button.isExpandable,
                            textStyle: button.textStyle,
                          ),
                        ),
                        if (button.isExpandable)
                          AnimatedSize(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            child: ClipRect(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                height: (_expandStates[index] ?? false)
                                    ? (button.expandedItems?.length ?? 0) * 56.0
                                    : 0,
                                child: SingleChildScrollView(
                                  physics: NeverScrollableScrollPhysics(),
                                  child: Column(
                                    children: button.expandedItems
                                            ?.map((item) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15.0,
                                                          right: 20.0),
                                                  child: UtilityButton(
                                                    title: item.title,
                                                    icon: item.icon,
                                                    onPressed: item.onPressed,
                                                    color: item.color,
                                                    colorText: item.colorText,
                                                    trailingIconType:
                                                        item.trailingIconType,
                                                    textStyle: item.textStyle,
                                                  ),
                                                ))
                                            .toList() ??
                                        [],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              if (showMoreButton)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(
                      _showAllButtons ? Icons.expand_less : Icons.expand_more,
                      color: Colors.pink,
                    ),
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          _showAllButtons = !_showAllButtons;
                        });
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// UtilityButton class remains unchanged

// UtilityButton class remains unchanged

class UtilityButton extends StatelessWidget {
  final String title;
  final IconData? icon; // Change to IconData?
  final Widget? lottieAnimation; // Add new property for Lottie animation
  final VoidCallback onPressed;
  final Color color;
  final Color toggleColor;
  final Color colorText;
  final TrailingIconType trailingIconType;
  final bool isToggled;
  final void Function(bool)? onToggleChanged;
  final bool isExpandable;
  final List<UtilityButton>? expandedItems;
  final TextStyle? textStyle;

  const UtilityButton({
    Key? key,
    required this.title,
    this.icon,
    this.lottieAnimation, // Initialize the new property
    required this.onPressed,
    required this.color,
    this.colorText = Colors.black,
    this.toggleColor = Colors.grey,
    this.trailingIconType = TrailingIconType.chevronRight,
    this.isToggled = false,
    this.onToggleChanged,
    this.isExpandable = false,
    this.expandedItems,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget;

    if (lottieAnimation != null) {
      leadingWidget = lottieAnimation;
    } else if (icon != null) {
      leadingWidget = Icon(icon, color: color, size: textStyle?.fontSize);
    }

    Icon? trailingIcon;
    switch (trailingIconType) {
      case TrailingIconType.none:
        trailingIcon = null;
        break;
      case TrailingIconType.chevronRight:
        trailingIcon = Icon(Icons.chevron_right, size: textStyle?.fontSize);
        break;
      case TrailingIconType.toggle:
        trailingIcon = Icon(
          isToggled ? Icons.toggle_on : Icons.toggle_off,
          color: toggleColor,
          size: textStyle?.fontSize,
        );
        break;
      case TrailingIconType.expandMore:
        trailingIcon = Icon(
          Icons.expand_more,
          size: textStyle?.fontSize,
        );
        break;
      case TrailingIconType.expandLess:
        trailingIcon = Icon(
          Icons.expand_less,
          size: textStyle?.fontSize,
          color: Colors.pink,
        );
        break;
    }

    return ListTile(
      leading: leadingWidget,
      title: Text(
        title,
        style: textStyle ??
            TextStyle(color: colorText, fontWeight: FontWeight.bold),
      ),
      trailing: trailingIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      onTap: () {
        if (trailingIconType == TrailingIconType.toggle) {
          bool newState = !isToggled;
          if (onToggleChanged != null) {
            onToggleChanged!(newState);
          }
        }
        onPressed();
      },
    );
  }
}

enum TrailingIconType {
  none,
  chevronRight,
  toggle,
  expandMore,
  expandLess,
}
