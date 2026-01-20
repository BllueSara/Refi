import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../data/repositories/add_book_repository_impl.dart';
import '../cubit/search_cubit.dart';
import '../widgets/search_states_widgets.dart';
import 'manual_entry_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchCubit(AddBookRepositoryImpl()),
      child: const SearchScreenContent(),
    );
  }
}

class SearchScreenContent extends StatefulWidget {
  const SearchScreenContent({super.key});

  @override
  State<SearchScreenContent> createState() => _SearchScreenContentState();
}

class _SearchScreenContentState extends State<SearchScreenContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query, BuildContext context) {
    // Debounce can be added here
    context.read<SearchCubit>().searchBooks(query);
  }

  void _navigateToAddManually() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManualEntryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textMain),
        title: const Text(
          AppStrings.searchTitle,
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(
                fontFamily: 'Tajawal',
                color: AppColors.primaryBlue,
                fontSize: 16,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right, // RTL
              onChanged: (val) => _onSearchChanged(val, context),
              decoration: InputDecoration(
                hintText: AppStrings.searchHintFull,
                hintStyle: const TextStyle(
                  fontFamily: 'Tajawal',
                  color: AppColors.textPlaceholder,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textPlaceholder,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.cancel,
                    color: AppColors.textSub,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchCubit>().searchBooks("");
                  },
                ),
                filled: true,
                fillColor: const Color(0xFFF1F5F9), // Slate 100
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          if (state is SearchInitial) {
            return const SearchStartWidget();
          } else if (state is SearchLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          } else if (state is SearchEmpty) {
            return SearchEmptyWidget(onAddManually: _navigateToAddManually);
          } else if (state is SearchLoaded) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${AppStrings.searchResultsCount} (${state.books.length})",
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          color: AppColors.textSub,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.books.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final book = state.books[index];
                      return ListTile(
                        leading: Container(
                          width: 48,
                          height: 72,
                          color: Colors.grey[200], // Placeholder cover
                          child: const Icon(Icons.book, color: Colors.grey),
                        ),
                        title: Text(
                          book.title,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.author,
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                color: AppColors.textSub,
                              ),
                            ),
                            if (book.rating > 0)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    book.rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSub,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textPlaceholder,
                        ),
                        onTap: () {
                          // Select book logic
                        },
                      );
                    },
                  ),
                ),
                // Footer Link
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: _navigateToAddManually,
                    child: const Text(
                      AppStrings.didntFindBook,
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        color: AppColors.secondaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (state is SearchError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
