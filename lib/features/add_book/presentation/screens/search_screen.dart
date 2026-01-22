import 'package:flutter/material.dart';
import '../../../../core/widgets/refi_snack_bar.dart';
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
        RefiSnackBars.show(
          context,
          message: failure.message,
          type: SnackBarType.error,
        );
      },
      (_) {
        RefiSnackBars.show(
          context,
          message: "تمت إضافة الكتاب للمكتبة بنجاح",
          type: SnackBarType.success,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right, // RTL
              onChanged: (val) => _onSearchChanged(val, context),
              decoration: InputDecoration(
                hintText: AppStrings.searchHint, // Updated hint
                hintStyle: const TextStyle(
                  fontFamily: 'Tajawal',
                  color: AppColors.textPlaceholder,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryBlue, // Brand color for icon
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
                  borderRadius: BorderRadius.circular(100), // Pill shape
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
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
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showAddDialog(book),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 8.0,
                            ),
                            child: Row(
                              children: [
                                // Hero Image
                                Hero(
                                  tag: book.id ?? book.title,
                                  child: Container(
                                    width: 48,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                      image: book.imageUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                book.imageUrl!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: book.imageUrl == null
                                        ? const Icon(
                                            Icons.book,
                                            color: Colors.grey,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.textMain,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        book.authors.isNotEmpty
                                            ? book.authors.first
                                            : 'Unknown',
                                        style: const TextStyle(
                                          fontFamily: 'Tajawal',
                                          color: AppColors.textSub,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (book.rating != null &&
                                          book.rating! > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Row(
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
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: AppColors.primaryBlue,
                                  ),
                                  onPressed: () => _showAddDialog(book),
                                ),
                              ],
                            ),
                          ),
                        ),
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
