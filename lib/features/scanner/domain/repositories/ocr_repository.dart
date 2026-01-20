import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/processed_text.dart';

abstract class OCRRepository {
  Future<Either<Failure, ProcessedText>> scanImage(String imagePath);
}
