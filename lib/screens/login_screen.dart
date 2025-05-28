import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const LoginScreen({Key? key, required this.onLogin}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    final url = Uri.parse('http://172.27.192.1:3000/api/users/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔍 로그인 응답: $data');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        // ✅ 사용자 ID 저장 - 올바른 위치로 수정
        if (data['user'] != null && data['user']['id'] != null) {
          final userId = int.tryParse(data['user']['id'].toString());
          if (userId != null) {
            await prefs.setInt('user_id', userId);
            print('✅ 저장된 user_id: $userId');
          } else {
            print('⚠️ user_id 변환 실패: ${data['user']['id']}');
          }
        } else {
          print('⚠️ 사용자 ID 필드 없음: $data');
        }

        // ✅ 콜백 호출 및 화면 이동은 저장 후 실행
        widget.onLogin();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(onLogout: widget.onLogin),
          ),
        );
      } else {
        setState(() {
          _errorMessage = '로그인 실패: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '로그인 중 오류 발생: $e';
      });
    }
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(title: Text('로그인')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Login'),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: _navigateToSignup,
                    child: Text('회원가입'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
