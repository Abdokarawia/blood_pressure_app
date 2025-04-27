import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

class HealthAIChatScreen extends StatefulWidget {
  const HealthAIChatScreen({super.key});

  @override
  State<HealthAIChatScreen> createState() => _HealthAIChatScreenState();
}

class _HealthAIChatScreenState extends State<HealthAIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Dio dio = Dio();

  // Use ValueNotifier for efficient state updates
  final ValueNotifier<List<ChatMessage>> chatHistoryNotifier = ValueNotifier([]);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  final ValueNotifier<String?> errorMessageNotifier = ValueNotifier(null);

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    chatHistoryNotifier.dispose();
    isLoadingNotifier.dispose();
    errorMessageNotifier.dispose();
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

  void _handleSendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      fetchHealthChatResponse(message);
      _messageController.clear();
    }
  }

  Future<void> fetchHealthChatResponse(String message) async {
    isLoadingNotifier.value = true;
    errorMessageNotifier.value = null;

    try {
      final DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('AI_LINK')
          .doc('ee7PKmGZq3xe5PRJEqq2')
          .get();

      if (!docSnapshot.exists) {
        throw Exception('API endpoint document not found in Firestore');
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      final String apiUrl = data['link'] ?? '';

      if (apiUrl.isEmpty) {
        throw Exception('API URL not found in the document');
      }

      List<Map<String, dynamic>> conversationHistory = [];
      for (var chat in chatHistoryNotifier.value) {
        conversationHistory.add({
          'role': chat.isUser ? 'user' : 'assistant',
          'content': chat.message,
        });
      }

      Map<String, dynamic> requestData = {
        "message": message,
      };

      if (conversationHistory.isNotEmpty) {
        requestData["conversation_history"] = conversationHistory;
      }

      final response = await dio.post(
        "$apiUrl/health-chat",
        data: requestData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      chatHistoryNotifier.value = [
        ...chatHistoryNotifier.value,
        ChatMessage(
          message: message,
          timestamp: DateTime.now(),
          isUser: true,
        ),
        ChatMessage(
          message: response.data?['response'] ?? 'No response received',
          timestamp: DateTime.now(),
          isUser: false,
        ),
      ];

      _scrollToBottom();
    } catch (e) {
      errorMessageNotifier.value = e is DioException
          ? e.response?.statusMessage ?? 'Network error occurred'
          : e.toString();
      print('Error in health chat: $e');
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 15 : 20),
          child: Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<List<ChatMessage>>(
                  valueListenable: chatHistoryNotifier,
                  builder: (context, chatHistory, _) {
                    return chatHistory.isEmpty
                        ? _buildWelcomeScreen(isSmallScreen)
                        : _buildChatHistoryView(isSmallScreen);
                  },
                ),
              ),
              ValueListenableBuilder<String?>(
                valueListenable: errorMessageNotifier,
                builder: (context, errorMessage, _) {
                  return errorMessage != null
                      ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      'Error: $errorMessage',
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  )
                      : const SizedBox.shrink();
                },
              ),
              _buildMessageInput(isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(bool isSmallScreen) {
    return _buildAIChatTab(isSmallScreen);
  }

  Widget _buildChatHistoryView(bool isSmallScreen) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: chatHistoryNotifier.value.length,
      itemBuilder: (context, index) {
        final message = chatHistoryNotifier.value[index];
        return _buildChatBubble(message, isSmallScreen);
      },
    );
  }

  Widget _buildChatBubble(ChatMessage message, bool isSmallScreen) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: isSmallScreen ? 5 : 10,
        ),
        padding: EdgeInsets.all(isSmallScreen ? 12 : 15),
        decoration: BoxDecoration(
          color: message.isUser
              ? Colors.teal.shade500
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 13 : 15,
                color: message.isUser ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: GoogleFonts.poppins(
                fontSize: isSmallScreen ? 10 : 11,
                color: message.isUser
                    ? Colors.white.withOpacity(0.7)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isSmallScreen) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoadingNotifier,
      builder: (context, isLoading, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type your question here...',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey.shade400,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _handleSendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _handleSendMessage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade500,
                    shape: BoxShape.circle,
                  ),
                  child: isLoading
                      ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Iconsax.send,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAIChatTab(bool isSmallScreen) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isSmallScreen ? 15 : 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.message_question,
                          size: isSmallScreen ? 30 : 40,
                          color: Colors.teal.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Health AI Assistant',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 18 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ask any health or lifestyle questions and get personalized answers',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildSampleQuestion(
                          'How can I improve my sleep quality?', isSmallScreen),
                      const SizedBox(height: 10),
                      _buildSampleQuestion(
                          'What are the best exercises for weight loss?',
                          isSmallScreen),
                      const SizedBox(height: 10),
                      _buildSampleQuestion(
                          'What foods are high in protein?', isSmallScreen),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSampleQuestion(String question, bool isSmallScreen) {
    return GestureDetector(
      onTap: () {
        _messageController.text = question;
        _handleSendMessage();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 15 : 20,
          vertical: isSmallScreen ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Text(
          question,
          style: GoogleFonts.poppins(
            fontSize: isSmallScreen ? 12 : 14,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final DateTime timestamp;
  final bool isUser;

  ChatMessage({
    required this.message,
    required this.timestamp,
    required this.isUser,
  });
}