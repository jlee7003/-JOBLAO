import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://172.27.192.1:3000'; // 실제 API URL로 변경

  // 사용자 프로필 정보 로드
  Future<Map<String, dynamic>> loadUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/profile'), // 실제 엔드포인트
        headers: {
          'Authorization': 'Bearer $token', // 인증 헤더에 토큰 전달
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // 프로필 정보가 성공적으로 로드되면 데이터 반환
      } else {
        throw Exception('프로필 정보 로드 실패: ${response.body}');
      }
    } catch (e) {
      throw Exception('API 요청 오류: $e');
    }
  }

  // 프로필 이미지 업로드
  Future<Map<String, dynamic>> uploadProfileImage(String token, String imagePath) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/users/upload-profile-image'))
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('profile_image', imagePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        return {'message': '프로필 이미지 업로드 성공'};
      } else {
        throw Exception('이미지 업로드 실패');
      }
    } catch (e) {
      throw Exception('이미지 업로드 오류: $e');
    }
  }
}
