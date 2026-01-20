import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit extends Cubit<int> {
  OnboardingCubit() : super(0);

  void pageChanged(int index) {
    emit(index);
  }

  void skip() {
    // Navigate to Auth/Home
    // For now, we can just print or handle navigation in the UI based on a state listener if needed,
    // but typically navigation is side-effect.
    // Since the requirement is "Tapping it should navigate to the Auth/Home screen immediately",
    // we might handle this in the UI, but let's provide a method here if we want to track "completed" state.
    // simpler: UI handles navigation, Cubit handles page index.
    emit(2); // Go to last page? Or just keep it simpe.
    // Actually, skip usually means "Done".
  }
}
