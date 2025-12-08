import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../shared/widgets/widgets.dart';

/// KYC Selfie Screen - REAL Camera Preview Implementation
/// Shows live camera feed, captures photo, and displays preview
class KycSelfieScreen extends StatefulWidget {
  const KycSelfieScreen({super.key});

  @override
  State<KycSelfieScreen> createState() => _KycSelfieScreenState();
}

class _KycSelfieScreenState extends State<KycSelfieScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _isUploading = false;
  String? _errorMessage;

  // Captured photo data
  XFile? _capturedPhoto;
  Uint8List? _photoBytes; // For cross-platform display

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  /// Initialize camera with front camera (for selfie)
  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    // Request camera permission
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Izin kamera diperlukan untuk mengambil foto selfie.';
      });
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return;
    }

    try {
      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Tidak ada kamera yang tersedia pada perangkat ini.';
        });
        return;
      }

      // Find front camera for selfie, fallback to first camera
      CameraDescription selectedCamera = _cameras!.first;
      for (final camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }

      // Initialize controller
      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Gagal menginisialisasi kamera: ${e.toString()}';
        });
      }
    }
  }

  /// Capture photo from camera
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showMessage('Kamera belum siap', isError: true);
      return;
    }

    if (_isCapturing) return;

    setState(() => _isCapturing = true);

    try {
      final XFile photo = await _cameraController!.takePicture();

      // Read bytes for cross-platform display
      final bytes = await photo.readAsBytes();

      if (mounted) {
        setState(() {
          _capturedPhoto = photo;
          _photoBytes = bytes;
          _isCapturing = false;
        });
        _showMessage('Foto berhasil diambil!', isError: false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        _showMessage('Gagal mengambil foto: ${e.toString()}', isError: true);
      }
    }
  }

  /// Retake photo - go back to camera view
  void _retakePhoto() {
    setState(() {
      _capturedPhoto = null;
      _photoBytes = null;
    });
  }

  /// Submit photo and proceed
  Future<void> _submitPhoto() async {
    if (_capturedPhoto == null) {
      _showMessage('Harap ambil foto terlebih dahulu', isError: true);
      return;
    }

    setState(() => _isUploading = true);

    // Simulate upload
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isUploading = false);
      Navigator.pushNamed(context, '/kyc-success');
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorRed : AppColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text('Verifikasi Identitas'),
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Instructions Header
            Container(
              padding: EdgeInsets.all(responsive.horizontalPadding),
              color: AppColors.black,
              child: Column(
                children: [
                  Text(
                    'Foto Selfie + KTP',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pegang KTP di samping wajah Anda',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Camera Preview or Photo
            Expanded(
              child: _capturedPhoto != null && _photoBytes != null
                  ? _buildPhotoPreview()
                  : _buildCameraPreview(),
            ),

            // Bottom Controls
            Container(
              padding: EdgeInsets.all(responsive.horizontalPadding),
              color: AppColors.black,
              child: _capturedPhoto != null
                  ? _buildPhotoControls()
                  : _buildCameraControls(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build live camera preview
  Widget _buildCameraPreview() {
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryOrange),
            SizedBox(height: 16),
            Text('Memuat kamera...', style: TextStyle(color: AppColors.white)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: AppColors.grayMedium1,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Coba Lagi',
                onPressed: _initializeCamera,
                icon: Icons.refresh,
              ),
            ],
          ),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: Text(
          'Kamera tidak tersedia',
          style: TextStyle(color: AppColors.white),
        ),
      );
    }

    // Live camera preview
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera feed
        ClipRRect(child: CameraPreview(_cameraController!)),

        // Face guide overlay
        Center(
          child: Container(
            width: 250,
            height: 320,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryOrange.withValues(alpha: 0.8),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.face, size: 48, color: AppColors.primaryOrange),
                SizedBox(height: 8),
                Text(
                  'Posisikan wajah\ndi dalam frame',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build photo preview after capture
  Widget _buildPhotoPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Use Image.memory for cross-platform compatibility
        Image.memory(
          _photoBytes!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: 64,
                    color: AppColors.grayMedium1,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gagal menampilkan foto',
                    style: TextStyle(color: AppColors.white),
                  ),
                ],
              ),
            );
          },
        ),

        // Success indicator
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.successGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: AppColors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Foto berhasil',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Camera capture button
  Widget _buildCameraControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Capture button
        GestureDetector(
          onTap: _isCapturing ? null : _capturePhoto,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 4),
            ),
            child: Center(
              child: _isCapturing
                  ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryOrange,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tekan untuk mengambil foto',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  /// Photo preview controls (retake/continue)
  Widget _buildPhotoControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomButton(
          text: 'Lanjutkan',
          onPressed: _isUploading ? null : _submitPhoto,
          isLoading: _isUploading,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Ambil Ulang',
          onPressed: _retakePhoto,
          isOutlined: true,
          icon: Icons.refresh,
        ),
      ],
    );
  }
}
