import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class JobPostUploadPage extends StatefulWidget {
  final Map<String, dynamic>? existingJob;

  const JobPostUploadPage({Key? key, this.existingJob}) : super(key: key);

  @override
  State<JobPostUploadPage> createState() => _JobPostUploadPageState();
}

class _JobPostUploadPageState extends State<JobPostUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? pdfUrl;

  @override
  void initState() {
    super.initState();
    if (widget.existingJob != null) {
      _titleController.text = widget.existingJob!['title'] ?? '';
      _companyController.text = widget.existingJob!['company'] ?? '';
      _locationController.text = widget.existingJob!['location'] ?? '';
      _descriptionController.text = widget.existingJob!['description'] ?? '';
      pdfUrl = widget.existingJob!['pdf_url'];
    }
  }

  Future<String> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print('Token from SharedPreferences: $token');
    return token ?? '';
  }

  Future<void> _uploadPdfFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final token = await _getAuthToken();

      final uri = Uri.parse("http://172.27.192.1:3000/api/upload-pdf");
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath(
          'pdf',
          file.path,
          contentType: MediaType('application', 'pdf'),
        ));


      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        setState(() {
          pdfUrl = data['pdf_url'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ PDF 업로드 성공')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ PDF 업로드 실패: ${response.statusCode}')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    final token = await _getAuthToken();
    if (_formKey.currentState!.validate()) {
      final jobData = {
        "title": _titleController.text.trim(),
        "company": _companyController.text.trim(),
        "location": _locationController.text.trim(),
        "description": _descriptionController.text.trim(),
        "pdf_url": pdfUrl,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('채용공고를 처리 중입니다...')),
      );

      try {
        final Uri url = widget.existingJob == null
            ? Uri.parse('http://172.27.192.1:3000/api/jobs')
            : Uri.parse('http://172.27.192.1:3000/api/jobs/${widget.existingJob!['id']}');

        final response = widget.existingJob == null
            ? await http.post(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(jobData),
        )
            : await http.put(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(jobData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('채용공고가 성공적으로 처리되었습니다.')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('처리 실패: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existingJob == null ? '채용공고 등록' : '채용공고 수정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputField('공고 제목', _titleController),
              _buildInputField('기업 이름', _companyController),
              _buildInputField('근무 위치', _locationController),
              _buildInputField('상세 설명', _descriptionController, maxLines: 5),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: const Text('PDF 업로드'),
                    onPressed: _uploadPdfFile,
                  ),
                  const SizedBox(width: 10),
                  if (pdfUrl != null) const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.upload),
                  label: Text(widget.existingJob == null ? '공고 등록' : '공고 수정'),
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) => value == null || value.isEmpty ? '$label을 입력해주세요' : null,
      ),
    );
  }
}
