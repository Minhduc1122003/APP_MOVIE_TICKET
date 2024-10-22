import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_chat/auth/api_service.dart';
import 'package:flutter_app_chat/components/my_button.dart';
import 'package:flutter_app_chat/themes/colorsTheme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  final TextEditingController _durationController = TextEditingController();
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
  List<Map<String, dynamic>> _rows = [];
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _urlController = TextEditingController();
  YoutubePlayerController? _youtubeController;
  File? _image;
  final picker = ImagePicker();
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _addNewRow(); // Initialize with one row
  }

  Future<void> _pickImage(int index) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          // Ensure the index is within bounds
          if (index >= 0 && index < _rows.length) {
            _rows[index]['image'] =
                File(pickedFile.path); // Store the image file
            _image = File(pickedFile
                .path); // Optionally store it in a separate variable if needed
          } else {
            print('Index out of bounds');
          }
        });

        // Automatically upload the image after it is picked
        await _uploadImage();
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      await _apiService.uploadImage(_image!);
    } else {
      print('No image selected');
    }
  }

  void _loadVideo(String url) {
    final videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
      setState(() {});
    } else {
      // Handle invalid URL
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Không tìm thấy đường dẫn Url trên youtube')),
      );
    }
  }

  void _addNewRow() {
    setState(() {
      _rows.add({'image': null, 'name': TextEditingController()});
    });
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
          title: const Text('Nhập thời lượng (phút)'),
          content: TextField(
            controller: _durationController,
            keyboardType: TextInputType.number, // Chỉ cho phép nhập số
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly // Chỉ cho phép nhập chữ số
            ],
            decoration: const InputDecoration(
              hintText: 'Nhập số phút',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Xác nhận'),
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
              title: const Text('Chọn thể loại'),
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
                  child: const Text('Hủy'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Xác nhận'),
                  onPressed: () {
                    // Update the parent widget's state
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
    ).then((_) {
      // Ensure the parent widget's state is updated after the dialog is closed
      setState(() {});
    });
  }

  void _showPopupMenu(BuildContext context) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(100, 210, 0, 0), // Position the menu
        Offset.zero & overlay.size,
      ),
      items: ageRatings.map((Map<String, dynamic> rating) {
        return PopupMenuItem<String>(
          value: rating['value'],
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  rating['label']!,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: rating['color']),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rating['description']!,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedRating = value;
        });
      }
    });
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _durationController.dispose();
    _urlController.dispose();
    for (var row in _rows) {
      row['name'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0XFF6F3CD7),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_outlined,
                color: Colors.white, size: 16),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text('Thêm phim sắp chiếu',
              style: TextStyle(color: Colors.white, fontSize: 20)),
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImagePicker(),
                const SizedBox(height: 20),
                const Divider(
                  height: 0,
                  thickness: 6,
                  color: Color(0xfff0f0f0),
                ),
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
                const SizedBox(height: 10),
                const Text(
                  'Video trailer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                _buildYoutubePlayer(),
                const SizedBox(height: 10),
                _buildUrlInput(),
                const SizedBox(height: 20),
                _buildDescriptionInput(),
                const SizedBox(height: 20),
                const Divider(
                  height: 0,
                  thickness: 6,
                  color: Color(0xfff0f0f0),
                ),
                const SizedBox(height: 16),
                _buildActorSection(),
                const SizedBox(height: 15),
                const Divider(
                  height: 0,
                  thickness: 6,
                  color: Color(0xfff0f0f0),
                ),
                const SizedBox(height: 10),
                MyButton(
                    fontsize: 20,
                    paddingText: 10,
                    text: 'Hoàn tất',
                    isBold: true,
                    onTap: () {})
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click, // Change the cursor to a hand
              child: GestureDetector(
                onTap: () => _pickImage(
                    0), // Trigger _pickImage when the container is tapped
                child: Container(
                  height: 200,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _rows.isEmpty || _rows[0]['image'] == null
                      ? Center(
                          child: Icon(Icons.add,
                              size: 40, color: Colors.grey[400]))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _rows[0]['image'], // Display the image if it exists
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: 120, // Match the width of the card
                decoration: BoxDecoration(
                  color: Colors.black
                      .withOpacity(0.7), // Black background with opacity
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(
                        12), // Add border radius to the bottom left
                    bottomRight: Radius.circular(
                        12), // Add border radius to the bottom right
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 4), // Add some vertical padding
                child: const Text(
                  'Thêm ảnh',
                  textAlign: TextAlign.center, // Center the text
                  style: TextStyle(color: Colors.white), // White text color
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Tên phim',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tuổi',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                          height:
                              4), // Add some space between the title and the dropdown
                      GestureDetector(
                        onTap: () {
                          // Trigger the dropdown menu
                          _showPopupMenu(context);
                        },
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedRating,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Icon(Icons.arrow_drop_down,
                                  color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
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
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
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
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        // Tính toán chiều rộng khả dụng cho mỗi mục
                        double itemWidth = (constraints.maxWidth - 10) /
                            2; // Trừ đi khoảng cách giữa các mục

                        return Wrap(
                          spacing:
                              3.0, // Không có khoảng cách ngang giữa các mục
                          runSpacing: 5.0, // Thêm khoảng cách dọc giữa các hàng
                          children: selectedGenres.map((genre) {
                            return Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    itemWidth, // Đặt chiều rộng tối đa cho mỗi mục
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
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYoutubePlayer() {
    return _youtubeController != null
        ? YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.amber,
          )
        : SizedBox(
            height: 200,
            child: Container(
              height: 200,
              color: Colors.grey,
              child: Center(
                child: Text(
                  'Chưa tìm thấy nội dung',
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
  }

  Widget _buildUrlInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Url Trailer',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 10),
        MyButton(
          fontsize: 14,
          paddingText: 10,
          text: 'Duyệt',
          isBold: true,
          onTap: () {
            _loadVideo(_urlController.text);
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Nội dung phim',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: 3,
    );
  }

  Widget _buildActorSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Diễn viên',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ..._rows.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> row = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () => _pickImage(index),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: row['image'] != null
                                ? FileImage(row['image'])
                                : null,
                            child: row['image'] == null
                                ? const Icon(Icons.add_a_photo,
                                    color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const AutoSizeText(
                          'Thêm ảnh',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          maxFontSize: 8,
                          minFontSize: 4,
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: row['name'],
                        decoration: InputDecoration(
                          focusColor: mainColor,
                          hintText: 'Tên diễn viên',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    if (_rows.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _rows.removeAt(index);
                          });
                        },
                      ),
                  ],
                ),
              ),
              if (index < _rows.length - 1)
                const Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
            ],
          );
        }).toList(),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: mainColor, // Replace with your desired color
              borderRadius: BorderRadius.circular(50),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _addNewRow,
            ),
          ),
        ),
      ],
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

  const MovieInfo({
    Key? key,
    required this.isSubtitled,
    required this.isDubbed,
    required this.onSubtitleChanged,
    required this.onDubbedChanged,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onDurationSelected,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: 160,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AutoSizeText(
                    'Ngày khởi chiếu',
                    style: TextStyle(fontSize: 16),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  if (selectedDate != null)
                    AutoSizeText(
                      "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                    ),
                  if (selectedDate == null)
                    const AutoSizeText(
                      "",
                      style: TextStyle(fontSize: 14),
                      maxLines: 1,
                    ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: mainColor, // Replace with your desired color
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      icon: Icon(
                        selectedDate != null ? Icons.edit : Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: onDateSelected,
                    ),
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
                  const AutoSizeText(
                    'Thời lượng',
                    style: TextStyle(fontSize: 16),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  AutoSizeText(
                    duration,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      color: mainColor, // Replace with your desired color
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      icon: Icon(
                        selectedDate != null ? Icons.edit : Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: onDurationSelected,
                    ),
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
                  const SizedBox(height: 20),
                  const AutoSizeText(
                    'Ngôn ngữ',
                    style: TextStyle(fontSize: 16),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 5),
                  CheckboxListTile(
                    title: const AutoSizeText(
                      'Phụ đề',
                      style: TextStyle(fontSize: 14),
                      maxLines: 1,
                    ),
                    value: isSubtitled,
                    onChanged: onSubtitleChanged,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                    dense: true,
                    activeColor: mainColor,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: CheckboxListTile(
                      title: const AutoSizeText(
                        'Lồng tiếng',
                        style: TextStyle(fontSize: 14),
                        maxLines: 1,
                      ),
                      value: isDubbed,
                      onChanged: onDubbedChanged,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      dense: true,
                      activeColor: mainColor,
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
