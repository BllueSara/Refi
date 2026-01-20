import 'package:flutter/services.dart';
import 'dart:io';

abstract class OCRService {
  Future<String> recognizeText(File imageFile);
  void dispose();
}

class OCRServiceImpl implements OCRService {
  static const platform = MethodChannel('com.refi.ocr/text_recognition');

  @override
  Future<String> recognizeText(File imageFile) async {
    try {
      print('🔍 OCR: Sending image to native: ${imageFile.path}');

      final String result = await platform.invokeMethod('extractText', {
        'path': imageFile.path,
      });

      print('✅ OCR: Received text: $result');

      // Don't return the "not found" message, return empty instead
      if (result == "لم يتم العثور على نص") {
        return "";
      }

      return result.trim();
    } on PlatformException catch (e) {
      print('❌ OCR Platform Error: ${e.message}');
      return "";
    } catch (e) {
      print('❌ OCR Error: $e');
      return "";
    }
  }

  @override
  void dispose() {
    // No resources to dispose for platform channels
  }
}
