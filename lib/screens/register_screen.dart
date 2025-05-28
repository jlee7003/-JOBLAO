import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final codeController = TextEditingController();

  bool isButtonDisabled = false;
  int remainingSeconds = 180;
  Timer? _timer;
  String errorMessage = '';
  bool isCodeSent = false;
  bool isLoading = false;

  Future<void> sendVerificationCode() async {
    final email = emailController.text;
    final name = nameController.text;
    final password = passwordController.text;
    if (email.isEmpty || name.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = '이름, 이메일, 비밀번호를 입력해주세요';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://172.27.192.1:3000/api/auth/send-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'name': name, 'password': password}),
      );

      if (response.statusCode == 200) {
        setState(() {
          isCodeSent = true;
          isButtonDisabled = true;
          remainingSeconds = 180;
          errorMessage = '';
        });
        _startTimer();
      } else {
        final error = jsonDecode(response.body);
        setState(() {
          errorMessage = error['message'] ?? '메일 전송 실패';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '서버 오류: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          isButtonDisabled = false;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  Future<void> registerUser() async {
    final userData = {
      'email': emailController.text,
      'code': codeController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('http://172.27.192.1:3000/api/auth/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201){
        final responseData = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("회원가입 성공"),
            content: Text("환영합니다, ${responseData['user']['name']}님!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text("로그인하러 가기"),
              ),
            ],
          ),
        );
      } else {
        final error = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("회원가입 실패"),
            content: Text(error['message'] ?? '알 수 없는 오류'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("확인"),
              ),
            ],
          ),
        );
      }

    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("회원가입 실패"),
          content: Text("서버 오류: ${e.toString()}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("확인"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: '이메일'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: isButtonDisabled || isLoading ? null : sendVerificationCode,
              child: isButtonDisabled
                  ? Text('${_formatTime(remainingSeconds)} 후 다시 보내기')
                  : Text(isLoading ? '로딩 중...' : '인증코드 받기'),
            ),
            if (isCodeSent)
              TextField(
                controller: codeController,
                decoration: InputDecoration(labelText: '인증코드 입력'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : registerUser,
              child: Text("회원가입"),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(errorMessage, style: TextStyle(color: Colors.red)),
              )
          ],
        ),
      ),
    );
  }
}