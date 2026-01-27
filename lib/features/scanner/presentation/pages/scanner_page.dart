import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../quotes/presentation/widgets/quote_review_modal.dart';
import '../cubit/scanner_cubit.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  FlashMode _currentFlashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final camera = cameras[0];
        _cameraController = CameraController(
          camera,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم العثور على الكاميرا')),
          );
        }
      }
    } catch (e) {
      debugPrint("Camera error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تشغيل الكاميرا: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) return;

    try {
      FlashMode newFlashMode =
          _currentFlashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;

      await _cameraController!.setFlashMode(newFlashMode);
      setState(() {
        _currentFlashMode = newFlashMode;
      });
    } catch (e) {
      debugPrint("Could not toggle flash: $e");
    }
  }

  Future<void> _onShutterPressed() async {
    if (_cameraController == null || !_isCameraInitialized || _isProcessing)
      return;

    // Do not show full blocking loader yet, just block button interaction via _isProcessing check if needed,
    // but the user wants to see the cropper immediately without "Processing..." overlay.
    // We will simple capture and await.

    try {
      final XFile image = await _cameraController!.takePicture();
      if (!mounted) return;

      // Crop the image
      final croppedFile = await _cropImage(File(image.path));

      if (croppedFile != null) {
        // Only show processing AFTER crop is confirmed
        setState(() => _isProcessing = true);

        if (!mounted) return;
        context.read<ScannerCubit>().scanImageFromPath(croppedFile.path);
      }
      // If cancelled (croppedFile == null), we just stay on camera, no processing state needed.
    } catch (e) {
      debugPrint("Error capturing/cropping: $e");
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }

  Future<CroppedFile?> _cropImage(File imageFile) async {
    return await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressQuality: 100, // We handle compression later in service
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'قص النص',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'قص النص',
        ),
      ],
    );
  }

  void _onScanSuccess(String text) {
    setState(() => _isProcessing = false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: QuoteReviewModal(initialText: text),
      ),
    );
  }

  void _onScanFailure(String message) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerCubit, ScannerState>(
      listener: (context, state) {
        if (state is ScannerSuccess) {
          _onScanSuccess(state.text);
        } else if (state is ScannerFailure) {
          _onScanFailure(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Camera Preview
            SizedBox.expand(
              child: _isCameraInitialized
                  ? CameraPreview(_cameraController!)
                  : const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primaryBlue),
                    ),
            ),

            // Minimal Overlay
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: Icon(
                            _currentFlashMode == FlashMode.off
                                ? Icons.flash_off
                                : Icons.flash_on,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: _toggleFlash,
                        ),
                      ],
                    ),
                  ),
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
            ),

            // 2. Dark Overlay
            Container(color: Colors.black.withValues(alpha: 0.4)),

            // 3. Top Bar
            Positioned(
              top: 60.h(context),
              left: 20.w(context),
              right: 20.w(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28.sp(context),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    AppStrings.scanPointCamera,
                    style: TextStyle(
                      //fontFamily: 'Tajawal',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp(context),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _currentFlashMode == FlashMode.off
                          ? Icons.flash_off
                          : _currentFlashMode == FlashMode.auto
                              ? Icons.flash_auto
                              : Icons.flash_on,
                      color: Colors.white,
                      size: 28.sp(context),
                    ),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),

                  // Bottom Bar (Shutter)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Center(
                      child: GestureDetector(
                        onTap: _onShutterPressed,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          child: const Icon(Icons.camera,
                              color: Colors.transparent),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            // 4. Scanning Frame (Center)
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Stack(
                  children: [
                    // Corners
                    _buildCorner(context, top: true, left: true),
                    _buildCorner(context, top: true, left: false),
                    _buildCorner(context, top: false, left: true),
                    _buildCorner(context, top: false, left: false),

                    // Text Highlights (Simulated Blue Overlays)
                    Positioned(
                      top: 100.h(context),
                      left: 20.w(context),
                      right: 40.w(context),
                      child: Container(
                        height: 20.h(context),
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    Positioned(
                      top: 130.h(context),
                      left: 30.w(context),
                      right: 20.w(context),
                      child: Container(
                        height: 20.h(context),
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    Positioned(
                      top: 180.h(context),
                      left: 20.w(context),
                      right: 20.w(context),
                      child: Container(
                        height: 20.h(context),
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Loading Overlay
            if (_isProcessing)
              Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: const Center(
                  child: Column(
            // 5. Status Toast
            Positioned(
              bottom: 200.h(context),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w(context),
                    vertical: 10.h(context),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(30.r(context)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryBlue),
                      SizedBox(height: 20),
                      Text(
                        "جاري معالجة الاقتباس...",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 8.w(context),
                          height: 8.h(context),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w(context)),
                      Text(
                        AppStrings.scanDetecting,
                        style: TextStyle(
                          //fontFamily: 'Tajawal',
                          color: Colors.white,
                          fontSize: 14.sp(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 6. Controls & Mode Switcher
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(bottom: 40.h(context), top: 20.h(context)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Shutter Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 28.sp(context),
                          ),
                          onPressed: () {
                            context.read<ScannerCubit>().scanImage(
                                  ImageSource.gallery,
                                );
                          },
                        ),
                        GestureDetector(
                          onTap: _onShutterPressed,
                          child: Container(
                            width: 80.w(context),
                            height: 80.h(context),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              gradient: AppColors.refiMeshGradient,
                            ),
                            child: const Icon(
                              Icons.camera,
                              color: Colors.transparent,
                            ), // Just circle
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 28.sp(context),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h(context)),
                    // Mode Switcher
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildModeItem(context, AppStrings.modeFile, 0),
                        SizedBox(width: 24.w(context)),
                        _buildModeItem(context, AppStrings.modeQuote, 1),
                        SizedBox(width: 24.w(context)),
                        _buildModeItem(context, AppStrings.modeTranslate, 2),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeItem(BuildContext context, String label, int index) {
    final isSelected = _selectedModeIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedModeIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              //fontFamily: 'Tajawal',
              color: isSelected ? AppColors.secondaryBlue : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp(context),
            ),
          ),
          if (isSelected)
            Container(
              margin: EdgeInsets.only(top: 4.h(context)),
              width: 4.w(context),
              height: 4.h(context),
              decoration: const BoxDecoration(
                color: AppColors.secondaryBlue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCorner(BuildContext context, {required bool top, required bool left}) {
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: 40.w(context),
        height: 40.h(context),
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? BorderSide(color: AppColors.secondaryBlue, width: 4)
                : BorderSide.none,
            bottom: top
                ? BorderSide.none
                : BorderSide(color: AppColors.secondaryBlue, width: 4),
            left: left
                ? BorderSide(color: AppColors.secondaryBlue, width: 4)
                : BorderSide.none,
            right: left
                ? BorderSide.none
                : BorderSide(color: AppColors.secondaryBlue, width: 4),
          ),
          borderRadius: BorderRadius.only(
            topLeft: (top && left) ? Radius.circular(16.r(context)) : Radius.zero,
            topRight: (top && !left) ? Radius.circular(16.r(context)) : Radius.zero,
            bottomLeft:
                (!top && left) ? Radius.circular(16.r(context)) : Radius.zero,
            bottomRight:
                (!top && !left) ? Radius.circular(16.r(context)) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
