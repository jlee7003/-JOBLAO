import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('구인구직 앱 홈')),
      body: Center(
        child: Text('구인구직 앱의 홈 화면'),
      ),
    );
  }
}
