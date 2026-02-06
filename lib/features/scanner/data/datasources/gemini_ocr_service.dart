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

    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        maxOutputTokens: 2048, // OCR ما يحتاج أكثر
        temperature: 0.0, // دقة أعلى، هلاوس أقل
        topP: 0.9,
      ),
    );

    print('🚀 Gemini Flash Initialized for jalees OCR');
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

      throw Exception('عذراً، لم نتمكن من قراءة الصفحة بوضوح. حاول مرة أخرى.');
    }
  }

  @override
  void dispose() {}
}
