import 'package:flutter/material.dart';

class MovieManagerPage extends StatefulWidget {
  const MovieManagerPage({Key? key}) : super(key: key);

  @override
  _MovieManagerPageState createState() => _MovieManagerPageState();
}

class _MovieManagerPageState extends State<MovieManagerPage> {
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

  List<String> selectedGenres = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFF6F3CD7),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
            size: 16,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Thêm phim sắp chiếu',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Poster Placeholder with "Coming Soon" label
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 180,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(Icons.add,
                              size: 40, color: Colors.grey[400]),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber[400],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Coming soon',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        // Row to align TextField and DropdownButton
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Nhập tên phim...',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
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
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
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
                        SizedBox(height: 10),
                        // Wrap with Chips for selected genres
                        Wrap(
                          spacing: 8.0,
                          children: selectedGenres.map((genre) {
                            return Chip(
                              label: Text(genre),
                              onDeleted: () {
                                setState(() {
                                  selectedGenres.remove(genre);
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('13+',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ngày khởi chiếu',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600])),
                        SizedBox(height: 4),
                        Text('7/9/2024', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Thời lượng',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600])),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ngôn ngữ',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600])),
                        Row(
                          children: [
                            Checkbox(
                              value: true,
                              onChanged: (bool? value) {},
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text('Phụ đề'),
                            Checkbox(
                              value: true,
                              onChanged: (bool? value) {},
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            Text('Lồng tiếng'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Rating
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 4),
                        Text('0/10', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    SizedBox(height: 8),
                    _buildRatingBar('9-10', 0.0),
                    _buildRatingBar('5-6', 0.0),
                    _buildRatingBar('3-4', 0.0),
                    _buildRatingBar('1-2', 0.0),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Movie Content
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

              // Director & Cast
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

              // Complete Button
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
    );
  }

  Widget _buildGenreChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.purple[700],
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Helper method for rating bars
  Widget _buildRatingBar(String label, double value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 40, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  void _showMultiSelectDialog() async {
    // Create a temporary list to hold the selected genres
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
                    // Update the main state with the selected genres
                    this.setState(() {
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
}
