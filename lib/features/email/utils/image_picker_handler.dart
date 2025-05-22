import 'package:image_picker/image_picker.dart';

mixin ImagePickerHandlerBase {
  Future<String?> pickImage();
}

class ImagePickerHandlerMobile implements ImagePickerHandlerBase {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile?.path;
  }
}

ImagePickerHandlerBase getImagePickerHandler() {
  return ImagePickerHandlerMobile();
}
