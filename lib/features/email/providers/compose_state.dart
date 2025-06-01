import 'dart:io';
import 'dart:typed_data';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ComposeState with ChangeNotifier {
  PlatformFile? _selectedFile;
  Uint8List? _fileBytes;

  PlatformFile? get selectedFile => _selectedFile;
  Uint8List? get fileBytes => _fileBytes;

  Future<void> setSelectedFile(PlatformFile? file) async {
    _selectedFile = file;

    // Đọc bytes của file để hiển thị
    if (file != null) {
      try {
        if (file.bytes != null) {
          // Web platform
          _fileBytes = file.bytes;
        } else if (file.path != null) {
          // Mobile/Desktop platform
          final fileData = File(file.path!);
          _fileBytes = await fileData.readAsBytes();
        }
      } on Exception catch (e) {
        AppFunctions.debugPrint('Error reading file: $e');
        _fileBytes = null;
      }
    } else {
      _fileBytes = null;
    }

    notifyListeners();
  }

  void clearSelectedFile() {
    _selectedFile = null;
    _fileBytes = null;
    notifyListeners();
  }

  // Kiểm tra xem file có phải là ảnh không
  bool isImageFile() {
    if (_selectedFile == null) return false;

    final extension = _selectedFile!.extension?.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(extension);
  }

  // Lấy kích thước file dạng readable
  String getFileSize() {
    if (_selectedFile == null) return '';

    final bytes = _selectedFile!.size;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
