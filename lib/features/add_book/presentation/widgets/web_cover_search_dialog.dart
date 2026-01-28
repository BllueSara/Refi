import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class WebCoverSearchDialog extends StatefulWidget {
  final String initialQuery;
  final Function(String) onImageSelected;

  const WebCoverSearchDialog({
    super.key,
    required this.initialQuery,
    required this.onImageSelected,
  });

  @override
  State<WebCoverSearchDialog> createState() => _WebCoverSearchDialogState();
}

class _WebCoverSearchDialogState extends State<WebCoverSearchDialog> {
  final TextEditingController _ctrl = TextEditingController();
  List<String> _res = [];
  bool _load = false;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.initialQuery;
    _ctrl.addListener(() {
      setState(() {});
    });
    if (widget.initialQuery.isNotEmpty) _search(widget.initialQuery);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    setState(() => _load = true);
    try {
      final r = await http.get(
          Uri.parse('https://www.google.com/search?q=$q&tbm=isch&safe=active'),
          headers: {'User-Agent': 'Mozilla/5.0'});
      if (r.statusCode == 200) {
        final matches = RegExp(
                r'src="(https://encrypted-tbn[0-9]\.gstatic\.com/images\?q=[^"]*)"')
            .allMatches(r.body);
        setState(() {
          _res = matches.map((m) => m.group(1)!).toList().take(30).toList();
          _load = false;
        });
      } else
        setState(() => _load = false);
    } catch (_) {
      setState(() => _load = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r(context)),
      ),
      child: Container(
        padding: EdgeInsets.all(20.w(context)),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    "البحث عن غلاف الكتاب",
                    style: GoogleFonts.tajawal(
                      fontSize: 18.sp(context),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 24.sp(context)),
                  color: AppColors.textSub,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20.h(context)),
            // Search field
            TextField(
              controller: _ctrl,
              autofocus: true,
              style: GoogleFonts.tajawal(
                fontSize: 16.sp(context),
                color: AppColors.textMain,
              ),
              decoration: InputDecoration(
                hintText: "ابحث عن غلاف الكتاب...",
                hintStyle: GoogleFonts.tajawal(
                  fontSize: 14.sp(context),
                  color: AppColors.textPlaceholder,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 24.sp(context),
                  color: AppColors.primaryBlue,
                ),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 20.sp(context),
                        ),
                        onPressed: () {
                          _ctrl.clear();
                          setState(() => _res = []);
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.inputBorder.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r(context)),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w(context),
                  vertical: 16.h(context),
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _search(value);
                }
              },
              onChanged: (value) => setState(() {}),
            ),
            SizedBox(height: 20.h(context)),
            // Results
            Expanded(
              child: _load
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 3.w(context),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryBlue,
                            ),
                          ),
                          SizedBox(height: 16.h(context)),
                          Text(
                            "جاري البحث...",
                            style: GoogleFonts.tajawal(
                              fontSize: 14.sp(context),
                              color: AppColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _res.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_search_rounded,
                                size: 64.sp(context),
                                color: AppColors.textPlaceholder,
                              ),
                              SizedBox(height: 16.h(context)),
                              Text(
                                "ابدأ بالبحث عن غلاف الكتاب",
                                style: GoogleFonts.tajawal(
                                  fontSize: 14.sp(context),
                                  color: AppColors.textSub,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 12.w(context),
                            mainAxisSpacing: 12.h(context),
                          ),
                          itemCount: _res.length,
                          itemBuilder: (c, i) => GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onImageSelected(_res[i]);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(12.r(context)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.textMain.withOpacity(0.1),
                                    blurRadius: 8.r(context),
                                    offset: Offset(0, 4.h(context)),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(12.r(context)),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      _res[i],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: AppColors.inputBorder,
                                          child: Icon(
                                            Icons.broken_image_rounded,
                                            color: AppColors.textPlaceholder,
                                          ),
                                        );
                                      },
                                    ),
                                    // Overlay on tap
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.r(context)),
                                        border: Border.all(
                                          color: AppColors.primaryBlue,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
