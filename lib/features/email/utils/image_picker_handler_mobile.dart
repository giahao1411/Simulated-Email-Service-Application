import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'image_picker_handler.dart';

class ImagePickerHandlerMobile implements ImagePickerHandlerBase {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile?.path;
  }
}

ImagePickerHandlerBase createImagePickerHandler() => ImagePickerHandlerMobile();
