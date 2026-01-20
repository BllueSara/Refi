import 'package:equatable/equatable.dart';

class ProcessedText extends Equatable {
  final String text;

  const ProcessedText({required this.text});

  @override
  List<Object?> get props => [text];
}
