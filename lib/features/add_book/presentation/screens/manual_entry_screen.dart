import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/main_navigation_screen.dart';
import '../../../library/domain/entities/book_entity.dart';
import '../../../library/presentation/cubit/library_cubit.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  // Config
  final List<String> _availableTags = [
    AppStrings.catPhilosophy,
    AppStrings.catNovel,
    AppStrings.catHistory,
    AppStrings.catSelfHelp,
  ];
  final List<String> _selectedTags = [];
  String _readingStatus =
      AppStrings.statusWantToRead; // Want to Read -> Reading -> Finished

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _pagesController = TextEditingController();
  final TextEditingController _customCategoryController =
      TextEditingController();

  // State
  File? _imageFile;
  String? _webImageUrl;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    _customCategoryController.dispose();
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
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("عنوان الكتاب مطلوب")));
      return;
    }

    setState(() => _isSaving = true);

    String? finalImageUrl = _webImageUrl;
    if (_imageFile != null) {
      finalImageUrl = await _uploadCover();
    }

    final book = BookEntity(
      id: '',
      title: _titleController.text,
      authors: [
        _authorController.text.isEmpty ? "Unknown" : _authorController.text
      ],
      imageUrl: finalImageUrl,
      status: _readingStatus == AppStrings.statusReading
          ? BookStatus.reading
          : _readingStatus == AppStrings.statusFinished
              ? BookStatus.completed
              : BookStatus.wishlist,
      currentPage: 0,
      pageCount: int.tryParse(_pagesController.text),
      categories: _selectedTags,
    );

    await context.read<LibraryCubit>().addBook(book);

    if (mounted) {
      setState(() => _isSaving = false);
      _showSuccessScreen();
    }
  }

  void _showSuccessScreen() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => Scaffold(
          body: Stack(
            children: [
              Positioned(
                  top: 56,
                  right: 24,
                  child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx))),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('assets/images/Success.json',
                        width: 250, height: 250),
                    const SizedBox(height: 32),
                    Text("تمت إضافة الكتاب بنجاح!",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    Text("أصبح الكتاب الآن جزءاً من رحلتك المعرفية",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 48),
                    _buildSaveButtonUI(
                        label: "ابدأ القراءة الآن",
                        onTap: () {
                          Navigator.pop(ctx);
                          final mainNavState = context.findAncestorStateOfType<
                              State<MainNavigationScreen>>();
                          if (mainNavState != null)
                            (mainNavState as dynamic).changeTab(1);
                        }),
                  ],
                ),
              ),
            ],
          ),
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
            _buildTextField(
                label: AppStrings.bookTitleLabel,
                hint: AppStrings.enterBookTitle,
                controller: _titleController),
            const SizedBox(height: 24),
            _buildTextField(
                label: AppStrings.authorNameLabel,
                hint: AppStrings.enterAuthorName,
                controller: _authorController),
            const SizedBox(height: 24),
            _buildTextField(
                label: "عدد صفحات الكتاب",
                hint: "مثال: 200",
                controller: _pagesController,
                isNumber: true),
            const SizedBox(height: 32),
            // 3. Categories
            _buildTagsSection(),
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
      bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters:
              isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.categoryLabel,
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._availableTags.map((tag) => ChoiceChip(
                  label: Text(tag),
                  selected: _selectedTags.contains(tag),
                  onSelected: (val) {
                    setState(() {
                      if (val)
                        _selectedTags.add(tag);
                      else
                        _selectedTags.remove(tag);
                    });
                  },
                )),
            IconButton(
                icon:
                    const Icon(Icons.add_circle, color: AppColors.primaryBlue),
                onPressed: _showAddTagDialog),
          ],
        ),
      ],
    );
  }

  void _showAddTagDialog() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text("إضافة تصنيف"),
              content: TextField(
                  controller: _customCategoryController,
                  decoration: const InputDecoration(hintText: "اسم التصنيف")),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("إلغاء")),
                ElevatedButton(
                    onPressed: () {
                      if (_customCategoryController.text.isNotEmpty) {
                        setState(() {
                          _availableTags.add(_customCategoryController.text);
                          _selectedTags.add(_customCategoryController.text);
                        });
                        _customCategoryController.clear();
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text("إضافة")),
              ],
            ));
  }

  Widget _buildStatusSection() {
    final list = [
      AppStrings.statusWantToRead,
      AppStrings.statusReading,
      AppStrings.statusFinished
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
                    child: Text(s,
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
