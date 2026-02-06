import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class LegalTemplateScreen extends StatefulWidget {
  final String title;
  final String markdownUrl;

  const LegalTemplateScreen({
    super.key,
    required this.title,
    required this.markdownUrl,
  });

  @override
  State<LegalTemplateScreen> createState() => _LegalTemplateScreenState();
}

class _LegalTemplateScreenState extends State<LegalTemplateScreen> {
  String? _content;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    try {
      final response = await http.get(Uri.parse(widget.markdownUrl));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _content = response.body;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load content');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'تعذر تحميل المستند. يرجى التحقق من اتصالك بالإنترنت.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Creamy paper background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textMain,
            size: 24.sp(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.tajawal(
            fontSize: 20.sp(context),
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r(context)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 48.sp(context), color: Colors.grey),
              SizedBox(height: 16.h(context)),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 16.sp(context),
                  color: AppColors.textMain,
                ),
              ),
              SizedBox(height: 24.h(context)),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchContent();
                },
                child: Text(
                  'إعادة المحاولة',
                  style: GoogleFonts.tajawal(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scrollbar(
      child: Markdown(
        data: _content ?? '',
        padding: EdgeInsets.all(24.r(context)),
        styleSheet: MarkdownStyleSheet(
          p: GoogleFonts.tajawal(
            fontSize: 16.sp(context),
            height: 1.6,
            color: AppColors.textMain,
          ),
          h1: GoogleFonts.tajawal(
            fontSize: 24.sp(context),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
            height: 1.5,
          ),
          h2: GoogleFonts.tajawal(
            fontSize: 20.sp(context),
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBrown,
            height: 1.5,
          ),
          h3: GoogleFonts.tajawal(
            fontSize: 18.sp(context),
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
          listBullet: TextStyle(
            color: AppColors.primaryBlue,
            fontSize: 16.sp(context),
          ),
          blockSpacing: 16.h(context),
        ),
        onTapLink: (text, href, title) {
          // You could implement URL launcher here if needed
        },
      ),
    );
  }
}
