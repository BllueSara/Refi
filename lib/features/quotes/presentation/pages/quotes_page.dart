import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../scanner/presentation/pages/scanner_page.dart';
import '../cubit/quote_cubit.dart';
import '../../domain/entities/quote_entity.dart';

class QuotesPage extends StatefulWidget {
  const QuotesPage({super.key});

  @override
  State<QuotesPage> createState() => _QuotesPageState();
}

class _QuotesPageState extends State<QuotesPage> {
  String _activeTab = AppStrings.tabAll;

  final List<String> _tabs = [
    AppStrings.tabAll,
    AppStrings.filterByBook,
    AppStrings.filterFavorites,
  ];

  @override
  void initState() {
    super.initState();
    // Load quotes when page opens
    context.read<QuoteCubit>().loadUserQuotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.search, color: AppColors.textMain, size: 28),
          onPressed: () {},
        ),
        title: const Text(
          AppStrings.quotesVaultTitle,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textMain,
          ),
        ),
        actions: const [SizedBox(width: 48)],
      ),
      body: Column(
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: _tabs.map((tab) {
                final isActive = _activeTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeTab = tab),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: isActive ? AppColors.refiMeshGradient : null,
                        color: isActive ? null : AppColors.inputBorder,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : AppColors.textSub,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Quote List
          Expanded(
            child: BlocBuilder<QuoteCubit, QuoteState>(
              builder: (context, state) {
                if (state is QuoteLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is QuoteError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.textPlaceholder,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            color: AppColors.textSub,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<QuoteCubit>().loadUserQuotes();
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is QuotesLoaded) {
                  final quotes = state.quotes;

                  if (quotes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.format_quote,
                            size: 80,
                            color: AppColors.textPlaceholder.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'لا توجد اقتباسات بعد',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSub,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ابدأ بإضافة اقتباساتك المفضلة',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              color: AppColors.textPlaceholder,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<QuoteCubit>().loadUserQuotes();
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: quotes.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final quote = quotes[index];
                        return _QuoteCard(quote: quote);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const ScannerPage()),
          );
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.refiMeshGradient,
          ),
          child: const Icon(Icons.camera_alt, color: Colors.white),
        ),
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final QuoteEntity quote;

  const _QuoteCard({required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            quote.text,
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
              fontSize: 16,
              height: 1.6,
              color: Colors.black,
            ),
          ),
          if (quote.notes != null && quote.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputBorder.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                quote.notes!,
                style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  color: AppColors.textSub,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.bookmark,
                      size: 16,
                      color: AppColors.textSub,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        quote.bookTitle ?? 'بدون كتاب',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 12,
                          color: AppColors.textSub,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.share,
                size: 20,
                color: AppColors.textPlaceholder,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
