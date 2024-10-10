import 'package:flutter/material.dart';

class MovieManagerPage extends StatefulWidget {
  const MovieManagerPage({Key? key}) : super(key: key);

  @override
  _MovieManagerPageState createState() => _MovieManagerPageState();
}

@override
class _MovieManagerPageState extends State<MovieManagerPage> {
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
          'Chi tiết phim',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Text('this movie Manager'),
      ),
    );
  }
}
