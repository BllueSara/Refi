import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/home_entity.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/home_header.dart';
import '../widgets/home_empty_body.dart';
import '../widgets/home_populated_body.dart';
import '../../../../core/constants/colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()
        ..loadHomeData(
          isNewUser: false,
        ), // Set isNewUser: false to show Populated state
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          // Default data for Initial/Loading to avoid null errors in Header
          // In a real app, Header might be loading state too
          HomeData? currentData;
          if (state is HomeLoaded) {
            currentData = state.data;
          } else if (state is HomeEmpty) {
            currentData = state.data;
          } else {
            // Mock data for loading header
            currentData = const HomeData(
              username: "...",
              streakDays: 0,
              completedBooks: 0,
              totalQuotes: 0,
              topTag: "",
            );
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: HomeHeader(data: currentData),
            body: Builder(
              builder: (context) {
                if (state is HomeLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  );
                } else if (state is HomeEmpty) {
                  return const HomeEmptyBody();
                } else if (state is HomeLoaded) {
                  return HomePopulatedBody(data: state.data);
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}
