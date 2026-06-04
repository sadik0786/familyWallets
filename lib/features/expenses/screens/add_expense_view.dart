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

  DateTime _selectedDate = DateTime.now();

  bool _isListening = false;
  String _voiceTranscription = '';

  @override
  void initState() {
    super.initState();
    _dateController.text =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
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
    final speech = SpeechToTextService();
    setState(() {
      _isListening = true;
      _voiceTranscription = context.tr('listeningVoice', ref);
    });

    // Simulate voice entry delay
    final spoken = await speech.getSimulatedVoiceInput(
      0,
    ); // e.g. "spent 45.50 on grocery for apples"

    if (!mounted) return;

    setState(() {
      _isListening = false;
      _voiceTranscription = '"$spoken"';
    });

    final parsed = speech.parseVoiceInput(spoken);
    if (parsed.success) {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('voiceError', ref)),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
        );

    if (success && mounted) {
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
      appBar: AppBar(title: Text(context.tr('addSharedExpense', ref))),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkBackground, const Color(0xFF14151F)]
                : [AppColors.lightBackground, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // OCR SCAN QUICK NAV
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  context.push('/ocr-scanner');
                },
                child: GlassCard(
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
                      const Icon(
                        Icons.document_scanner_rounded,
                        color: AppColors.primaryCyan,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('autoScanBill', ref),
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primaryCyan,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('autoScanDesc', ref),
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // VOICE ASSISTANT BLOCK
              GlassCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr('voiceExpenseEntry', ref),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        if (_isListening)
                          const SizedBox(
                            width: 12,
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
                    const SizedBox(height: 12),
                    Text(
                      _voiceTranscription.isEmpty
                          ? context.tr('voicePrompt', ref)
                          : _voiceTranscription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: _isListening
                            ? AppColors.primaryPink
                            : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 16),
                    IconButton(
                      onPressed: _triggerVoiceInput,
                      icon: const Icon(
                        Icons.mic,
                        color: AppColors.primaryPurple,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // LEDGER INPUT FORM
              GlassCard(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Amount
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: GoogleFonts.outfit(
                          fontSize: 24,
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
                      const Divider(),
                      const SizedBox(height: 16),

                      // Category Dropdown
                      _buildDropdownRow(
                        label: context.tr('category', ref),
                        value: _selectedCategory,
                        items: categories,
                        onChanged: (val) =>
                            setState(() => _selectedCategory = val!),
                      ),
                      const SizedBox(height: 16),

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
                      const SizedBox(height: 16),

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
                      const SizedBox(height: 16),



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
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            dropdownColor: isDark ? AppColors.darkCard : Colors.white,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
      labelStyle: const TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryCyan, width: 1.5),
      ),
      filled: true,
      fillColor: isDark ? Colors.black26 : Colors.white60,
    );
  }
}
