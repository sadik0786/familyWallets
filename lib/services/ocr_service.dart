import 'dart:io';
import 'package:flutter/foundation.dart';

class OcrScanResult {
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final bool success;

  OcrScanResult({
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    this.success = false,
  });
}

class OcrService {
  Future<OcrScanResult> scanReceipt(File file) async {
    debugPrint('[OcrService] Starting receipt scan on file: ${file.path}');
    
    // Simulate holographic scan network/processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulated OCR matches based on filename or dummy triggers
    final path = file.path.toLowerCase();
    
    double amount = 58.75;
    String category = 'Grocery';
    String description = 'Walmart Store';
    
    if (path.contains('electric') || path.contains('power') || path.contains('bill')) {
      amount = 142.10;
      category = 'Electricity';
      description = 'City Power & Grid';
    } else if (path.contains('med') || path.contains('cvs') || path.contains('pill')) {
      amount = 32.40;
      category = 'Medicine';
      description = 'CVS Pharmacy Receipt';
    } else if (path.contains('gas') || path.contains('fuel') || path.contains('shell')) {
      amount = 45.00;
      category = 'Transport';
      description = 'Shell Gas Station';
    } else if (path.contains('internet') || path.contains('wifi') || path.contains('comcast')) {
      amount = 89.99;
      category = 'Internet';
      description = 'Comcast Cable Bill';
    }

    return OcrScanResult(
      amount: amount,
      category: category,
      description: description,
      date: DateTime.now(),
      success: true,
    );
  }
}
