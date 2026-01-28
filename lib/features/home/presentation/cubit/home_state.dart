import 'package:equatable/equatable.dart';
import '../../domain/entities/home_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeEmpty extends HomeState {
  final HomeData data;

  const HomeEmpty(this.data);

  @override
  List<Object?> get props => [data];
}

class HomeLoaded extends HomeState {
  final HomeData data;

  const HomeLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class HomeGoalAchieved extends HomeState {
  final HomeData data;

  const HomeGoalAchieved(this.data);

  @override
  List<Object?> get props => [data];
}
