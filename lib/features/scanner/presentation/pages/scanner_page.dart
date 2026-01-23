import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/colors.dart';
import '../../../quotes/presentation/widgets/quote_review_modal.dart';

import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/scanner_cubit.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _selectedModeIndex = 1; // 0: File, 1: Quote (Default), 2: Translate

  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  FlashMode _currentFlashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(_pulseController);

    _initializeCamera();

    // Simulate detecting text after 3 seconds for demo ? Or leave it manual trigger
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

        // Set initial flash mode
        // The camera plugin will handle errors gracefully if flash is not available
        try {
          await _cameraController!.setFlashMode(_currentFlashMode);
          debugPrint(
              "Flash mode set to ${_currentFlashMode} on camera initialization");
        } catch (e) {
          debugPrint(
              "Could not set flash mode (flash may not be available): $e");
        }

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        debugPrint("No cameras found");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم العثور على الكاميرا')),
          );
        }
      }
    } catch (e) {
      debugPrint("Camera error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تشغيل الكاميرا: $e')));
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  void _onShutterPressed() async {
    if (_cameraController == null || !_isCameraInitialized || _isProcessing) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Use the current flash mode setting (user can toggle it)
      // The camera plugin will handle errors gracefully if flash is not available
      try {
        await _cameraController!.setFlashMode(_currentFlashMode);
        debugPrint("Flash set to ${_currentFlashMode} before capture");
        // Wait to ensure the flash mode is applied
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        debugPrint("Could not set flash mode (flash may not be available): $e");
      }

      // Take picture
      final XFile image = await _cameraController!.takePicture();
      debugPrint("Picture taken: ${image.path}");

      // Restore flash mode after capture (workaround for some Android devices)
      try {
        await _cameraController!.setFlashMode(_currentFlashMode);
        debugPrint("Flash restored to ${_currentFlashMode} after capture");
      } catch (e) {
        debugPrint("Could not set flash mode after capture: $e");
      }

      if (!mounted) return;

      // Use ScannerCubit to scan
      context.read<ScannerCubit>().scanImageFromPath(image.path);
    } catch (e) {
      debugPrint("Error taking picture: $e");
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في التصوير: $e')));
    }
  }

  void _onScanSuccess(String text) {
    setState(() => _isProcessing = false);
    // Show Quote Review Modal
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_isCameraInitialized) {
      return;
    }

    try {
      // Cycle through flash modes: off -> auto -> on -> off
      FlashMode newFlashMode;
      switch (_currentFlashMode) {
        case FlashMode.off:
          newFlashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newFlashMode = FlashMode.always;
          break;
        case FlashMode.always:
        case FlashMode.torch:
          newFlashMode = FlashMode.off;
          break;
      }

      await _cameraController!.setFlashMode(newFlashMode);
      setState(() {
        _currentFlashMode = newFlashMode;
      });
      debugPrint("Flash mode changed to: $newFlashMode");
    } catch (e) {
      debugPrint("Could not toggle flash mode: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن تغيير وضع الفلاش'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
            // 1. Camera Viewfinder
            SizedBox.expand(
              child: _isCameraInitialized
                  ? CameraPreview(_cameraController!)
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
              top: 60,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    AppStrings.scanPointCamera,
                    style: TextStyle(
                      //fontFamily: 'Tajawal',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
                      size: 28,
                    ),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),

            // 4. Scanning Frame (Center)
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                child: Stack(
                  children: [
                    // Corners
                    _buildCorner(top: true, left: true),
                    _buildCorner(top: true, left: false),
                    _buildCorner(top: false, left: true),
                    _buildCorner(top: false, left: false),

                    // Text Highlights (Simulated Blue Overlays)
                    Positioned(
                      top: 100,
                      left: 20,
                      right: 40,
                      child: Container(
                        height: 20,
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    Positioned(
                      top: 130,
                      left: 30,
                      right: 20,
                      child: Container(
                        height: 20,
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    Positioned(
                      top: 180,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 20,
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Status Toast
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        AppStrings.scanDetecting,
                        style: TextStyle(
                          //fontFamily: 'Tajawal',
                          color: Colors.white,
                          fontSize: 14,
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
                padding: const EdgeInsets.only(bottom: 40, top: 20),
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
                          icon: const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 28,
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
                            width: 80,
                            height: 80,
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
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Mode Switcher
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildModeItem(AppStrings.modeFile, 0),
                        const SizedBox(width: 24),
                        _buildModeItem(AppStrings.modeQuote, 1),
                        const SizedBox(width: 24),
                        _buildModeItem(AppStrings.modeTranslate, 2),
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

  Widget _buildModeItem(String label, int index) {
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
              fontSize: 16,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.secondaryBlue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool top, required bool left}) {
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: left ? 0 : null,
      right: left ? null : 0,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: top
                ? const BorderSide(color: AppColors.secondaryBlue, width: 4)
                : BorderSide.none,
            bottom: top
                ? BorderSide.none
                : const BorderSide(color: AppColors.secondaryBlue, width: 4),
            left: left
                ? const BorderSide(color: AppColors.secondaryBlue, width: 4)
                : BorderSide.none,
            right: left
                ? BorderSide.none
                : const BorderSide(color: AppColors.secondaryBlue, width: 4),
          ),
          borderRadius: BorderRadius.only(
            topLeft: (top && left) ? const Radius.circular(16) : Radius.zero,
            topRight: (top && !left) ? const Radius.circular(16) : Radius.zero,
            bottomLeft:
                (!top && left) ? const Radius.circular(16) : Radius.zero,
            bottomRight:
                (!top && !left) ? const Radius.circular(16) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
