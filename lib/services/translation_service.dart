import 'package:translator/translator.dart';

class TranslationService {
  static final _translator = GoogleTranslator();
  static final Map<String, String> _cache = {};

  /// Translates a given text to the target locale if it's not English.
  static Future<String> translateCustomText(String text, String targetLocale) async {
    if (text.isEmpty) return text;
    // Don't translate if the target is English or text is just numbers
    if (targetLocale == 'en') return text;
    if (double.tryParse(text) != null) return text;

    final cacheKey = '${text}_$targetLocale';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final translation = await _translator.translate(text, to: targetLocale);
      _cache[cacheKey] = translation.text;
      return translation.text;
    } catch (e) {
      // Fallback to original text if translation fails
      return text;
    }
  }
}
