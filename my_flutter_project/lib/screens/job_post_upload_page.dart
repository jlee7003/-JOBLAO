import 'package:flutter/material.dart';

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 서버에 업로드 요청 보내기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('채용공고를 등록 중입니다...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('채용공고 등록')),
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
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.upload),
                  label: Text('공고 등록'),
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
