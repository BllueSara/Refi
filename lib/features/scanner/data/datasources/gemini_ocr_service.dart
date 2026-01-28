import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'ocr_service.dart';

class GeminiOCRService implements OCRService {
  late final GenerativeModel _model;

  GeminiOCRService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in .env');
    }

    // التغيير هنا: استخدم gemini-1.5-flash لضمان التوافق والسرعة
    _model = GenerativeModel(
      model: 'gemini 2.5 Flash-Lite',
      apiKey: apiKey,
    );
    print('🚀 Gemini Flash Initialized for Refi OCR');
  }

  @override
  Future<String> recognizeText(File imageFile) async {
    try {
      // 1. Compress Image
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: 1024,
        minHeight: 1024,
        quality: 85,
      );

      if (compressedBytes == null) {
        throw Exception("Image compression failed");
      }

      print(
          '📦 Image Size: ${(await imageFile.length()) / 1024} KB -> ${(compressedBytes.length) / 1024} KB');

      // 2. Send to Gemini

      // تأكد من استخدام البرومت المتفق عليه لضمان الدقة الكاملة
      final content = [
        Content.multi([
          TextPart('أنت خبير OCR لغة عربية. استخرج النص من الصورة بدقة 100%. '
              'قم بتصحيح الأخطاء الإملائية سياقياً، تجاهل الهوامش وأرقام الصفحات، '
              'وأعطني النص المستخرج فقط دون أي مقدمات.'),
          DataPart('image/jpeg', compressedBytes),
        ])
      ];

      final response = await _model.generateContent(content);
      return response.text?.trim() ?? '';
    } catch (e) {
      print('❌ Gemini OCR Error: $e');
      // إذا استمر الخطأ، جرب تحديث بكج google_generative_ai لأحدث نسخة
      throw Exception('Failed to extract text: $e');
    }
  }

  @override
  void dispose() {}
}
