import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/refi_success_widget.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedCategory;
  bool _isSending = false;

  final List<Map<String, String>> _categories = [
    {'label': AppStrings.categoryProblem, 'value': 'مشكلة'},
    {'label': AppStrings.categorySuggestion, 'value': 'اقتراح'},
    {'label': AppStrings.categoryOther, 'value': 'شيء آخر'},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    // Validation
    if (_selectedCategory == null) {
      _showSnackBar(
        AppStrings.pleaseSelectCategory,
        AppColors.warningOrange,
        Icons.warning_amber_rounded,
      );
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      _showSnackBar(
        AppStrings.pleaseEnterMessage,
        AppColors.warningOrange,
        Icons.warning_amber_rounded,
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      // Prepare email
      final String emailAddress = 'jaleesreader@gmail.com';
      final String subject = '[$_selectedCategory] رسالة من تطبيق جليس';
      final String body = _messageController.text.trim();
      
      // Create mailto URL with proper encoding
      final String mailtoUrl = 'mailto:$emailAddress?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
      final Uri emailUri = Uri.parse(mailtoUrl);

      // Try to launch email
      try {
        final bool launched = await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          // Clear form and show success
          if (mounted) {
            _messageController.clear();
            setState(() {
              _selectedCategory = null;
            });
            _showSuccessDialog();
          }
        } else {
          // If launchUrl returns false, try alternative method
          await _showAlternativeDialog(emailAddress, subject, body);
        }
      } catch (launchError) {
        // If launch fails, show alternative method
        await _showAlternativeDialog(emailAddress, subject, body);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى.',
          AppColors.errorRed,
          Icons.error_outline,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _showAlternativeDialog(
      String email, String subject, String body) async {
    final fullMessage = 'البريد الإلكتروني: $email\n\nالموضوع: $subject\n\nالرسالة:\n$body';
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r(context)),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.primaryBlue,
              size: 24.sp(context),
            ),
            SizedBox(width: 12.w(context)),
            Text(
              'تعذر فتح البريد',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp(context),
                color: AppColors.textMain,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'يمكنك نسخ المعلومات وإرسالها يدوياً:',
              style: TextStyle(
                fontSize: 14.sp(context),
                color: AppColors.textSub,
              ),
            ),
            SizedBox(height: 16.h(context)),
            Container(
              padding: EdgeInsets.all(12.w(context)),
              decoration: BoxDecoration(
                color: AppColors.inputBorder.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12.r(context)),
              ),
              child: SelectableText(
                fullMessage,
                style: TextStyle(
                  fontSize: 13.sp(context),
                  color: AppColors.textMain,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: fullMessage));
              Navigator.pop(context);
              _showSnackBar(
                'تم نسخ المعلومات',
                AppColors.primaryBlue,
                Icons.check_circle,
              );
            },
            child: Text(
              'نسخ المعلومات',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: TextStyle(
                color: AppColors.textSub,
                fontSize: 14.sp(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20.sp(context)),
            SizedBox(width: 12.w(context)),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp(context)),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r(context)),
        ),
        margin: EdgeInsets.all(16.w(context)),
      ),
    );
  }

  void _showSuccessDialog() {
    HapticFeedback.heavyImpact();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => RefiSuccessWidget(
          title: AppStrings.messageSent,
          subtitle: AppStrings.messageSentDesc,
          primaryButtonLabel: "العودة",
          onPrimaryAction: () {
            Navigator.of(ctx).pop(); // Close success screen
            Navigator.of(context).pop(); // Close contact page
          },
        ),
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
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textMain,
            size: 24.sp(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.contactUsTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp(context),
            color: AppColors.textMain,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section with Icon
            Center(
              child: Container(
                padding: EdgeInsets.all(24.w(context)),
                decoration: BoxDecoration(
                  gradient: AppColors.refiMeshGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 20.r(context),
                      offset: Offset(0, 8.h(context)),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mail_outline_rounded,
                  size: 48.sp(context),
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 24.h(context)),
            
            // Welcome Text
            Text(
              AppStrings.contactUsSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp(context),
                fontWeight: FontWeight.w600,
                color: AppColors.textMain,
                height: 1.4,
              ),
            ),
            SizedBox(height: 40.h(context)),

            // Category Selection
            Text(
              AppStrings.whatToTalkAbout,
              style: TextStyle(
                fontSize: 16.sp(context),
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            SizedBox(height: 16.h(context)),
            
            Wrap(
              spacing: 12.w(context),
              runSpacing: 12.h(context),
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category['value'];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedCategory = category['value'];
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w(context),
                      vertical: 14.h(context),
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.refiMeshGradient : null,
                      color: isSelected ? null : AppColors.inputBorder,
                      borderRadius: BorderRadius.circular(28.r(context)),
                      border: isSelected
                          ? Border.all(
                              color: AppColors.primaryBlue.withOpacity(0.3),
                              width: 1.5,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryBlue.withOpacity(0.25),
                                blurRadius: 12.r(context),
                                offset: Offset(0, 6.h(context)),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      category['label']!,
                      style: TextStyle(
                        fontSize: 15.sp(context),
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSub,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 32.h(context)),

            // Message Input Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r(context)),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.08),
                    blurRadius: 20.r(context),
                    offset: Offset(0, 8.h(context)),
                  ),
                ],
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 8,
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 15.sp(context),
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.messageHint,
                  hintStyle: TextStyle(
                    color: AppColors.textPlaceholder,
                    fontSize: 15.sp(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r(context)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(20.w(context)),
                ),
              ),
            ),
            SizedBox(height: 32.h(context)),

            // Send Button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r(context)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 20.r(context),
                    offset: Offset(0, 10.h(context)),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSending ? null : _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.symmetric(vertical: 18.h(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r(context)),
                  ),
                  elevation: 0,
                ),
                child: _isSending
                    ? SizedBox(
                        height: 24.h(context),
                        width: 24.w(context),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [       Text(
                            AppStrings.sendMessage,
                            style: TextStyle(
                              fontSize: 17.sp(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12.w(context)),
                          Icon(
                            Icons.send,
                            size: 20.sp(context),
                            color: Colors.white,
                          ),
                   
                        ],
                      ),
              ),
            ),
            SizedBox(height: 20.h(context)),

            // Info Text
            Center(
              child: Text(
                'سيتم فتح تطبيق البريد الإلكتروني لإرسال رسالتك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.sp(context),
                  color: AppColors.textPlaceholder,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

