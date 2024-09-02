import 'package:flutter/material.dart';

class ExpandableInfoCard extends StatefulWidget {
  final String title;
  final String content;
  final bool isExpandedInitially;

  ExpandableInfoCard({
    required this.title,
    required this.content,
    this.isExpandedInitially = false,
  });

  @override
  _ExpandableInfoCardState createState() => _ExpandableInfoCardState();
}

class _ExpandableInfoCardState extends State<ExpandableInfoCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpandedInitially;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (_isExpanded) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border(
          bottom: BorderSide(
            color: Color(0XFF6F3CD7),
            width: 5.0,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Card(
          margin: EdgeInsets.zero,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: _isExpanded ? Color(0XFC4DFF6FF) : Color(0XFFf0f0f0),
                    child: ListTile(
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 15),
                      title: Text(
                        widget.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: AnimatedSize(
                          duration: Duration(milliseconds: 300),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: _isExpanded
                                  ? double.infinity
                                  : 3 * 20.0, // Điều chỉnh độ cao cho 3 dòng
                            ),
                            child: Text(
                              widget.content,
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.justify,
                              maxLines: _isExpanded ? null : 3,
                              overflow: _isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: -5,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: TextButton(
                      onPressed: _toggleExpansion,
                      child: Text(
                        _isExpanded ? '<< Rút gọn' : 'Xem thêm >>',
                        style: const TextStyle(
                          color: Color(0XFF6F3CD7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
