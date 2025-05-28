import 'package:flutter/material.dart';

/// 공통 입력 필드 위젯
Widget buildInputField({
  required String label,
  required TextEditingController controller,
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) =>
      value == null || value.isEmpty ? '$label을 입력해주세요' : null,
    ),
  );
}
