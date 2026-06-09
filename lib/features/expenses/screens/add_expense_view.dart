import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/expense_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../services/speech_to_text_service.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/translations.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../profile/controllers/profile_controller.dart';

class AddExpenseView extends ConsumerStatefulWidget {
  const AddExpenseView({super.key});

  @override
  ConsumerState<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends ConsumerState<AddExpenseView> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  String _selectedCategory = 'Grocery';
  String _paymentMethod = 'cash'; // 'cash' or 'online'

  DateTime _selectedDate = DateTime.now();

  bool _isListening = false;
  String _voiceTranscription = '';

  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _dateController.text =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _triggerVoiceInput() async {
    if (!_speechEnabled) {
      _speechEnabled = await _speechToText.initialize();
      if (!_speechEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Speech recognition not available',
              style: GoogleFonts.outfit(),
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    if (_isListening) {
      await _speechToText.stop();
      setState(() {
        _isListening = false;
      });
      return;
    }

    setState(() {
      _isListening = true;
      _voiceTranscription = context.tr('listeningVoice', ref);
    });

    await _speechToText.listen(
      onResult: (result) {
        if (mounted) {
          setState(() {
            _voiceTranscription = '"${result.recognizedWords}"';
          });
        }

        if (result.finalResult) {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
          final speech = SpeechToTextService();
          final parsed = speech.parseVoiceInput(result.recognizedWords);
          if (parsed.success && mounted) {
            setState(() {
              if (parsed.amount != null) {
                _amountController.text = parsed.amount!.toStringAsFixed(2);
              }
              if (parsed.category != null) _selectedCategory = parsed.category!;
              if (parsed.description != null) {
                _descriptionController.text = parsed.description!;
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('voiceSuccess', ref)),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (mounted && result.recognizedWords.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr('voiceError', ref)),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
    );
  }

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider).user;
    final addedByName = user?.displayName ?? 'Dad';
    final addedBy = user?.id;

    final double amount = double.parse(_amountController.text);

    final success = await ref
        .read(expenseControllerProvider.notifier)
        .addExpense(
          amount: amount,
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          date: _selectedDate,
          addedByName: addedByName,
          addedBy: addedBy,
          receiptUrl: null, // Modified via OCR scans screen
          paymentMethod: _paymentMethod,
        );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('expenseSuccess', ref)),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileState = ref.watch(profileControllerProvider);
    final isPremium = profileState.family?.subscriptionTier == 'premium';

    final categories = [
      'Grocery',
      'Electricity',
      'Water',
      'Gas',
      'Rent',
      'Internet',
      'Medicine',
      'Education',
      'Transport',
      'Other',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('addSharedExpense', ref),
          style: GoogleFonts.outfit(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0.w),
          child: Column(
            children: [
              // OCR SCAN QUICK NAV
              GestureDetector(
                onTap: () {
                  if (isPremium) {
                    Navigator.pop(context);
                    context.push('/ocr-scanner');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'OCR Scan is a Premium feature. You are not eligible.',
                          style: GoogleFonts.outfit(),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: Opacity(
                  opacity: isPremium ? 1.0 : 0.6,
                  child: GlassCard(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    gradientColors: isDark
                        ? [
                            AppColors.primaryCyan.withValues(alpha: 0.1),
                            Colors.transparent,
                          ]
                        : [
                            AppColors.primaryBlue.withValues(alpha: 0.05),
                            Colors.white,
                          ],
                    child: Row(
                      children: [
                        Icon(
                          Icons.document_scanner_rounded,
                          color: AppColors.primaryCyan,
                          size: 32,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('autoScanBill', ref),
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                  color: AppColors.primaryCyan,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                context.tr('autoScanDesc', ref),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isPremium)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryPink.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primaryPink.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                            child: Text(
                              'PRO',
                              style: GoogleFonts.outfit(
                                color: AppColors.primaryPink,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 14,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // VOICE ASSISTANT BLOCK
              GlassCard(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr('voiceExpenseEntry', ref),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                        if (_isListening)
                          SizedBox(width: 12.w,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.primaryPink,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      _voiceTranscription.isEmpty
                          ? context.tr('voicePrompt', ref)
                          : _voiceTranscription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: _isListening
                            ? AppColors.primaryPink
                            : Colors.grey[400],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    IconButton(
                      onPressed: _triggerVoiceInput,
                      icon: Icon(
                        Icons.mic,
                        color: AppColors.primaryPurple,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // LEDGER INPUT FORM
              GlassCard(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Amount
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: GoogleFonts.outfit(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixText: '₹ ',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                        ),
                        validator: (val) =>
                            val == null || double.tryParse(val) == null
                            ? context.tr('invalidAmount', ref)
                            : null,
                      ),
                      Divider(),
                      SizedBox(height: 16.h),

                      // Category Dropdown
                      _buildDropdownRow(
                        label: context.tr('category', ref),
                        value: _selectedCategory,
                        items: categories,
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val!),
                      ),
                      SizedBox(height: 16.h),

                      // Payment Method Segmented Control
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('paymentMethod', ref),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                            ),
                          ),
                          SegmentedButton<String>(
                            segments: [
                              ButtonSegment<String>(
                                value: 'cash',
                                label: Text(context.tr('cash', ref)),
                                icon: Icon(Icons.money_rounded, size: 16),
                              ),
                              ButtonSegment<String>(
                                value: 'online',
                                label: Text(context.tr('online', ref)),
                                icon: Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 16,
                                ),
                              ),
                            ],
                            selected: {_paymentMethod},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() {
                                _paymentMethod = newSelection.first;
                              });
                            },
                            style: SegmentedButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.darkCard
                                  : Colors.white,
                              selectedBackgroundColor: AppColors.primaryCyan
                                  .withValues(alpha: 0.2),
                              selectedForegroundColor: AppColors.primaryCyan,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _getInputDecoration(
                          context.tr('descriptionNotes', ref),
                          Icons.description_outlined,
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? context.tr('descriptionRequired', ref)
                            : null,
                      ),
                      SizedBox(height: 16.h),

                      // Date Picker
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: _getInputDecoration(
                          context.tr('dateLogged', ref),
                          Icons.calendar_today_outlined,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Save
                      PrimaryButton(
                        text: context.tr('saveLedgerTransaction', ref),
                        onPressed: _saveExpense,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownRow({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
        ),
        Container(
          height: 35,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            underline: SizedBox(),
            dropdownColor: isDark ? AppColors.darkCard : Colors.white,
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(context.tr(e.toLowerCase(), ref)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  InputDecoration _getInputDecoration(String label, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      labelStyle: TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primaryCyan, width: 1.5),
      ),
      filled: true,
      fillColor: isDark ? Colors.black26 : Colors.white60,
    );
  }
}
