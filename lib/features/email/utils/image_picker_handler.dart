import 'dart:async';
import 'image_picker_handler_stub.dart'
    if (dart.library.html) 'image_picker_handler_web.dart'
    if (dart.library.io) 'image_picker_handler_mobile.dart';

mixin ImagePickerHandlerBase {
  Future<String?> pickImage();
}

ImagePickerHandlerBase getImagePickerHandler() => createImagePickerHandler();
