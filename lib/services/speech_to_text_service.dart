class ParsedVoiceExpense {
  final double? amount;
  final String? category;
  final String? description;
  final bool success;

  ParsedVoiceExpense({
    this.amount,
    this.category,
    this.description,
    this.success = false,
  });
}

class SpeechToTextService {
  // Parses natural voice inputs using rule-based keyword triggers.
  // Example: "Spent 45 dollars on Grocery for fruits"
  ParsedVoiceExpense parseVoiceInput(String text) {
    if (text.isEmpty) return ParsedVoiceExpense();

    final cleanText = text.toLowerCase();
    
    // 1. Try to extract amount
    double? amount;
    final amountRegExp = RegExp(r'(\d+(?:\.\d{1,2})?)');
    final match = amountRegExp.firstMatch(cleanText);
    if (match != null) {
      amount = double.tryParse(match.group(1) ?? '');
    }

    // 2. Try to extract category
    String? category;
    final categories = [
      'grocery', 'electricity', 'water', 'gas', 'rent', 
      'internet', 'medicine', 'education', 'transport', 'other'
    ];
    for (final cat in categories) {
      if (cleanText.contains(cat)) {
        category = cat[0].toUpperCase() + cat.substring(1);
        break;
      }
    }

    // 3. Try to extract description
    String? description;
    if (cleanText.contains('for ')) {
      final index = cleanText.indexOf('for ');
      description = text.substring(index + 4);
    } else if (cleanText.contains('on ')) {
      final index = cleanText.indexOf('on ');
      final amountIndex = cleanText.indexOf(amount.toString());
      if (index > amountIndex) {
        description = text.substring(index + 3);
      }
    }

    // Default category if amount found but no category matched
    if (amount != null && category == null) {
      category = 'Other';
    }

    return ParsedVoiceExpense(
      amount: amount,
      category: category,
      description: description ?? (amount != null ? 'Voice expense' : null),
      success: amount != null,
    );
  }

  // Simulates transcribing audio for seamless demo scenarios
  Future<String> getSimulatedVoiceInput(int index) async {
    await Future.delayed(const Duration(seconds: 2));
    final samples = [
      "spent 45.50 on grocery for apples",
      "rent of 1200 paid today",
      "electricity bill is 85 rupees",
      "bought medicine for 30 rupees for grandmother",
      "spent 15.00 on transport for bus ticket"
    ];
    return samples[index % samples.length];
  }
}
