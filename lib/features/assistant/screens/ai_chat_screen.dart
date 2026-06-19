import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:family_wallet/features/dashboard/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/localization/translations.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  GenerativeModel? _model;
  ChatSession? _chatSession;

  @override
  void initState() {
    super.initState();
    // Add localized welcoming message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authControllerProvider).user;
      final name = user != null ? user.displayName.split(' ').first : 'there';

      String welcomeText = context.tr('welcomeMessage', ref);
      if (welcomeText.startsWith('Hello!')) {
        welcomeText = welcomeText.replaceFirst('Hello!', 'Hello $name!');
      } else {
        welcomeText = 'Hello $name! $welcomeText';
      }

      setState(() {
        _messages.add(
          Message(text: welcomeText, isUser: false, time: DateTime.now()),
        );
      });
    });

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
      _chatSession = _model!.startChat();
    }
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
          duration: Duration(milliseconds: 300),
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
    final locale = ref.read(profileControllerProvider).language;

    await Future.delayed(Duration(milliseconds: 1500));

    // Dynamic response logic
    String reply = '';

    if (_chatSession != null) {
      try {
        final prompt =
            '''
You are FamilyWallet AI, a helpful family finance assistant.
User's Language: $locale
Household Context:
- Total Contributions: ₹${dashboard.totalContributions.toStringAsFixed(2)}
- Total Expenses: ₹${dashboard.totalExpenses.toStringAsFixed(2)}
- Remaining Balance: ₹${dashboard.remainingBalance.toStringAsFixed(2)}
User Query: $text
Reply concisely in the user's language.
''';
        final response = await _chatSession!.sendMessage(Content.text(prompt));
        reply = response.text ?? 'I could not generate a response.';
      } catch (e) {
        reply = 'Error connecting to AI: $e';
      }
    } else {
      reply =
          'GEMINI_API_KEY is missing in .env file. Please add it to enable real AI chat.';
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
      appBar: CustomAppBar(
        title: context.tr('aiCoachTitle', ref),
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
        child: Column(
          children: [
            // CHAT BUBBLES LIST
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(20.w),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            if (_isTyping)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology_rounded,
                      color: AppColors.primaryCyan,
                      size: 16,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      context.tr('coachThinking', ref),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

            // INPUT CONTROLS BAR
            Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
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
                          borderSide: BorderSide(
                            color: AppColors.primaryCyan,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.black26 : Colors.grey[100],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryPurple,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white, size: 18),
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
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(msg.isUser ? 20 : 4),
              bottomRight: Radius.circular(msg.isUser ? 4 : 20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              height: 1.5,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
