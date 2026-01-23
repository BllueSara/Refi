import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../library/domain/entities/book_entity.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../../../core/widgets/refi_success_widget.dart';

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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("اختر غلاف الكتاب",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("بحث في الإنترنت"),
                onTap: () {
                  Navigator.pop(context);
                  _searchCoverFromWeb();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("معرض الصور"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("الكاميرا"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _searchCoverFromWeb() {
    showDialog(
      context: context,
      builder: (context) => _WebCoverSearchDialog(
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

  Future<String?> _uploadCover() async {
    if (_imageFile == null) return null;
    try {
      final bytes = await _imageFile!.readAsBytes();
      final fileExt = _imageFile!.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = 'covers/$fileName';
      await Supabase.instance.client.storage
          .from('book_covers')
          .uploadBinary(filePath, bytes);
      return Supabase.instance.client.storage
          .from('book_covers')
          .getPublicUrl(filePath);
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
      finalImageUrl = await _uploadCover();
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
      appBar: AppBar(
        title: const Text(AppStrings.addBookTitle),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 1. Cover
            _buildCoverPicker(),
            const SizedBox(height: 32),
            // 2. Fields
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  _buildTextField(
                      label: AppStrings.bookTitleLabel,
                      hint: AppStrings.enterBookTitle,
                      controller: _titleController,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "عذراً، هذا الحقل مطلوب";
                        }
                        return null;
                      }),
                  const SizedBox(height: 24),
                  _buildTextField(
                      label: AppStrings.authorNameLabel,
                      hint: AppStrings.enterAuthorName,
                      controller: _authorController,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "عذراً، هذا الحقل مطلوب";
                        }
                        return null;
                      }),
                  const SizedBox(height: 24),
                  _buildTextField(
                      label: "عدد صفحات الكتاب",
                      hint: "مثال: 200",
                      controller: _pagesController,
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
                      }),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. Status
            _buildStatusSection(),
            const SizedBox(height: 48),
            // 5. Save Button
            _isSaving
                ? const CircularProgressIndicator()
                : _buildSaveButtonUI(
                    label: AppStrings.saveBook, onTap: _saveBook),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPicker() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          image: (_imageFile != null || _webImageUrl != null)
              ? DecorationImage(
                  image: _imageFile != null
                      ? FileImage(_imageFile!) as ImageProvider
                      : NetworkImage(_webImageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: (_imageFile == null && _webImageUrl == null)
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo,
                        size: 48, color: AppColors.primaryBlue),
                    const SizedBox(height: 16),
                    Text(AppStrings.addBookCover,
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required String hint,
      required TextEditingController controller,
      bool isNumber = false,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: validator,
          inputFormatters:
              isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
          decoration: InputDecoration(
            hintText: hint,
            // Proper Error Styling
            errorStyle: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFD32F2F),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
            ),
            // Default Styling
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: AppColors.inputBorder.withOpacity(0.5), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: AppColors.inputBorder.withOpacity(0.5), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    // Order: Wishlist -> Reading -> Finished
    final list = [
      BookStatus.wishlist,
      BookStatus.reading,
      BookStatus.completed,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.readingStatusLabel,
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: AppColors.inputBorder.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24)),
          child: Row(
            children: list.map((s) {
              final sel = _readingStatus == s;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _readingStatus = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        gradient: sel ? AppColors.refiMeshGradient : null,
                        borderRadius: BorderRadius.circular(20)),
                    alignment: Alignment.center,
                    child: Text(s.label,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: sel ? Colors.white : AppColors.textSub)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButtonUI(
      {required String label, required VoidCallback onTap}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
          gradient: AppColors.refiMeshGradient,
          borderRadius: BorderRadius.circular(24)),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24))),
        child: Text(label,
            style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white)),
      ),
    );
  }
}

class _WebCoverSearchDialog extends StatefulWidget {
  final String initialQuery;
  final Function(String) onImageSelected;
  const _WebCoverSearchDialog(
      {required this.initialQuery, required this.onImageSelected});
  @override
  State<_WebCoverSearchDialog> createState() => _WebCoverSearchDialogState();
}

class _WebCoverSearchDialogState extends State<_WebCoverSearchDialog> {
  final TextEditingController _ctrl = TextEditingController();
  List<String> _res = [];
  bool _load = false;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) _search(widget.initialQuery);
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: _ctrl,
                decoration: const InputDecoration(
                    hintText: "ابحث عن غلاف", prefixIcon: Icon(Icons.search)),
                onSubmitted: _search),
            const SizedBox(height: 16),
            SizedBox(
                height: 300,
                child: _load
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8),
                        itemCount: _res.length,
                        itemBuilder: (c, i) => GestureDetector(
                            onTap: () => widget.onImageSelected(_res[i]),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child:
                                    Image.network(_res[i], fit: BoxFit.cover))),
                      )),
          ],
        ),
      ),
    );
  }
}
