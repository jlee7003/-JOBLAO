import 'package:flutter/material.dart';

class JobDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Job Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Company Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            Text(
              'Job Description:\nLorem ipsum dolor sit amet, consectetur adipiscing elit.',
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // 지원하기 기능 추가 가능
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Applied Successfully!')),
                  );
                },
                child: Text('Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
