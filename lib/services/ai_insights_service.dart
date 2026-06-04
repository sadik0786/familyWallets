import '../models/finance_models.dart';

class AiInsightReport {
  final String title;
  final String content;
  final List<String> warnings;
  final List<String> actionItems;

  AiInsightReport({
    required this.title,
    required this.content,
    required this.warnings,
    required this.actionItems,
  });
}

class AiInsightsService {
  AiInsightReport generateInsights({
    required String familyName,
    required double totalContributions,
    required double totalExpenses,
    required List<ExpenseModel> expenses,
    String locale = 'en',
  }) {
    final balance = totalContributions - totalExpenses;
    final warnings = <String>[];
    final actions = <String>[];

    // 1. Core balance check
    if (balance < 0) {
      if (locale == 'hi') {
        warnings.add('घाटा चेतावनी: आपके पारिवारिक खर्च योगदान से ₹${(-balance).toStringAsFixed(2)} अधिक हैं। आप रिजर्व से उधार ले रहे हैं।');
        actions.add('इस महीने के योगदान को बढ़ाने के लिए एक तत्काल पारिवारिक बैठक आयोजित करें।');
      } else if (locale == 'es') {
        warnings.add('Advertencia de déficit: Sus gastos familiares exceden las contribuciones en ₹${(-balance).toStringAsFixed(2)}. Está tomando prestado de las reservas.');
        actions.add('Programe una sincronización familiar urgente para aumentar las contribuciones de este mes.');
      } else {
        warnings.add('Deficit Warning: Your family expenses exceed contributions by ₹${(-balance).toStringAsFixed(2)}. You are borrowing from reserves.');
        actions.add('Schedule an urgent family sync to increase this month\'s contributions.');
      }
    } else if (totalContributions > 0 && (balance / totalContributions) < 0.15) {
      final pct = ((balance / totalContributions) * 100).toStringAsFixed(0);
      if (locale == 'hi') {
        warnings.add('कम लिक्विडिटी अलर्ट: शेष राशि योगदान का केवल $pct% है। अप्रत्याशित खर्च होने पर उच्च जोखिम।');
        actions.add('बजट आवंटित करने से पहले १५% आपातकालीन नकद बफर बनाने पर विचार करें।');
      } else if (locale == 'es') {
        warnings.add('Alerta de baja liquidez: El saldo restante es solo el $pct% de las contribuciones. Alto riesgo si ocurre un gasto inesperado.');
        actions.add('Considere crear un colchón de efectivo de emergencia del 15% antes de asignar presupuestos.');
      } else {
        warnings.add('Low Liquidity Alert: Remaining balance is only $pct% of contributions. High risk if an unexpected expense occurs.');
        actions.add('Consider building a 15% emergency cash buffer before allocating budgets.');
      }
    }

    // 2. Category spending breakdowns
    final categoryTotals = <String, double>{};
    for (final exp in expenses) {
      categoryTotals[exp.category] = (categoryTotals[exp.category] ?? 0.0) + exp.amount;
    }

    // Rent check
    final rentAmount = categoryTotals['Rent'] ?? 0.0;
    if (totalExpenses > 0 && (rentAmount / totalExpenses) > 0.40) {
      final pct = ((rentAmount / totalExpenses) * 100).toStringAsFixed(0);
      if (locale == 'hi') {
        warnings.add('उच्च किराया ओवरहेड: आवास / किराए की लागत आपके घरेलू खर्चों का $pct% लेती है।');
        actions.add('सुनिश्चित करें कि उच्च निश्चित किराया लागत को संतुलित करने के लिए उपयोगिता प्रबंधन (पानी/बिजली) को अनुकूलित किया गया है।');
      } else if (locale == 'es') {
        warnings.add('Alto costo de alquiler: Los costos de vivienda/alquiler consumen el $pct% de sus gastos domésticos.');
        actions.add('Asegúrese de que la gestión de servicios públicos (agua/electricidad) esté optimizada para equilibrar los altos costos fijos de alquiler.');
      } else {
        warnings.add('High Rent Overhead: Housing / Rent costs take up $pct% of your household outlays.');
        actions.add('Ensure utility management (water/electricity) is optimized to balance high fixed rent costs.');
      }
    }

    // Food check
    final foodAmount = categoryTotals['Grocery'] ?? 0.0;
    if (totalExpenses > 0 && (foodAmount / totalExpenses) > 0.35) {
      final pct = ((foodAmount / totalExpenses) * 100).toStringAsFixed(0);
      if (locale == 'hi') {
        warnings.add('किराना खर्च में वृद्धि: कुल खर्च का लगभग $pct% किराना पर खर्च हो रहा है।');
        actions.add('भोजन की लागत को १०-१५% कम करने के लिए थोक खरीद या गतिशील भोजन की तैयारी की योजना का पता लगाएं।');
      } else if (locale == 'es') {
        warnings.add('Aumento en comestibles: El gasto en comestibles es relativamente alto con un $pct% de los gastos totales.');
        actions.add('Explore compras al por mayor o planes dinámicos de preparación de comidas para reducir los costos de alimentos en un 10-15%.');
      } else {
        warnings.add('Spike in Groceries: Grocery spending is relatively high at $pct% of total expenditures.');
        actions.add('Explore bulk buying or dynamic meal prep plans to bring food costs down by 10-15%.');
      }
    }

    // 3. Generate content paragraphs
    String title = 'Family Finance Health Report';
    String content = '';

    if (locale == 'hi') {
      title = 'पारिवारिक वित्त स्वास्थ्य रिपोर्ट';
      content = 'फैमिली वॉलेट एआई ने **$familyName** के लिए साझा रिकॉर्ड का विश्लेषण किया।\n\n';
      if (expenses.isEmpty) {
        content += 'आपका बहीखाता साफ है! उन्नत भविष्य कहनेवाला अंतर्दृष्टि उत्पन्न करने के लिए कुछ खर्च या योगदान जोड़ें।';
        actions.add('गतिशील ट्रैकिंग शुरू करने के लिए अपना पहला योगदान जोड़ें।');
      } else {
        content += 'वर्तमान में, आपका सबसे बड़ा खर्च क्षेत्र **${_getTopCategory(categoryTotals, locale)}** है। ';
        content += 'कुल व्यय ₹${totalExpenses.toStringAsFixed(2)} के मुकाबले ₹${totalContributions.toStringAsFixed(2)} का कुल योगदान आपको ₹${balance.toStringAsFixed(2)} का सुरक्षा रिजर्व देता है।\n\n';
        content += 'समग्र वित्तीय स्वास्थ्य का मूल्यांकन **${_calculateHealthStatus(balance, totalContributions, locale)}** के रूप में किया गया है।';
      }
      if (actions.isEmpty) {
        actions.add('सटीक वित्तीय बहीखाता पारदर्शिता बनाए रखने के लिए दैनिक खर्चों को ट्रैक करते रहें।');
      }
    } else if (locale == 'es') {
      title = 'Informe de Salud de Finanzas Familiares';
      content = 'Family Wallet AI analizó los registros compartidos de **$familyName**.\n\n';
      if (expenses.isEmpty) {
        content += '¡Su libro está limpio! Agregue algunos gastos o contribuciones para generar información predictiva avanzada.';
        actions.add('Agregue su primera contribución para comenzar el seguimiento dinámico.');
      } else {
        content += 'Actualmente, su área de mayor gasto es **${_getTopCategory(categoryTotals, locale)}**. ';
        content += 'Las contribuciones totales de ₹${totalContributions.toStringAsFixed(2)} frente a los desembolsos de ₹${totalExpenses.toStringAsFixed(2)} le dejan con una reserva de seguridad de ₹${balance.toStringAsFixed(2)}.\n\n';
        content += 'La salud financiera general está calificada como **${_calculateHealthStatus(balance, totalContributions, locale)}**.';
      }
      if (actions.isEmpty) {
        actions.add('Siga rastreando los gastos diariamente para mantener la transparencia del libro financiero.');
      }
    } else {
      title = 'Family Finance Health Report';
      content = 'Family Wallet AI analyzed shared records for **$familyName**.\n\n';
      if (expenses.isEmpty) {
        content += 'Your ledger is clean! Add some expenses or contributions to generate advanced predictive insights.';
        actions.add('Add your first contribution to begin dynamic tracking.');
      } else {
        content += 'Currently, your largest spending area is **${_getTopCategory(categoryTotals, locale)}**. ';
        content += 'Total contributions of ₹${totalContributions.toStringAsFixed(2)} against outlays of ₹${totalExpenses.toStringAsFixed(2)} leave you with a safety reserve of ₹${balance.toStringAsFixed(2)}.\n\n';
        content += 'Overall financial health is rated as **${_calculateHealthStatus(balance, totalContributions, locale)}**.';
      }
      if (actions.isEmpty) {
        actions.add('Keep tracking expenses daily to maintain clean financial ledger transparency.');
      }
    }

    return AiInsightReport(
      title: title,
      content: content,
      warnings: warnings,
      actionItems: actions,
    );
  }

  String _getTopCategory(Map<String, double> categoryTotals, String locale) {
    final noneStr = locale == 'hi' ? 'कोई नहीं' : (locale == 'es' ? 'Ninguno' : 'None');
    if (categoryTotals.isEmpty) return noneStr;
    var topCat = noneStr;
    var maxAmount = 0.0;
    categoryTotals.forEach((cat, amt) {
      if (amt > maxAmount) {
        maxAmount = amt;
        topCat = cat;
      }
    });
    return '$topCat (₹${maxAmount.toStringAsFixed(2)})';
  }

  String _calculateHealthStatus(double balance, double contributions, String locale) {
    if (contributions == 0) {
      return locale == 'hi' ? 'अनिर्धारित' : (locale == 'es' ? 'Indeterminado' : 'Undetermined');
    }
    final ratio = balance / contributions;
    if (ratio < 0) {
      return locale == 'hi' 
          ? 'गंभीर घाटा (कार्रवाई आवश्यक)' 
          : (locale == 'es' ? 'Déficit Crítico (Acción Requerida)' : 'Critical Deficit (Action Required)');
    }
    if (ratio < 0.15) {
      return locale == 'hi' 
          ? 'मध्यम (बारीकी से निगरानी करें)' 
          : (locale == 'es' ? 'Moderado (Monitorear de cerca)' : 'Moderate (Monitor Closely)');
    }
    if (ratio < 0.35) {
      return locale == 'hi' 
          ? 'स्वस्थ (स्थिर बफर)' 
          : (locale == 'es' ? 'Saludable (Buffer Estable)' : 'Healthy (Stable Buffer)');
    }
    return locale == 'hi' 
        ? 'उत्कृष्ट (मजबूत बचत और बफर)' 
        : (locale == 'es' ? 'Excelente (Ahorro y Buffer Fuerte)' : 'Excellent (Strong Savings & Buffers)');
  }
}
