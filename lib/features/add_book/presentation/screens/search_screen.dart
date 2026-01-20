import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../library/domain/entities/book_entity.dart';
import '../../../library/domain/usecases/add_book_to_library_usecase.dart';
import '../../../library/presentation/cubit/search_cubit.dart';
import '../widgets/search_states_widgets.dart';
import 'manual_entry_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<SearchCubit>(),
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
    context.read<SearchCubit>().search(query);
  }

  void _navigateToAddManually() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManualEntryScreen()),
    );
  }

  Future<void> _addBook(BookEntity book) async {
    // Show a loading indicator (optional) or just add
    final result = await di.sl<AddBookToLibraryUseCase>().call(book);
    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${failure.message}")));
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تمت إضافة الكتاب للمكتبة بنجاح")),
        );
        // Pop to return to library
        Navigator.pop(context);
      },
    );
  }

  void _showAddDialog(BookEntity book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book.title, textAlign: TextAlign.center),
        content: const Text(
          "هل تريد إضافة هذا الكتاب إلى مكتبتك؟",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _addBook(book);
            },
            child: const Text("إضافة"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: AppColors.textMain,
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          AppStrings.searchTitle,
          style: TextStyle(
            fontFamily: 'Tajawal',
            color: AppColors.textMain,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                    context.read<SearchCubit>().search("");
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
          } else if (state is SearchSuccess) {
            if (state.books.isEmpty) {
              return SearchEmptyWidget(onAddManually: _navigateToAddManually);
            }
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
                          color: Colors.grey[200],
                          child: book.imageUrl != null
                              ? Image.network(
                                  book.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.book,
                                        color: Colors.grey,
                                      ),
                                )
                              : const Icon(Icons.book, color: Colors.grey),
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
                              book.authors.isNotEmpty
                                  ? book.authors.first
                                  : 'Unknown',
                              style: const TextStyle(
                                fontFamily: 'Tajawal',
                                color: AppColors.textSub,
                              ),
                            ),
                            if (book.rating != null && book.rating! > 0)
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
                          Icons.add_circle_outline, // Hint to add
                          color: AppColors.primaryBlue,
                        ),
                        onTap: () {
                          _showAddDialog(book);
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
