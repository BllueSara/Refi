import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../library/domain/entities/book_entity.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../../../core/widgets/refi_success_widget.dart';
import '../widgets/book_cover_picker.dart';
import '../widgets/book_form_text_field.dart';
import '../widgets/book_status_selector.dart';
import '../widgets/save_book_button.dart';
import '../widgets/image_source_bottom_sheet.dart';
import '../widgets/web_cover_search_dialog.dart';

class ManualEntryScreen extends StatefulWidget {
  final BookEntity? book;
  const ManualEntryScreen({super.key, this.book});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  // Config

  BookStatus _readingStatus = BookStatus.wishlist;

  // Validation
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _pagesController;

  // State
  File? _imageFile;
  String? _webImageUrl;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.title);
    _authorController =
        TextEditingController(text: widget.book?.authors.firstOrNull);
    _pagesController =
        TextEditingController(text: widget.book?.pageCount?.toString());
    if (widget.book != null) {
      _readingStatus = widget.book!.status;
      _webImageUrl = widget.book!.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();

    super.dispose();
  }

  // Logic
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
        source: source, imageQuality: 70, maxWidth: 600);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _webImageUrl = null;
      });
    }
  }

  void _showImageSourceSheet() {
    ImageSourceBottomSheet.show(
      context,
      onWebSearch: _searchCoverFromWeb,
      onGalleryPick: () => _pickImage(ImageSource.gallery),
      onCameraPick: () => _pickImage(ImageSource.camera),
    );
  }

  void _searchCoverFromWeb() {
    showDialog(
      context: context,
      builder: (context) => WebCoverSearchDialog(
        initialQuery: _titleController.text,
        onImageSelected: (url) {
          setState(() {
            _webImageUrl = url;
            _imageFile = null;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _deleteOldCover(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;

    try {
      const bucketName = 'book_covers';
      const publicPath = '/storage/v1/object/public/$bucketName/';

      if (!imageUrl.contains(publicPath)) {
        return;
      }

      final uri = Uri.parse(imageUrl);
      final fullPath = uri.path;

      final pathIndex = fullPath.indexOf(publicPath);
      if (pathIndex == -1) {
        return;
      }

      final filePath = fullPath.substring(pathIndex + publicPath.length);
      if (filePath.isEmpty) {
        return;
      }

      await Supabase.instance.client.storage
          .from(bucketName)
          .remove([filePath]);
    } catch (e) {
      // Silently fail - old image deletion is not critical
    }
  }

  Future<String?> _uploadCover() async {
    if (_imageFile == null) return null;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('يجب تسجيل الدخول أولاً');
      }

      final compressedFile = await _compressImage(_imageFile!);
      if (compressedFile == null) {
        throw Exception('فشل ضغط الصورة');
      }

      final bytes = await compressedFile.readAsBytes();
      final fileExt = 'jpg';
      final userId = user.id;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${userId.substring(0, 8)}.$fileExt';
      final filePath = 'covers/$fileName';

      const bucketName = 'book_covers';

      await Supabase.instance.client.storage.from(bucketName).uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
            ),
          );

      final publicUrl = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      try {
        await compressedFile.delete();
      } catch (_) {}

      return publicUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في رفع الصورة: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  Future<File?> _compressImage(File imageFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: 800,
        minHeight: 800,
        quality: 85,
      );

      if (compressedBytes == null) return null;

      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    String? finalImageUrl = _webImageUrl;

    if (_imageFile != null) {
      if (widget.book != null && widget.book!.imageUrl != null) {
        await _deleteOldCover(widget.book!.imageUrl);
      }

      finalImageUrl = await _uploadCover();
      if (finalImageUrl == null) {
        setState(() => _isSaving = false);
        return;
      }
    }

    final book = BookEntity(
      id: widget.book?.id ?? '',
      title: _titleController.text,
      authors: [
        _authorController.text.isEmpty ? "Unknown" : _authorController.text
      ],
      imageUrl: finalImageUrl,
      status: _readingStatus,
      currentPage: widget.book?.currentPage ?? 0,
      pageCount: int.tryParse(_pagesController.text),
      categories: widget.book?.categories ?? [],
      googleBookId: widget.book?.googleBookId,
      source: widget.book?.source ?? 'manual',
    );

    if (widget.book != null) {
      await context.read<LibraryCubit>().updateBook(book);
    } else {
      await context.read<LibraryCubit>().addBook(book);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      _showSuccessScreen();
    }
  }

  void _showSuccessScreen() {
    HapticFeedback.heavyImpact();
    final isEdit = widget.book != null;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => RefiSuccessWidget(
          title: isEdit ? "تم تحديث الكتاب بنجاح!" : "تمت إضافة الكتاب بنجاح!",
          subtitle: isEdit
              ? "تم حفظ التعديلات الجديدة في مكتبتك الخاصة"
              : "أصبح الكتاب الآن جزءاً من رحلتك المعرفية المثرية",
          primaryButtonLabel: isEdit ? "العودة للمكتبة" : "إضافة كتاب آخر",
          onPrimaryAction: () {
            if (isEdit) {
              Navigator.of(ctx).pop(); // Back to details/library
            } else {
              Navigator.of(ctx).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ManualEntryScreen(),
                ),
              );
            }
          },
          secondaryButtonLabel: "العودة للرئيسية",
          onSecondaryAction: () {
            // Pop until we reach main screen
            final nav = Navigator.of(ctx);
            nav.pop(); // Pop SuccessWidget
            if (nav.canPop()) {
              nav.pop(); // Pop previous screen (Search or BookDetails)
            }
          },
        ),
      ),
    );
  }

  // --- UI Builders ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        title: Text(
          widget.book != null ? "تعديل الكتاب" : AppStrings.addBookTitle,
          style: GoogleFonts.tajawal(
            fontSize: 20.sp(context),
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.back,
                color: AppColors.textMain,
                size: 28.sp(context),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: 24.w(context), vertical: 20.h(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              if (widget.book == null) ...[
                Text(
                  "ابدأ بإضافة تفاصيل كتابك",
                  style: GoogleFonts.tajawal(
                    fontSize: 24.sp(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                SizedBox(height: 8.h(context)),
                Text(
                  "املأ المعلومات التالية لإضافة كتاب جديد إلى مكتبتك",
                  style: GoogleFonts.tajawal(
                    fontSize: 14.sp(context),
                    color: AppColors.textSub,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h(context)),
              ],

              // 1. Cover Section
              BookCoverPicker(
                imageFile: _imageFile,
                webImageUrl: _webImageUrl,
                onTap: _showImageSourceSheet,
              ),
              SizedBox(height: 32.h(context)),

              // 2. Form Fields
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookFormTextField(
                      label: AppStrings.bookTitleLabel,
                      hint: AppStrings.enterBookTitle,
                      controller: _titleController,
                      icon: Icons.menu_book_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "عذراً، هذا الحقل مطلوب";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h(context)),
                    BookFormTextField(
                      label: AppStrings.authorNameLabel,
                      hint: AppStrings.enterAuthorName,
                      controller: _authorController,
                      icon: Icons.person_outline_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "عذراً، هذا الحقل مطلوب";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h(context)),
                    BookFormTextField(
                      label: "عدد صفحات الكتاب",
                      hint: "مثال: 200",
                      controller: _pagesController,
                      icon: Icons.numbers_rounded,
                      isNumber: true,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "يرجى إدخال عدد الصفحات";
                        }
                        final count = int.tryParse(val);
                        if (count == null) {
                          return "يرجى إدخال أرقام فقط";
                        }
                        if (count <= 0) {
                          return "عدد الصفحات يجب أن يكون أكبر من صفر";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h(context)),

              // 3. Status Section
              BookStatusSelector(
                selectedStatus: _readingStatus,
                onStatusChanged: (status) {
                  setState(() => _readingStatus = status);
                },
              ),
              SizedBox(height: 48.h(context)),

              // 4. Save Button
              _isSaving
                  ? Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 3.w(context),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryBlue),
                          ),
                          SizedBox(height: 16.h(context)),
                          Text(
                            "جاري الحفظ...",
                            style: GoogleFonts.tajawal(
                              fontSize: 14.sp(context),
                              color: AppColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SaveBookButton(
                      label: widget.book != null
                          ? "حفظ التعديلات"
                          : AppStrings.saveBook,
                      onTap: _saveBook,
                      isEdit: widget.book != null,
                    ),
              SizedBox(height: 24.h(context)),
            ],
          ),
        ),
      ),
    );
  }
}
