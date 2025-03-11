import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  ChatMessage({
    required this.text, 
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      "Hello! I'm here to help answer any questions you have about meal planning, dietary restrictions, or our service.",
    );
  }
  
  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(text: message, isUser: false));
    });
    _scrollToBottom();
  }
  
  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    _messageController.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();
    
    // Simulate bot response after a delay
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isTyping = false;
      });
      _addBotMessage(_getBotResponse(text));
    });
  }

  String _getBotResponse(String query) {
    query = query.toLowerCase();
    if (query.contains('menu') || query.contains('food')) {
      return "You can check our menu in the home screen. We offer a variety of dishes including vegetarian and non-vegetarian options.";
    } else if (query.contains('delivery') || query.contains('time')) {
      return "We typically deliver within 30-45 minutes of ordering. Delivery times may vary based on your location and order volume.";
    } else if (query.contains('diet') || query.contains('restriction')) {
      return "We cater to various dietary restrictions. You can set your preferences in the profile section under 'Diet Preferences'.";
    }
    return "I understand you're asking about \"$query\". Could you please be more specific about what you'd like to know?";
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Implement the rest of the UI...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MealBuddy Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser 
                      ? Alignment.centerRight 
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: message.isUser 
                          ? const Color(0xFF8BC34A) 
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Bot is typing..."),
              ),
            ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Ask me anything...",
                      contentPadding: EdgeInsets.all(16.0),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}