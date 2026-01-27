import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/ocr_repository.dart';

class ExtractTextFromImageUseCase {
  final OCRRepository repository;

  ExtractTextFromImageUseCase(this.repository);

  Future<Either<Failure, String>> call(String imagePath) async {
    final result = await repository.scanImage(imagePath);
    return result.map((processedText) => processedText.text);
  }
}
