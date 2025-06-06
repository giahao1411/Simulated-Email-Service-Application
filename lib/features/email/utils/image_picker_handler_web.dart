import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'image_picker_handler.dart';

class ImagePickerHandlerWeb implements ImagePickerHandlerBase {
  @override
  Future<String?> pickImage() async {
    if (!kIsWeb) {
      return null;
    }

    final completer = Completer<String?>();
    final uploadInput = html.FileUploadInputElement()..accept = 'image/*';

    uploadInput.onChange.listen((event) {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) {
        completer.complete(null);
        return;
      }

      final file = files[0];
      final reader = html.FileReader();
      reader.onLoad.listen((loadEvent) {
        final result = reader.result as String?;
        if (result != null) {
          completer.complete(result);
        } else {
          completer.completeError(Exception('Không thể đọc file'));
        }
      });

      reader.onError.listen((errorEvent) {
        completer.completeError(Exception('Lỗi khi đọc file: ${reader.error}'));
      });

      reader.readAsDataUrl(file);
    });

    uploadInput.click();

    return completer.future;
  }
}

ImagePickerHandlerBase createImagePickerHandler() => ImagePickerHandlerWeb();
