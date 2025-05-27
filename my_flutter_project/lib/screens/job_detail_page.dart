import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class JobDetailPage extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailPage({Key? key, required this.job}) : super(key: key);

  /// 서버 기본 주소 (자신의 환경에 맞게 수정)
  final String baseUrl = "http://172.27.192.1:3000";

  Future<String?> _downloadPdf(String url) async {
    try {
      print('최종 PDF 요청 URL: $url');
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/job.pdf');
      await file.writeAsBytes(bytes, flush: true);

      return file.path;
    } catch (e) {
      print('PDF 다운로드 실패: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? relativePdfPath = job['pdf_url'];
    final String? pdfUrl =
    (relativePdfPath != null && !relativePdfPath.startsWith("http"))
        ? "$baseUrl$relativePdfPath"
        : relativePdfPath;

    final String? description = job['description'];
    final String? title = job['title'];
    final String? company = job['company'];
    final String? location = job['location'];

    return Scaffold(
      appBar: AppBar(title: Text(title ?? '채용 상세')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기본 정보
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? '',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  company ?? '',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  location ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(),
          // PDF 또는 설명
          Expanded(
            child: pdfUrl != null && pdfUrl.isNotEmpty
                ? FutureBuilder<String?>(
              future: _downloadPdf(pdfUrl),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data != null) {
                  return PDFView(filePath: snapshot.data!);
                } else {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      description ?? '상세 설명을 불러올 수 없습니다.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }
              },
            )
                : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                description ?? '상세 정보가 없습니다.',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
