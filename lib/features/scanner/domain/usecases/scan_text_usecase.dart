import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/processed_text.dart';
import '../repositories/ocr_repository.dart';

class ScanTextUseCase {
  final OCRRepository repository;

  ScanTextUseCase(this.repository);

  Future<Either<Failure, ProcessedText>> call(String imagePath) async {
    return await repository.scanImage(imagePath);
  }
}
