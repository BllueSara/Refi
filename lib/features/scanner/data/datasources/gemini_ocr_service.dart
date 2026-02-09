import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'ocr_service.dart';

import 'package:image/image.dart' as img;

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
        topP:
            0.95, // Increased slightly for better creativity in reconstruction
      ),
    );

    print('🚀 Gemini Flash Initialized for jalees OCR');
  }

  Future<Uint8List> _processImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) return imageBytes; // Return original if decode fails

      // 1. Grayscale
      final grayscale = img.grayscale(image);

      // 2. Increase Contrast (1.5 factor)
      final contrast = img.contrast(grayscale, contrast: 150);

      // Encode back to JPEG
      return Uint8List.fromList(img.encodeJpg(contrast, quality: 85));
    } catch (e) {
      print('⚠️ Image processing failed, using original: $e');
      return await imageFile.readAsBytes();
    }
  }

  @override
  Future<String> recognizeText(File imageFile) async {
    try {
      // 1. Pre-process Image (Contrast + Grayscale)
      final processedBytes = await _processImage(imageFile);

      // 2. Compress Image (ensure it's not too large)
      // Note: FlutterImageCompress expects a path, but we have bytes now.
      // We can skip extra compression if we encoded with quality 85 above,
      // or write to temp file if strictly needed.
      // For efficiency, we'll try sending processedBytes directly if under limit.
      // But to be safe and consistent with previous flow, let's use the processed bytes directly.

      print(
          '📦 Processed Image Size: ${(await imageFile.length()) / 1024} KB -> ${(processedBytes.length) / 1024} KB');

      // 3. Send to Gemini
      final content = [
        Content.multi([
          TextPart(
              'Act as an expert OCR system. Your task is to extract text from the provided image with high precision.\n\n'
              '**CRITICAL INSTRUCTIONS:**\n'
              '1. **Handle Faint Text:** If the text appears faint, blurred, or has low contrast (ink is light), use your advanced contextual reasoning to reconstruct the words accurately. Do not return an error; try your absolute best to recover the text.\n'
              '2. **Language:** The text is primarily in Arabic. Ensure correct character recognition and handle Arabic punctuation and ligatures properly.\n'
              '3. **Format:** Return ONLY the extracted text. Do not include any introductory remarks, explanations, metadata, or comments.\n'
              '4. **No Hallucinations:** Only extract what is visible or contextually certain. If a word is completely illegible, represent it with [..].\n'
              '5. **Clean Output:** Remove any visual noise, page numbers, shadows, or header/footer artifacts. Only keep the main body of the quote.\n\n'
              'EXTRACTED TEXT:'),
          DataPart('image/jpeg', processedBytes),
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
