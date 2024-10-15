import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MovieManagerPage extends StatefulWidget {
  const MovieManagerPage({Key? key}) : super(key: key);

  @override
  _MovieManagerPageState createState() => _MovieManagerPageState();
}

class _MovieManagerPageState extends State<MovieManagerPage> {
  bool _isSubtitled = false;
  bool _isDubbed = false;
  DateTime? _selectedDate;
  String _duration = '';
  TextEditingController _durationController = TextEditingController();
  String _selectedRating = '13+';
  final List<String> genres = [
    'Hài',
    'Phiêu lưu',
    'Hành động',
    'Kịch',
    'Kinh dị',
    'Gia đình',
    'Lãng mạn',
    'Hoạt hình',
  ];
  final List<Map<String, dynamic>> ageRatings = [
    {
      'label': 'K',
      'description': 'Dưới 13 tuổi + người giám hộ',
      'value': 'K',
      'color': Colors.blue
    },
    {
      'label': 'P',
      'description': 'Phù hợp mọi đối tượng khán giả',
      'value': 'P',
      'color': Colors.green
    },
    {
      'label': '13+',
      'description': 'Từ 13 tuổi trở lên',
      'value': '13+',
      'color': Colors.orange
    },
    {
      'label': '16+',
      'description': 'Từ 16 tuổi trở lên',
      'value': '16+',
      'color': Colors.red
    },
    {
      'label': '18+',
      'description': 'Từ 18 tuổi trở lên',
      'value': '18+',
      'color': Colors.black
    },
  ];

  List<String> selectedGenres = [];
  File? _image;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showDurationDialog() {
    _durationController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nhập thời lượng (phút)'),
          content: TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Nhập số phút',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Xác nhận'),
              onPressed: () {
                setState(() {
                  _duration = _durationController.text.isNotEmpty
                      ? '${_durationController.text} phút'
                      : 'Chưa chọn thời gian';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showMultiSelectDialog() async {
    final List<String> tempSelectedGenres = List.from(selectedGenres);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Chọn thể loại'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: genres.map((genre) {
                    return CheckboxListTile(
                      value: tempSelectedGenres.contains(genre),
                      title: Text(genre),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.green,
                      checkColor: Colors.white,
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            if (!tempSelectedGenres.contains(genre)) {
                              tempSelectedGenres.add(genre);
                            }
                          } else {
                            tempSelectedGenres.remove(genre);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Hủy'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Xác nhận'),
                  onPressed: () {
                    setState(() {
                      selectedGenres = List.from(tempSelectedGenres);
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFF6F3CD7),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined,
              color: Colors.white, size: 16),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Thêm phim sắp chiếu',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _image == null
                              ? Center(
                                  child: Icon(Icons.add,
                                      size: 40, color: Colors.grey[400]))
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(_image!, fit: BoxFit.cover),
                                ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.amber[400],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('Coming soon',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(Icons.add_a_photo, color: Colors.white),
                            onPressed: _pickImage,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    hintText: 'Nhập tên phim...',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[400]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.white,
                                ),
                                child: InkWell(
                                  onTap: _showMultiSelectDialog,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0, vertical: 11.0),
                                    child: Row(
                                      children: [
                                        Text('Thể loại'),
                                        Icon(Icons.add),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Wrap(
                                  spacing: 5.0,
                                  alignment: WrapAlignment.start,
                                  children: selectedGenres.map((genre) {
                                    return Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width /
                                                    2 -
                                                10,
                                      ),
                                      child: Chip(
                                        label: Text(
                                          genre,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            selectedGenres.remove(genre);
                                          });
                                        },
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _selectedRating,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.arrow_drop_down),
                                  offset: Offset(100, 40),
                                  onSelected: (String value) {
                                    setState(() {
                                      _selectedRating = value;
                                    });
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return ageRatings
                                        .map((Map<String, dynamic> rating) {
                                      return PopupMenuItem<String>(
                                        value: rating['value'],
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                rating['label']!,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: rating['color']),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  rating['description']!,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                MovieInfo(
                  isSubtitled: _isSubtitled,
                  isDubbed: _isDubbed,
                  onSubtitleChanged: (bool? value) {
                    setState(() {
                      _isSubtitled = value ?? false;
                    });
                  },
                  onDubbedChanged: (bool? value) {
                    setState(() {
                      _isDubbed = value ?? false;
                    });
                  },
                  selectedDate: _selectedDate,
                  onDateSelected: _selectDate,
                  onDurationSelected: _showDurationDialog,
                  duration: _duration,
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Nội dung phim',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Đạo diễn & Diễn viên',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Hoàn tất'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MovieInfo extends StatelessWidget {
  final bool isSubtitled;
  final bool isDubbed;
  final ValueChanged<bool?> onSubtitleChanged;
  final ValueChanged<bool?> onDubbedChanged;
  final DateTime? selectedDate;
  final Function() onDateSelected;
  final Function() onDurationSelected;
  final String duration;

  MovieInfo({
    required this.isSubtitled,
    required this.isDubbed,
    required this.onSubtitleChanged,
    required this.onDubbedChanged,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onDurationSelected,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Container(
        height: 190,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ngày khởi chiếu', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: onDateSelected,
                  ),
                  if (selectedDate != null)
                    Text(
                      "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      style: TextStyle(fontSize: 14),
                    ),
                ],
              ),
            ),
            Container(
              color: Colors.black,
              width: 1,
              height: 120,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Thời lượng', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: onDurationSelected,
                  ),
                  Text(
                    duration.isNotEmpty ? duration : '',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.black,
              width: 1,
              height: 120,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40),
                  Text('Ngôn ngữ', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 5),
                  CheckboxListTile(
                    title: Text('Phụ đề', style: TextStyle(fontSize: 14)),
                    value: isSubtitled,
                    onChanged: onSubtitleChanged,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    dense: true,
                  ),
                  Transform.translate(
                    offset: Offset(0, -10),
                    child: CheckboxListTile(
                      title: Text('Lồng tiếng', style: TextStyle(fontSize: 14)),
                      value: isDubbed,
                      onChanged: onDubbedChanged,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      dense: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
