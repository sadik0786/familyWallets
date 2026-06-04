import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/contribution_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/localization/translations.dart';

class AddContributionView extends ConsumerStatefulWidget {
  const AddContributionView({super.key});

  @override
  ConsumerState<AddContributionView> createState() =>
      _AddContributionViewState();
}

class _AddContributionViewState extends ConsumerState<AddContributionView> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text =
        "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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

  void _saveContribution() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider).user;
    final contributorName = user?.displayName ?? 'Dad';
    final contributorId = user?.id;

    final double amount = double.parse(_amountController.text);

    final success = await ref
        .read(contributionControllerProvider.notifier)
        .addContribution(
          amount: amount,
          contributorName: contributorName,
          contributorId: contributorId,
          note: _noteController.text.trim(),
          date: _selectedDate,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('contributionSuccess', ref)),
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
      appBar: AppBar(title: Text(context.tr('addFamilyContribution', ref))),
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

                      // Notes Note
                      TextFormField(
                        controller: _noteController,
                        decoration: _getInputDecoration(
                          context.tr('notesNoteLabel', ref),
                          Icons.note_alt_outlined,
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? context.tr('contributionNoteRequired', ref)
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
                        text: context.tr('saveContribution', ref),
                        onPressed: _saveContribution,
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
