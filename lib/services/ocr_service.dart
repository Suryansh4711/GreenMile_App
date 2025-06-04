import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../models/emission_result.dart';

class OcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _imagePicker = ImagePicker();

  Future<EmissionResult?> processImageFromCamera({
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Opening camera...');
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (image == null) {
        onStatus?.call('No image selected');
        return null;
      }

      return await _processImage(image, onStatus);
    } catch (e) {
      onStatus?.call('Error: $e');
      print('OCR Camera Error: $e');
      return null;
    }
  }

  Future<EmissionResult?> processImageFromGallery({
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Opening gallery...');
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (image == null) {
        onStatus?.call('No image selected');
        return null;
      }

      return await _processImage(image, onStatus);
    } catch (e) {
      onStatus?.call('Error: $e');
      print('OCR Gallery Error: $e');
      return null;
    }
  }

  Future<EmissionResult?> _processImage(
    XFile image,
    Function(String)? onStatus,
  ) async {
    try {
      onStatus?.call('Processing image...');
      final inputImage = InputImage.fromFilePath(image.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.isEmpty) {
        onStatus?.call('No text detected in image');
        return null;
      }

      onStatus?.call('Analyzing text...');
      final result = EmissionResult.fromOcrText(recognizedText.text);
      
      // Validate results
      if (!_validateResults(result)) {
        onStatus?.call('Invalid or incomplete data detected');
        return null;
      }

      onStatus?.call('Success!');
      return result;
    } catch (e) {
      onStatus?.call('Processing error: $e');
      print('OCR Processing Error: $e');
      return null;
    }
  }

  bool _validateResults(EmissionResult result) {
    // Basic validation to ensure we have reasonable values
    return result.co2Saved >= 0 && 
           result.co2Saved < 1000 &&
           result.noxSaved >= 0 && 
           result.noxSaved < 1000 &&
           result.fuelSaved >= 0 && 
           result.fuelSaved < 1000;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
