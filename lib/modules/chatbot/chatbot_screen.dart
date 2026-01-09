import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {"sender": "bot", "text": "Hello, how can I help?", "isTyping": false},
  ];

  void _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({"sender": "user", "text": message});
    });

    _textController.clear();

    // Scroll to bottom
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

    try {
      final response = await http.post(
        Uri.parse("http://192.168.0.31:5000/chat"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data["reply"];

        setState(() {
          _messages.add({
            "sender": "bot",
            "text": reply,
            "isTyping": true,
          });
        });
      } else {
        setState(() {
          _messages.add({
            "sender": "bot",
            "text": "Sorry, something went wrong. Try again later.",
            "isTyping": false,
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "sender": "bot",
          "text": "Cannot connect to the server. Is it running?",
          "isTyping": false,
        });
      });
    }

    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              "BOLTZ",
              style: TextStyle(
                fontSize: 24,
                fontFamily: AppFonts.primary,
                color: AppColors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),

            // Chat list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message["sender"] == "user";
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUser)
                          const CircleAvatar(
                            backgroundColor: AppColors.lightbackground,
                            backgroundImage: AssetImage('assets/icons/me.png'),
                          ),
                        if (!isUser) const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? AppColors.pink
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: message["isTyping"] == true
                                ? AnimatedTextKit(
                                    isRepeatingAnimation: false,
                                    animatedTexts: [
                                      TyperAnimatedText(
                                        message["text"],
                                        textStyle: TextStyle(
                                          color: isUser
                                              ? Colors.white
                                              : AppColors.background,
                                          fontSize: 14,
                                        ),
                                        speed: const Duration(milliseconds: 40),
                                      ),
                                    ],
                                    onFinished: () {
                                      setState(() {
                                        message["isTyping"] = false;
                                      });
                                    },
                                  )
                                : Text(
                                    message["text"],
                                    style: TextStyle(
                                      color: isUser
                                          ? Colors.white
                                          : AppColors.background,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        if (isUser) const SizedBox(width: 8),
                        if (isUser)
                          const CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage('assets/icons/me.png'),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8), // <-- adds some space before input box

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.lightbackground,
                        hintText: 'Type your message...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: AppColors.pink),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
