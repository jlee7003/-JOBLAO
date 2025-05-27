import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'job_post_upload_page.dart';
import 'job_detail_page.dart';

class JobListPage extends StatefulWidget {
  const JobListPage({Key? key}) : super(key: key);

  @override
  State<JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<JobListPage> {
  List<dynamic> _jobs = [];
  bool _isLoading = true;
  int? _currentUserId;
  String _searchKeyword = '';

  // 사용자 ID 로드
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getInt('user_id');
    });
  }

  // 채용공고 불러오기 (검색어 포함)
  Future<void> _fetchJobs({String keyword = ''}) async {
    setState(() => _isLoading = true);

    try {
      final Map<String, String> queryParameters = {};
      if (keyword.isNotEmpty) {
        queryParameters['search'] = keyword;
      }

      final url = Uri.http('172.27.192.1:3000', '/api/jobs', queryParameters);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _jobs = data.isEmpty ? [] : List.from(data);
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공고 불러오기 실패: ${response.statusCode} - ${response.reasonPhrase}')),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: $e')),
      );
      setState(() => _isLoading = false);
    }
  }


  // 채용공고 삭제
  Future<void> _deleteJob(int id) async {
    final url = Uri.parse('http://172.27.192.1:3000/api/jobs/$id');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('공고가 삭제되었습니다.')),
        );
        await _fetchJobs(keyword: _searchKeyword); // 현재 검색 상태 유지
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('채용공고를 찾을 수 없습니다.')),
        );
      } else if (response.statusCode == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 권한이 없습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: ${response.reasonPhrase}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류: ${error.toString()}')),
      );
    }
  }

  // 초기화
  Future<void> _initialize() async {
    await _loadUserId();
    await _fetchJobs(); // 검색어 없이 전체 불러오기
    print('✅ Loaded user id: $_currentUserId');
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // 검색어 변경 시 서버 요청
  void _onSearchChanged(String value) {
    _searchKeyword = value;
    _fetchJobs(keyword: _searchKeyword);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('채용공고 리스트')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: '공고 검색',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
              onRefresh: () => _fetchJobs(keyword: _searchKeyword),
              child: _jobs.isEmpty
                  ? const Center(child: Text('검색 결과가 없습니다.'))
                  : ListView.builder(
                itemCount: _jobs.length,
                itemBuilder: (context, index) {
                  final job = _jobs[index];
                  final currentUserId = _currentUserId;
                  final jobUserId = job['user_id'];

                  return ListTile(
                    title: Text(job['title']),
                    subtitle: Text('${job['company']} • ${job['location']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailPage(job: job),
                        ),
                      );
                    },
                    trailing: (jobUserId == currentUserId)
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobPostUploadPage(existingJob: job),
                              ),
                            );
                            if (updated == true) _fetchJobs(keyword: _searchKeyword);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteJob(job['id']),
                        ),
                      ],
                    )
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobPostUploadPage(),
            ),
          );
          if (created == true) _fetchJobs(keyword: _searchKeyword); // 검색 유지한 채 새로고침
        },
      ),
    );
  }
}
