import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/camera/camera_screen.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickFromCamera(BuildContext context) async {
    try {
      String? imagePath;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScreen(
            onImageCaptured: (path) {
              imagePath = path;
              Navigator.pop(context);
            },
          ),
        ),
      );

      return imagePath;
    } catch (e) {
      print('Camera error: $e');
      return null;
    }
  }

  Future<String?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      return image?.path;
    } catch (e) {
      print('Gallery error: $e');
      return null;
    }
  }
}
