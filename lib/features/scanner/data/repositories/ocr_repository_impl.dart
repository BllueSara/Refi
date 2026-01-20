import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/processed_text.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../datasources/ocr_service.dart';

class OCRRepositoryImpl implements OCRRepository {
  final OCRService ocrService;

  OCRRepositoryImpl({required this.ocrService});

  @override
  Future<Either<Failure, ProcessedText>> scanImage(String imagePath) async {
    try {
      final text = await ocrService.recognizeText(File(imagePath));
      if (text.trim().isEmpty) {
        return const Left(ServerFailure('لم يتم العثور على نص'));
      }
      return Right(ProcessedText(text: text));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
