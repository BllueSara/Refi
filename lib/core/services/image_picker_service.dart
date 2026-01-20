import 'package:image_picker/image_picker.dart';

abstract class ImagePickerService {
  Future<String?> pickImage(ImageSource source);
}

class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 100,
    );
    return image?.path;
  }
}
