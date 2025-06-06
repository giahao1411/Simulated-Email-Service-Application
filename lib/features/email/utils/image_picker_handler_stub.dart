import 'dart:async';
import 'image_picker_handler.dart';

class ImagePickerHandlerStub implements ImagePickerHandlerBase {
  @override
  Future<String?> pickImage() async {
    throw UnsupportedError('Image picker not supported on this platform');
  }
}

ImagePickerHandlerBase createImagePickerHandler() => ImagePickerHandlerStub();
