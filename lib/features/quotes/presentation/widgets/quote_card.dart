import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/quote_entity.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../cubit/quote_cubit.dart';
import 'quote_review_modal.dart';

class QuoteCard extends StatefulWidget {
  final QuoteEntity quote;

  const QuoteCard({super.key, required this.quote});

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _shareQuote() {
    HapticFeedback.mediumImpact();
    final shareText = widget.quote.text +
        (widget.quote.bookTitle != null
            ? '\n\n— ${widget.quote.bookTitle}'
            : '') +
        (widget.quote.bookAuthor != null ? '، ${widget.quote.bookAuthor}' : '');
    Share.share(shareText);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return DateFormat('dd MMM', 'ar').format(date);
    }
  }

  Color _getFeelingColor(String feeling) {
    // جميع المشاعر باللون الأزرق الفاتح
    return AppColors.secondaryBlue; // الأزرق الفاتح
  }

  void _showEditQuoteModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuoteReviewModal(
        quote: widget.quote,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r(context)),
        ),
        title: Text(
          'حذف الاقتباس',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp(context),
            color: AppColors.textMain,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا الاقتباس؟ لا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(
            fontSize: 14.sp(context),
            color: AppColors.textSub,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: AppColors.textSub,
                fontSize: 14.sp(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteQuote(context);
            },
            child: Text(
              'حذف',
              style: TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteQuote(BuildContext context) {
    context.read<QuoteCubit>().deleteQuote(widget.quote.id);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) {
          _animationController.reverse();
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        onTapCancel: () => _animationController.reverse(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r(context)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // خلفية بيضاء صلبة
              borderRadius: BorderRadius.circular(24.r(context)),
              border: Border.all(
                color: widget.quote.isFavorite
                    ? AppColors.primaryBlue.withOpacity(0.3)
                    : AppColors.inputBorder,
                width: widget.quote.isFavorite ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.quote.isFavorite
                      ? AppColors.primaryBlue.withOpacity(0.15)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: 20.r(context),
                  offset: Offset(0, 8.h(context)),
                  spreadRadius: widget.quote.isFavorite ? 2 : 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.all(24.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Feeling badge and date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Feeling Badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w(context),
                            vertical: 6.h(context),
                          ),
                          decoration: BoxDecoration(
                            color: _getFeelingColor(widget.quote.feeling)
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20.r(context)),
                            border: Border.all(
                              color: _getFeelingColor(widget.quote.feeling)
                                  .withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.quote.feeling,
                                style: TextStyle(
                                  fontSize: 12.sp(context),
                                  color: _getFeelingColor(widget.quote.feeling),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Date
                        Text(
                          _formatDate(widget.quote.createdAt),
                          style: TextStyle(
                            fontSize: 11.sp(context),
                            color: AppColors.textPlaceholder,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h(context)),
                    // Quote Text with Smart Scaling/Truncation
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final textSpan = TextSpan(
                            text: widget.quote.text,
                            style: TextStyle(
                              //fontFamily: 'Tajawal',
                              fontWeight: FontWeight.w500, // Medium
                              fontSize: 16.sp(context),
                              height: 1.5,
                              color: Colors.black,
                            ),
                          );

                          final textPainter = TextPainter(
                            text: textSpan,
                            textDirection: Directionality.of(context),
                            maxLines: 5,
                          );

                          textPainter.layout(maxWidth: constraints.maxWidth);

                          if (textPainter.didExceedMaxLines && !_isExpanded) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.quote.text,
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    //fontFamily: 'Tajawal',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16.sp(context),
                                    height: 1.5,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 8.h(context)),
                                InkWell(
                                  onTap: () =>
                                      setState(() => _isExpanded = true),
                                  child: Text(
                                    '... اقرأ المزيد',
                                    style: TextStyle(
                                      //fontFamily: 'Tajawal',
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp(context),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Expanded state or short text
                            return SelectableText(
                              widget.quote.text,
                              style: TextStyle(
                                //fontFamily: 'Tajawal',
                                fontWeight: FontWeight.w500, // Medium
                                fontSize: 16.sp(context),
                                height: 1.5,
                                color: Colors.black,
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    // Notes Section
                    if (widget.quote.notes != null &&
                        widget.quote.notes!.isNotEmpty) ...[
                      SizedBox(height: 16.h(context)),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w(context)),
                        decoration: BoxDecoration(
                          color: const Color(
                              0xFFF8FAFC), // Slight darker subtle box
                          borderRadius: BorderRadius.circular(12.r(context)),
                          border: Border.all(
                              color: AppColors.inputBorder.withOpacity(0.5)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.sticky_note_2_outlined,
                              size: 16.sp(context),
                              color: AppColors.textSub,
                            ),
                            SizedBox(width: 8.w(context)),
                            Expanded(
                              child: Text(
                                widget.quote.notes!,
                                style: TextStyle(
                                  //fontFamily: 'Tajawal',
                                  fontSize: 13.sp(context),
                                  color: AppColors.textSub,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 20.h(context)),

                    // Footer (Book Info & Actions)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              // Book Cover Thumbnail
                              if (widget.quote.bookCoverUrl != null)
                                Container(
                                  width: 32.w(context),
                                  height: 48.h(context),
                                  margin: EdgeInsets.only(left: 8.w(context)),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(6.r(context)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4.r(context),
                                        offset: Offset(0, 2.h(context)),
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          widget.quote.bookCoverUrl!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else if (widget.quote.bookTitle != null)
                                Container(
                                  width: 32.w(context),
                                  height: 48.h(context),
                                  margin: EdgeInsets.only(left: 8.w(context)),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(6.r(context)),
                                    color:
                                        AppColors.primaryBlue.withOpacity(0.1),
                                    border: Border.all(
                                      color: AppColors.primaryBlue
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.auto_stories,
                                    size: 18.sp(context),
                                    color: AppColors.primaryBlue,
                                  ),
                                ),

                              SizedBox(width: 10.w(context)),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (widget.quote.bookTitle != null)
                                      Text(
                                        widget.quote.bookTitle!,
                                        style: TextStyle(
                                          fontSize: 13.sp(context),
                                          color: AppColors.textMain,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    if (widget.quote.bookAuthor != null) ...[
                                      SizedBox(height: 2.h(context)),
                                      Text(
                                        widget.quote.bookAuthor!,
                                        style: TextStyle(
                                          fontSize: 11.sp(context),
                                          color: AppColors.textSub,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                    if (widget.quote.bookTitle == null)
                                      Text(
                                        'بدون كتاب',
                                        style: TextStyle(
                                          fontSize: 12.sp(context),
                                          color: AppColors.textPlaceholder,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Buttons (compact)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Share Button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _shareQuote,
                                borderRadius:
                                    BorderRadius.circular(20.r(context)),
                                child: Padding(
                                  padding: EdgeInsets.all(8.w(context)),
                                  child: Icon(
                                    Icons.share_outlined,
                                    size: 20.sp(context),
                                    color: AppColors.textSub,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w(context)),
                            // Favorite Button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  context
                                      .read<QuoteCubit>()
                                      .toggleFavorite(widget.quote);
                                },
                                borderRadius:
                                    BorderRadius.circular(20.r(context)),
                                child: Padding(
                                  padding: EdgeInsets.all(8.w(context)),
                                  child: Icon(
                                    widget.quote.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 22.sp(context),
                                    color: widget.quote.isFavorite
                                        ? AppColors.primaryBlue
                                        : AppColors.textPlaceholder,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w(context)),
                            // More actions (Edit / Delete)
                            PopupMenuButton<String>(
                              tooltip: 'المزيد',
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16.r(context)),
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  HapticFeedback.selectionClick();
                                  _showEditQuoteModal(context);
                                } else if (value == 'delete') {
                                  HapticFeedback.mediumImpact();
                                  _showDeleteConfirmation(context);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit_outlined,
                                        size: 18.sp(context),
                                        color: AppColors.primaryBlue,
                                      ),
                                      SizedBox(width: 8.w(context)),
                                      Text(
                                        'تعديل الاقتباس',
                                        style: TextStyle(
                                          fontSize: 14.sp(context),
                                          color: AppColors.textMain,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18.sp(context),
                                        color: AppColors.errorRed,
                                      ),
                                      SizedBox(width: 8.w(context)),
                                      Text(
                                        'حذف الاقتباس',
                                        style: TextStyle(
                                          fontSize: 14.sp(context),
                                          color: AppColors.errorRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              icon: Icon(
                                Icons.more_vert,
                                size: 22.sp(context),
                                color: AppColors.textSub,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
