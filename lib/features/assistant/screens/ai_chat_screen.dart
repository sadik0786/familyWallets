import 'package:family_wallet/features/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../expenses/controllers/expense_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/localization/translations.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime time;

  Message({required this.text, required this.isUser, required this.time});
}

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final List<Message> _messages = [];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add localized welcoming message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final welcomeText = context.tr('welcomeMessage', ref);
      setState(() {
        _messages.add(
          Message(text: welcomeText, isUser: false, time: DateTime.now()),
        );
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(Message(text: text, isUser: true, time: DateTime.now()));
      _isTyping = true;
    });
    _scrollToBottom();

    // Context analysis
    final dashboard = ref.read(dashboardControllerProvider);
    final expenses = ref.read(expenseControllerProvider).expenses;
    final locale = ref.read(profileControllerProvider).language;

    await Future.delayed(const Duration(milliseconds: 1500));

    // Dynamic response logic based on user queries and locale
    String reply = '';
    final query = text.toLowerCase();

    if (query.contains('balance') ||
        query.contains('status') ||
        query.contains('शेष') ||
        query.contains('saldo')) {
      if (locale == 'hi') {
        reply =
            'आपका शेष राशि वर्तमान में ₹${dashboard.remainingBalance.toStringAsFixed(2)} है। यह ₹${dashboard.totalContributions.toStringAsFixed(2)} कुल योगदान में से ₹${dashboard.totalExpenses.toStringAsFixed(2)} कुल खर्चों को घटाकर गणना की जाती है।';
      } else if (locale == 'es') {
        reply =
            'Su saldo restante actual es de ₹${dashboard.remainingBalance.toStringAsFixed(2)}. Esto se calcula como ₹${dashboard.totalContributions.toStringAsFixed(2)} de contribuciones totales menos ₹${dashboard.totalExpenses.toStringAsFixed(2)} de gastos totales.';
      } else {
        reply =
            'Your remaining balance is currently ₹${dashboard.remainingBalance.toStringAsFixed(2)}. This is calculated as ₹${dashboard.totalContributions.toStringAsFixed(2)} total contributions minus ₹${dashboard.totalExpenses.toStringAsFixed(2)} total expenses.';
      }
    } else if (query.contains('save') ||
        query.contains('tips') ||
        query.contains('बचत') ||
        query.contains('ahorrar') ||
        query.contains('consejos')) {
      if (locale == 'hi') {
        reply =
            'घरेलू बचत बढ़ाने के लिए:\n1. थोक में खरीदने के लिए किराना यात्राओं को समेकित करें—इससे भोजन खर्च में 12% की कमी आ सकती है।\n2. हमने बिजली की लागत में वृद्धि देखी है—₹5,000 की मासिक सीमा निर्धारित करने पर विचार करें।\n3. सुनिश्चित करें कि एक स्थिर नकदी बफर बनाए रखने के लिए हर महीने की 1 तारीख को योगदान दर्ज किया जाए।';
      } else if (locale == 'es') {
        reply =
            'Para aumentar los ahorros en su hogar:\n1. Consolide los viajes al supermercado para comprar al por mayor; esto podría reducir los gastos de comida en un 12%.\n2. Notamos picos en los costos de electricidad; considere establecer un límite mensual de ₹5,000.\n3. Asegúrese de registrar las contribuciones el día 1 de cada mes para mantener un colchón de efectivo estable.';
      } else {
        reply =
            'To boost savings in your household:\n1. Consolidate Grocery trips to buy in bulk—this could reduce food outlays by 12%.\n2. We noticed electricity costs spikes—consider setting a monthly cap of ₹5,000.\n3. Make sure contributions are logged on the 1st of every month to preserve a steady cash buffer.';
      }
    } else if (query.contains('grocery') ||
        query.contains('food') ||
        query.contains('किराना') ||
        query.contains('भोजन') ||
        query.contains('comida') ||
        query.contains('supermercado')) {
      final groceryTotal = expenses
          .where((e) => e.category == 'Grocery')
          .fold(0.0, (s, e) => s + e.amount);
      if (locale == 'hi') {
        reply =
            'कुल किराना खर्च ₹${groceryTotal.toStringAsFixed(2)} है। यदि यह अधिक लगता है, तो भोजन को कैलेंडर पर दर्ज करने और थोक खरीदारी की योजना बनाने का प्रयास करें।';
      } else if (locale == 'es') {
        reply =
            'El gasto total en comestibles es de ₹${groceryTotal.toStringAsFixed(2)}. Si esto le parece alto, intente registrar las comidas en un calendario y planificar compras al por mayor.';
      } else {
        reply =
            'Total Grocery spending is ₹${groceryTotal.toStringAsFixed(2)}. If this feels high, try logging meals on a calendar and planning bulk purchases.';
      }
    } else {
      if (locale == 'hi') {
        reply =
            'मैंने आपके साझा घरेलू बहीखाता की जांच की है। ₹${dashboard.totalContributions.toStringAsFixed(2)} के कुल योगदान सूचकांक और ₹${dashboard.totalExpenses.toStringAsFixed(2)} के मासिक खर्च के साथ, आप वर्तमान में ${((dashboard.remainingBalance / (dashboard.totalContributions == 0 ? 1 : dashboard.totalContributions)) * 100).toStringAsFixed(0)}% का बचत बफर अनुपात बनाए रख रहे हैं। आप एक स्थिर पथ पर हैं!';
      } else if (locale == 'es') {
        reply =
            'He examinado el libro contable compartido de su hogar. Con un índice de contribución total de ₹${dashboard.totalContributions.toStringAsFixed(2)} y gastos mensuales de ₹${dashboard.totalExpenses.toStringAsFixed(2)}, actualmente mantiene una relación de colchón de ahorro del ${((dashboard.remainingBalance / (dashboard.totalContributions == 0 ? 1 : dashboard.totalContributions)) * 100).toStringAsFixed(0)}%. ¡Está en un camino estable!';
      } else {
        reply =
            'I\'ve examined your shared household ledger. With a total contribution index of ₹${dashboard.totalContributions.toStringAsFixed(2)} and monthly expenses of ₹${dashboard.totalExpenses.toStringAsFixed(2)}, you are currently keeping a savings buffer ratio of ${((dashboard.remainingBalance / (dashboard.totalContributions == 0 ? 1 : dashboard.totalContributions)) * 100).toStringAsFixed(0)}%. You are on a stable path!';
      }
    }

    setState(() {
      _isTyping = false;
      _messages.add(Message(text: reply, isUser: false, time: DateTime.now()));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('aiCoachTitle', ref))),
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
        child: Column(
          children: [
            // CHAT BUBBLES LIST
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            if (_isTyping)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.psychology_rounded,
                      color: AppColors.primaryCyan,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('coachThinking', ref),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

            // INPUT CONTROLS BAR
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: context.tr('chatHint', ref),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: AppColors.primaryCyan,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.black26 : Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryPurple,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message msg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final align = msg.isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final bubbleColor = msg.isUser
        ? AppColors.primaryBlue
        : (isDark ? AppColors.darkCard : Colors.grey[200]);
    final textColor = msg.isUser
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
              bottomRight: Radius.circular(msg.isUser ? 4 : 20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: GoogleFonts.outfit(
              fontSize: 13,
              height: 1.5,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
