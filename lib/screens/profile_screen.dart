import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final String baseUrl = 'http://172.27.192.1:3000';
  String _userEmail = '불러오는 중...';
  String _userName = '불러오는 중...';
  String _userProfileImage = '';
  String _errorMessage = '';
  bool _isLoading = true;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print('Token from SharedPreferences: $token');

    if (token != null) {
      try {
        final url = Uri.parse('$baseUrl/api/users/profile');
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          setState(() {
            _userEmail = responseData['email'] ?? '이메일 없음';
            _userName = responseData['name'] ?? '이름 없음';
            _userProfileImage = responseData['profile_image'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = '프로필 정보를 불러오는 데 실패했습니다.';
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = '서버 오류: $e';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = '로그인 정보가 없습니다.';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImageAndUpload() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    setState(() {
      _selectedImage = imageFile;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/users/upload-profile'),
    );
    request.files.add(await http.MultipartFile.fromPath('profile_image', imageFile.path));
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      print('프로필 이미지 업로드 성공');
      _loadUserProfile(); // 업로드 후 재로딩
    } else {
      print('업로드 실패: ${response.statusCode}');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: _userProfileImage.isNotEmpty
                  ? Image.network(
                '$baseUrl/$_userProfileImage',
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              )
                  : CircleAvatar(
                radius: 75,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 75),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _pickImageAndUpload,
                child: Text('프로필 이미지 업로드'),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _userName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Email: $_userEmail', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            _errorMessage.isNotEmpty
                ? Text(_errorMessage, style: TextStyle(color: Colors.red))
                : Container(),
            /*Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                child: Text('Logout'),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
