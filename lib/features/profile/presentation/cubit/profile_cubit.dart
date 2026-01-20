import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // For auth fallback

// States
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  final String email;

  const ProfileLoaded({required this.profile, required this.email});

  @override
  List<Object> get props => [profile, email];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object> get props => [message];
}

// Cubit
class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final SupabaseClient supabaseClient;

  ProfileCubit({required this.getProfileUseCase, required this.supabaseClient})
    : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    final user = supabaseClient.auth.currentUser;

    if (user == null) {
      emit(const ProfileError("User not logged in"));
      return;
    }

    final result = await getProfileUseCase(user.id);

    result.fold((failure) => emit(ProfileError(failure.message)), (profile) {
      emit(ProfileLoaded(profile: profile, email: user.email ?? ''));
    });
  }
}
