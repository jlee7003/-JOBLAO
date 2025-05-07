import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'job_post_upload_page.dart'; // 등록/수정 페이지 import

class JobListPage extends StatefulWidget {
  const JobListPage({Key? key}) : super(key: key);

  @override
  State<JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<JobListPage> {
  List<dynamic> _jobs = [];
  bool _isLoading = true;

  Future<void> _fetchJobs() async {
    final url = Uri.parse('http://172.27.192.1:3000/api/jobs'); // 실제 API 주소로 교체
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _jobs = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('공고 불러오기 실패: ${response.reasonPhrase}')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteJob(int id) async {
    final url = Uri.parse('https://your-api.com/api/jobs/$id');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('공고가 삭제되었습니다.')),
      );
      _fetchJobs(); // 새로고침
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('삭제 실패: ${response.reasonPhrase}')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('채용공고 리스트')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchJobs,
        child: ListView.builder(
          itemCount: _jobs.length,
          itemBuilder: (context, index) {
            final job = _jobs[index];
            return ListTile(
              title: Text(job['title']),
              subtitle: Text('${job['company']} • ${job['location']}'),
              trailing: Row(
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
                      if (updated == true) _fetchJobs();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteJob(job['id']),
                  ),
                ],
              ),
            );
          },
        ),
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
          if (created == true) _fetchJobs();
        },
      ),
    );
  }
}
