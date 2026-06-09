import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../services/ocr_service.dart';
import '../../expenses/controllers/expense_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/localization/translations.dart';
import '../../../core/widgets/custom_app_bar.dart';

class OcrScannerScreen extends ConsumerStatefulWidget {
  const OcrScannerScreen({super.key});

  @override
  ConsumerState<OcrScannerScreen> createState() => _OcrScannerScreenState();
}

class _OcrScannerScreenState extends ConsumerState<OcrScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanPositionAnimation;

  File? _imageFile;
  bool _isScanning = false;
  OcrScanResult? _scanResult;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _scanPositionAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Loop scan line
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _scanResult = null;
      });
      _startHolographicScan();
    }
  }

  void _startHolographicScan() async {
    if (_imageFile == null) return;

    setState(() {
      _isScanning = true;
    });
    _animationController.forward();

    // OCR Analysis
    final ocr = OcrService();
    final result = await ocr.scanReceipt(_imageFile!);

    _animationController.stop();
    setState(() {
      _isScanning = false;
      _scanResult = result;
    });
  }

  void _confirmAndSave() async {
    if (_scanResult == null) return;

    final user = ref.read(authControllerProvider).user;
    final addedByName = user?.displayName ?? 'Dad';
    final addedBy = user?.id;

    // Save
    final success = await ref
        .read(expenseControllerProvider.notifier)
        .addExpense(
          amount: _scanResult!.amount,
          category: _scanResult!.category,
          description: _scanResult!.description,
          date: _scanResult!.date,
          addedByName: addedByName,
          addedBy: addedBy,
          receiptUrl:
              'https://via.placeholder.com/800x600.png?text=Demo+Receipt', // Simulated receipt URL
          paymentMethod: 'cash',
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('ocrSuccess', ref)),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('ocrTitle', ref),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkBackground, Color(0xFF14151F)]
                : [AppColors.lightBackground, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0.w),
          child: Column(
            children: [
              // SCANNER HOLOGRAPHIC CONTAINER
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Backdrop / Camera Placeholder
                      Container(
                        color: Colors.black,
                        width: double.infinity,
                        height: double.infinity,
                        child: _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 64,
                                    color: Colors.grey[700],
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    context.tr('cameraInstruction', ref),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      // Holographic scan lines
                      if (_isScanning)
                        AnimatedBuilder(
                          animation: _scanPositionAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top:
                                  MediaQuery.of(context).size.height *
                                  0.5 *
                                  _scanPositionAnimation.value,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryCyan.withValues(
                                        alpha: 0.8,
                                      ),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  color: AppColors.primaryCyan,
                                ),
                              ),
                            );
                          },
                        ),

                      // Transparent Camera Bounding box
                      if (_imageFile == null)
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white24, width: 2),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // ACTION PANELS OR RESULT DETAILS
              if (_scanResult == null) ...[
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        text: context.tr('cameraCapture', ref),
                        icon: Icons.camera_alt_rounded,
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: Icon(Icons.photo_library_outlined),
                        label: Text(context.tr('galleryPick', ref)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('extractedDetailsLabel', ref),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: AppColors.primaryCyan,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildResultRow(
                        context.tr('merchant', ref),
                        _scanResult!.description,
                      ),
                      _buildResultRow(
                        context.tr('category', ref),
                        _scanResult!.category,
                      ),
                      _buildResultRow(
                        context.tr('logDate', ref),
                        '${_scanResult!.date.year}-${_scanResult!.date.month}-${_scanResult!.date.day}',
                      ),
                      Divider(),
                      _buildResultRow(
                        context.tr('totalExtractedLabel', ref),
                        '₹${_scanResult!.amount.toStringAsFixed(2)}',
                        isHighlighted: true,
                      ),
                      SizedBox(height: 20.h),
                      PrimaryButton(
                        text: context.tr('confirmLogExpense', ref),
                        onPressed: _confirmAndSave,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: isHighlighted ? 18 : 13,
              color: isHighlighted ? AppColors.success : null,
            ),
          ),
        ],
      ),
    );
  }
}
