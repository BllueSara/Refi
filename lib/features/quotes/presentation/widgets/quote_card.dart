import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/quote_entity.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../cubit/quote_cubit.dart';

class QuoteCard extends StatefulWidget {
  final QuoteEntity quote;

  const QuoteCard({super.key, required this.quote});

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r(context)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(
                0.8), // Using 0.8 for visibility/readability on white
            borderRadius: BorderRadius.circular(24.r(context)),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.05),
                blurRadius: 20.r(context),
                offset: Offset(0, 8.h(context)),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(24.r(context)),
              child: Padding(
                padding: EdgeInsets.all(24.w(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            textDirection: TextDirection.rtl,
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

                    SizedBox(height: 24.h(context)),

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
                                  width: 24.w(context),
                                  height: 36.h(context),
                                  margin: EdgeInsets.only(left: 8.w(context)),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.r(context)),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          widget.quote.bookCoverUrl!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else
                                Icon(
                                  Icons.bookmark_outline,
                                  size: 18.sp(context),
                                  color: AppColors.textSub,
                                ),

                              SizedBox(width: 8.w(context)),

                              Expanded(
                                child: Text(
                                  widget.quote.bookTitle ?? 'بدون كتاب',
                                  style: TextStyle(
                                    //fontFamily: 'Tajawal',
                                    fontSize: 12.sp(context),
                                    color: AppColors.textSub,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Favorite Button
                        IconButton(
                          icon: Icon(
                            widget.quote.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          iconSize: 22.sp(context),
                          color: widget.quote.isFavorite
                              ? AppColors.primaryBlue // App Brand Color
                              : AppColors.textPlaceholder,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            context
                                .read<QuoteCubit>()
                                .toggleFavorite(widget.quote);
                          },
                          splashRadius: 24.r(context),
                          tooltip: widget.quote.isFavorite
                              ? 'إزالة من المفضلة'
                              : 'إضافة للمفضلة',
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
