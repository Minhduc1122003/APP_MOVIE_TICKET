import 'package:flutter/material.dart';

class MobileSchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch công tác đơn vị'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Thêm lịch công tác
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Quản lý tài nguyên
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: [
          buildDayCard(context, 'Thứ Hai', '26/08/2024', [
            buildTaskItem('Test nội dung công tác', '16:00', Colors.red),
          ]),
          buildDayCard(context, 'Thứ Ba', '27/08/2024', [
            buildTaskItem('ytjyjntnj', '11:00', Colors.grey),
            buildTaskItem('hymjtyhntnh', '11:00', Colors.grey),
            buildTaskItem('Test nội dung công tác 2', '06:00', Colors.purple),
          ]),
          buildDayCard(context, 'Thứ Tư', '28/08/2024', [
            buildTaskItem('Demo', '06:00', Colors.green),
          ]),
          buildDayCard(context, 'Thứ Năm', '29/08/2024', [
            buildTaskItem('Demo', '06:00', Colors.red),
          ]),
          buildDayCard(context, 'Thứ Sáu', '30/08/2024', [
            buildTaskItem('Ủa', '06:00', Colors.blue),
          ]),
        ],
      ),
    );
  }

  Widget buildDayCard(
      BuildContext context, String day, String date, List<Widget> tasks) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$day - $date',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Column(
              children: tasks,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTaskItem(String title, String time, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(8),
      color: color.withOpacity(0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14),
          ),
          Text(
            time,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
