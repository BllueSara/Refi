import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../library/domain/entities/book_entity.dart';
import '../../../library/presentation/cubit/library_cubit.dart';
import '../../../auth/presentation/widgets/refi_auth_field.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  // Tags
  final List<String> _tags = [
    AppStrings.catPhilosophy,
    AppStrings.catNovel,
    AppStrings.catHistory,
    AppStrings.catSelfHelp,
  ];
  String _selectedTag = AppStrings.catPhilosophy;

  // Reading Status
  String _readingStatus = AppStrings.statusReading;

  // Form Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();

  // Image Handling
  File? _imageFile;
  String? _webImageUrl;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70, // Optimize size
      maxWidth: 600,
    );
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _webImageUrl = null; // Reset web image if local picked
      });
    }
  }

  Future<void> _searchCoverFromWeb() async {
    // Quick dialog to show results
    showDialog(
      context: context,
      builder: (context) => _WebCoverSearchDialog(
        initialQuery: _titleController.text,
        onImageSelected: (url) {
          setState(() {
            _webImageUrl = url;
            _imageFile = null; // Reset local image if web picked
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "اختر غلاف الكتاب",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.search, color: AppColors.primaryBlue),
                title: const Text("بحث في الإنترنت"),
                onTap: () {
                  Navigator.pop(context);
                  _searchCoverFromWeb();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.primaryBlue,
                ),
                title: const Text("معرض الصور"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primaryBlue,
                ),
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

  Future<String?> _uploadImageToSupabase() async {
    if (_imageFile == null) return null;
    try {
      final bytes = await _imageFile!.readAsBytes();
      final fileExt = _imageFile!.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = 'covers/$fileName';

      // Assume bucket 'book_covers' exists.
      // If not, this might fail, but it's the standard way.
      await Supabase.instance.client.storage
          .from('book_covers')
          .uploadBinary(filePath, bytes);

      final imageUrl = Supabase.instance.client.storage
          .from('book_covers')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      debugPrint("Upload Failed: $e");
      // Fallback: Return null or handle error
      return null;
    }
  }

  Future<void> _saveBook() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("عنوان الكتاب مطلوب")));
      return;
    }

    setState(() => _isUploading = true);

    String? finalImageUrl = _webImageUrl;

    // Upload if local file exists
    if (_imageFile != null) {
      final uploadedUrl = await _uploadImageToSupabase();
      if (uploadedUrl != null) {
        finalImageUrl = uploadedUrl;
      }
    }

    final book = BookEntity(
      id: '', // Will be generated or handled by backend duplicate check
      title: _titleController.text,
      authors: [
        _authorController.text.isEmpty ? "Unknown" : _authorController.text,
      ],
      imageUrl: finalImageUrl,
      // Map status string to Enum
      status: _readingStatus == AppStrings.statusReading
          ? BookStatus.reading
          : _readingStatus == AppStrings.statusFinished
              ? BookStatus.completed
              : BookStatus.wishlist,
      currentPage: 0,
      // Store category in description or we need a tag field in Entity?
      // For now, simpler to ignore or append to description if Entity doesn't support tags directly yet
    );

    if (mounted) {
      context.read<LibraryCubit>().addBook(book);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          AppStrings.addBookTitle,
          style: TextStyle(
            //fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Upload Container
            GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.inputBorder,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
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
                    ? CustomPaint(
                        painter: _DashedBorderPainter(
                          color: AppColors.secondaryBlue,
                          strokeWidth: 2,
                          gap: 5,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              AppStrings.addBookCover,
                              style: TextStyle(
                                //fontFamily: 'Tajawal',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              AppStrings.clickToUpload,
                              style: TextStyle(
                                //fontFamily: 'Tajawal',
                                fontSize: 14,
                                color: AppColors.textPlaceholder,
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 32),

            // Book Title
            RefiAuthField(
              label: AppStrings.bookTitleLabel,
              hintText: AppStrings.enterBookTitle,
              controller: _titleController,
            ),

            const SizedBox(height: 24),

            // Author Name
            RefiAuthField(
              label: AppStrings.authorNameLabel,
              hintText: AppStrings.enterAuthorName,
              controller: _authorController,
            ),

            const SizedBox(height: 32),

            // Categories
            const Text(
              AppStrings.categoryLabel,
              style: TextStyle(
                //fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _tags.map((tag) {
                final isSelected = _selectedTag == tag;
                return ChoiceChip(
                  label: Text(tag),
                  labelStyle: TextStyle(
                    //fontFamily: 'Tajawal',
                    color: isSelected ? Colors.white : AppColors.textSub,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primaryBlue,
                  backgroundColor: AppColors.inputBorder,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  side: BorderSide.none,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedTag = tag);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Reading Status
            const Text(
              AppStrings.readingStatusLabel,
              style: TextStyle(
                //fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inputBorder,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatusSegment(AppStrings.statusFinished),
                  ),
                  Expanded(
                    child: _buildStatusSegment(AppStrings.statusWantToRead),
                  ),
                  Expanded(
                    child: _buildStatusSegment(AppStrings.statusReading),
                  ), // Default selected
                ],
              ),
            ),

            const SizedBox(height: 48),

            // Save Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.refiMeshGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isUploading ? null : _saveBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        AppStrings.saveBook,
                        style: TextStyle(
                          //fontFamily: 'Tajawal',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSegment(String status) {
    final isSelected = _readingStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() => _readingStatus = status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          gradient: isSelected ? AppColors.refiMeshGradient : null,
        ),
        alignment: Alignment.center,
        child: Text(
          status,
          style: TextStyle(
            //fontFamily: 'Tajawal',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textSub,
          ),
        ),
      ),
    );
  }
}

class _WebCoverSearchDialog extends StatefulWidget {
  final String initialQuery;
  final Function(String) onImageSelected;

  const _WebCoverSearchDialog({
    required this.initialQuery,
    required this.onImageSelected,
  });

  @override
  State<_WebCoverSearchDialog> createState() => _WebCoverSearchDialogState();
}

class _WebCoverSearchDialogState extends State<_WebCoverSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<BookEntity> _results = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    if (widget.initialQuery.isNotEmpty) {
      _search(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);

    final url = Uri.parse(
      'https://www.google.com/search?q=$query&tbm=isch&safe=active',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        final imgRegex = RegExp(
          r'src="(https://encrypted-tbn[0-9]\.gstatic\.com/images\?q=[^"]*)"',
        );
        final matches = imgRegex.allMatches(response.body);

        final List<BookEntity> results = matches.map((match) {
          final imageUrl = match.group(1);
          return BookEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'صورة من قوقل',
            authors: [],
            imageUrl: imageUrl,
            status: BookStatus.none,
            currentPage: 0,
          );
        }).toList();

        final distinctResults = <String, BookEntity>{};
        for (var item in results) {
          if (item.imageUrl != null) {
            distinctResults[item.imageUrl!] = item;
          }
        }

        setState(() {
          _results = distinctResults.values.take(30).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Google Search Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("بحث عن غلاف", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "ابحث عن كتاب...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: _search,
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 300,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? "أدخل كلمة للبحث"
                                : "لم يتم العثور على نتائج",
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => widget
                                  .onImageSelected(_results[index].imageUrl!),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _results[index].imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                          child: Icon(Icons.broken_image)),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    _drawingDashedBorder(canvas, size, paint);
  }

  void _drawingDashedBorder(Canvas canvas, Size size, Paint paint) {
    paint.color = color.withValues(alpha: 0.5); // make it subtle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(24),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
