import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../domain/usecases/scan_text_usecase.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();

  @override
  List<Object?> get props => [];
}

class ScannerIdle extends ScannerState {}

class ScannerScanning extends ScannerState {}

class ScannerSuccess extends ScannerState {
  final String text;
  const ScannerSuccess(this.text);

  @override
  List<Object?> get props => [text];
}

class ScannerFailure extends ScannerState {
  final String message;
  const ScannerFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ScannerCubit extends Cubit<ScannerState> {
  final ScanTextUseCase scanTextUseCase;
  final ImagePickerService imagePickerService;

  ScannerCubit({
    required this.scanTextUseCase,
    required this.imagePickerService,
  }) : super(ScannerIdle());

  Future<void> scanImage(ImageSource source) async {
    emit(ScannerScanning());

    final path = await imagePickerService.pickImage(source);

    if (path == null) {
      emit(ScannerIdle());
      return;
    }

    await scanImageFromPath(path);
  }

  Future<void> scanImageFromPath(String path) async {
    emit(ScannerScanning());
    final result = await scanTextUseCase(path);

    result.fold(
      (failure) => emit(ScannerFailure(failure.message)),
      (processedText) => emit(ScannerSuccess(processedText.text)),
    );
  }

  void reset() {
    emit(ScannerIdle());
  }
}
