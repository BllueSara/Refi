import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/scale_button.dart';
import '../../../../core/services/subscription_manager.dart';
import '../../../subscription/presentation/widgets/limit_warning_sheet.dart';
import '../../../quotes/presentation/widgets/quote_review_modal.dart';
import '../cubit/scanner_cubit.dart';
import 'scanning_processing_page.dart';
import '../../../../core/widgets/literary_overlay.dart';

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
  bool _isManualMode = false; // false = اقتباس, true = كتابة

  // Usage Limits
  bool _canScan = true;
  bool _canManual = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _checkUsageLimits();
  }

  Future<void> _checkUsageLimits() async {
    final subManager = SubscriptionManager.instance;
    final canScan = await subManager.canScanImage();
    final canManual = await subManager.canAddManualQuote();

    if (mounted) {
      setState(() {
        _canScan = canScan;
        _canManual = canManual;
      });
    }
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
    if (!_canScan) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const LimitWarningSheet(isScanning: true),
      );
      return;
    }

    if (_cameraController == null || !_isCameraInitialized || _isProcessing)
      return;

    try {
      final XFile image = await _cameraController!.takePicture();
      if (!mounted) return;

      // Crop the image
      final croppedFile = await _cropImage(File(image.path));

      if (croppedFile != null) {
        if (!mounted) return;

        // Trigger the scan
        context.read<ScannerCubit>().scanImageFromPath(croppedFile.path);

        // Await the result from processing page
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanningProcessingPage(
              imagePath: croppedFile.path,
            ),
          ),
        );

        if (!mounted) return;

        if (result is String) {
          // Success: Show Quote Review Page (Full Screen)
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => QuoteReviewModal(initialText: result),
            ),
          );

          // Refresh limits after potential save
          await _checkUsageLimits();
        }
        // If result is false or null, do nothing (user already saw error screen)
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          SizedBox.expand(
            child: _isCameraInitialized
                ? CameraPreview(_cameraController!)
                : const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primaryBlue),
                  ),
          ),

          // Top Bar - X and Flash
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20.w(context),
                vertical: 20.h(context),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30.sp(context),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  IconButton(
                    icon: Icon(
                      _currentFlashMode == FlashMode.off
                          ? Icons.flash_off
                          : Icons.flash_on,
                      color: Colors.white,
                      size: 30.sp(context),
                    ),
                    onPressed: _toggleFlash,
                  ),
                ],
              ),
            ),
          ),

          // Bottom - Capture Button with Mode Toggle on sides
          Positioned(
            bottom: 40.h(context),
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Capture Button - Centered
                GestureDetector(
                  onTap: _onShutterPressed,
                  child: Container(
                    width: 80.w(context),
                    height: 80.h(context),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _canScan ? Colors.white : Colors.grey,
                          width: 4),
                      gradient: _canScan
                          ? AppColors.refiMeshGradient
                          : const LinearGradient(
                              colors: [Colors.grey, Colors.black54]),
                    ),
                    child: !_canScan
                        ? const Icon(Icons.lock, color: Colors.white)
                        : null,
                  ),
                ),
                // كتابة - Left side
                Positioned(
                  left: 20.w(context),
                  child: ScaleButton(
                    onTap: () {
                      if (!_canManual) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              const LimitWarningSheet(isScanning: false),
                        );
                        return;
                      }

                      setState(() {
                        _isManualMode = true;
                      });
                      // Open manual quote modal
                      Future.delayed(
                        const Duration(milliseconds: 150),
                        () async {
                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: const QuoteReviewModal(initialText: ""),
                            ),
                          );
                          // Refresh limits after modal closes (user might have added a quote)
                          if (mounted) {
                            _checkUsageLimits();
                          }
                        },
                      );
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: _isManualMode
                          ? ShaderMask(
                              key: const ValueKey('selected'),
                              shaderCallback: (bounds) =>
                                  AppColors.refiMeshGradient.createShader(
                                Rect.fromLTWH(
                                    0, 0, bounds.width, bounds.height),
                              ),
                              child: Text(
                                "كتابة",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17.sp(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Text(
                              "كتابة",
                              key: const ValueKey('unselected'),
                              style: TextStyle(
                                color: _canManual
                                    ? Colors.white.withOpacity(0.7)
                                    : Colors.grey,
                                fontSize: 16.sp(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                // اقتباس - Right side
                Positioned(
                  right: 20.w(context),
                  child: ScaleButton(
                    onTap: () {
                      setState(() {
                        _isManualMode = false;
                      });
                    },
                    child: _isManualMode
                        ? Text(
                            "اقتباس",
                            key: const ValueKey('unselected'),
                            style: TextStyle(
                              color: _canScan
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.grey,
                              fontSize: 16.sp(context),
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : ShaderMask(
                            key: const ValueKey('selected'),
                            shaderCallback: (bounds) =>
                                AppColors.refiMeshGradient.createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                            child: Text(
                              "اقتباس",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.sp(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
