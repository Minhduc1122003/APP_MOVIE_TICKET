import 'package:flutter/material.dart';

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
  // Map để lưu trạng thái toggle của các nút
  final Map<int, bool> _toggleStates = {};

  @override
  void initState() {
    super.initState();
    // Khởi tạo trạng thái toggle cho từng nút
    for (int i = 0; i < widget.buttons.length; i++) {
      _toggleStates[i] = widget.buttons[i].isToggled;
    }
  }

  void _handleToggleChanged(int index, bool newState) {
    setState(() {
      _toggleStates[index] = newState;
      // In giá trị của toggle khi thay đổi trạng thái
      if (widget.buttons[index].title == 'Ngôn ngữ') {
        print('Trạng thái toggle hiện tại của "Ngôn ngữ": $newState');
      }
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
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 4,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _showAllButtons
                    ? null
                    : (widget.buttons.length > 5
                        ? 5 * 48.0 // Chiều cao của 5 nút
                        : widget.buttons.length * 60.0),
                child: Column(
                  children: visibleButtons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final button = entry.value;
                    return UtilityButton(
                      title: button.title,
                      icon: button.icon,
                      onPressed: button.onPressed,
                      color: button.color,
                      colorText: button.colorText,
                      trailingIconType: button.trailingIconType,
                      isToggled: _toggleStates[index] ?? false,
                      onToggleChanged: (newState) =>
                          _handleToggleChanged(index, newState),
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

class UtilityButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Color toggleColor;
  final Color colorText;
  final TrailingIconType trailingIconType;
  final bool isToggled;
  final void Function(bool)? onToggleChanged;

  const UtilityButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPressed,
    required this.color,
    this.colorText = Colors.black,
    this.toggleColor = Colors.grey,
    this.trailingIconType = TrailingIconType.chevronRight,
    this.isToggled = false,
    this.onToggleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Icon? trailingIcon;
    switch (trailingIconType) {
      case TrailingIconType.none:
        trailingIcon = null;
        break;
      case TrailingIconType.chevronRight:
        trailingIcon = const Icon(Icons.chevron_right);
        break;
      case TrailingIconType.toggle:
        trailingIcon = Icon(
          isToggled ? Icons.toggle_on : Icons.toggle_off,
          color: toggleColor,
        );
        break;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: colorText),
      ),
      trailing: trailingIcon,
      onTap: () {
        if (trailingIconType == TrailingIconType.toggle) {
          bool newState = !isToggled;
          if (onToggleChanged != null) {
            onToggleChanged!(newState); // Gọi callback với trạng thái mới
          }
        }
        onPressed(); // Gọi hàm onPressed bên ngoài
      },
    );
  }
}

enum TrailingIconType {
  none,
  chevronRight,
  toggle,
}
