import 'package:flutter/material.dart';
import '../../../core/theme/style.dart';

/// Chat screen for MoneyCA - the AI financial assistant
/// Users can ask questions about their finances, get insights,
/// and add transactions through natural conversation
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message from MoneyCA
    _messages.add(
      ChatMessage(
        id: '0',
        text: 'Hi! I\'m MoneyCA, your AI financial assistant. 💰\n\nI can help you:\n• Add transactions by voice or text\n• Get spending insights\n• Answer financial questions\n• Set and track goals\n\nHow can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      // Add user message
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    // Simulate AI response (replace with actual AI integration)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: _generateMockResponse(text),
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    });
  }

  String _generateMockResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    if (lowerMessage.contains('spent') || lowerMessage.contains('spending')) {
      return 'Based on your recent transactions, you\'ve spent \$1,247.89 this month. Your biggest expense category is Food & Dining at \$458.23. Would you like me to break this down further?';
    } else if (lowerMessage.contains('budget')) {
      return 'Your current budget status:\n• Food & Dining: \$458/\$400 (15% over)\n• Transportation: \$235/\$300 (22% under)\n• Entertainment: \$123/\$150 (18% under)\n\nOverall, you\'re doing well! Consider reducing dining expenses to stay on track.';
    } else if (lowerMessage.contains('add') || lowerMessage.contains('transaction')) {
      return 'I\'d be happy to help you add a transaction! Please tell me:\n• What did you spend money on?\n• How much was it?\n• What category should it go in?\n\nYou can also just say something like "I spent \$25 on groceries" and I\'ll handle the rest!';
    } else if (lowerMessage.contains('save') || lowerMessage.contains('saving')) {
      return 'Great question about savings! You\'re currently saving 64.3% of your income, which is excellent! Here are some tips to save even more:\n• Review your Food & Dining expenses\n• Consider meal prepping\n• Look for subscription services you might not need\n\nWould you like specific recommendations?';
    } else if (lowerMessage.contains('goal') || lowerMessage.contains('goals')) {
      return 'Here\'s your goals progress:\n🎯 Emergency Fund: \$2,500/\$5,000 (50%)\n✈️ Vacation Savings: \$1,200/\$3,000 (40%)\n📈 Investment Fund: \$800/\$2,000 (40%)\n\nYou\'re making good progress! At your current savings rate, you\'ll reach your emergency fund goal in about 4 months.';
    } else {
      return 'I understand you\'re asking about "${userMessage}". While I\'m still learning, I can help you with:\n• Tracking expenses and income\n• Budget analysis\n• Savings goals\n• Financial insights\n\nCould you rephrase your question or ask about one of these topics?';
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.darkBackground,
      appBar: AppBar(
        backgroundColor: AppStyle.darkBackground,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppStyle.primaryGreen.withOpacity(0.2),
              child: const Text('🤖', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MoneyCA', style: AppStyle.getBodyLarge(true).copyWith(fontSize: 16)),
                Text(
                  'Your AI Assistant',
                  style: AppStyle.getCaption(true).copyWith(
                    fontSize: 12,
                    color: AppStyle.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🚧 Chat history feature coming soon!'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildLoadingMessage();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          
          // Input area
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppStyle.primaryGreen.withOpacity(0.2),
              child: const Text('🤖', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isUser ? LinearGradient(
                  colors: [AppStyle.primaryGreen, AppStyle.greenAccent],
                ) : null,
                color: isUser ? null : AppStyle.cardBackground,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                ),
                border: !isUser ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: AppStyle.getBodyMedium(true).copyWith(
                      color: isUser ? Colors.white : AppStyle.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppStyle.getCaption(true).copyWith(
                      color: isUser ? Colors.white70 : AppStyle.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppStyle.greenAccent.withOpacity(0.2),
              child: Icon(Icons.person, size: 16, color: AppStyle.greenAccent),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppStyle.primaryGreen.withOpacity(0.2),
            child: const Text('🤖', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppStyle.cardBackground,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: Radius.zero,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppStyle.primaryGreen),
                  ),
                ),
                const SizedBox(width: 8),
                Text('MoneyCA is thinking...', style: AppStyle.getBodyMedium(true)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Voice input button
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🚧 Voice input feature coming soon!'),
                  ),
                );
              },
              icon: Icon(Icons.mic, color: AppStyle.primaryGreen),
              style: IconButton.styleFrom(
                backgroundColor: AppStyle.primaryGreen.withOpacity(0.1),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Text input
            Expanded(
              child: TextField(
                controller: _messageController,
                style: AppStyle.getBodyMedium(true),
                decoration: InputDecoration(
                  hintText: 'Ask MoneyCA anything...',
                  hintStyle: AppStyle.getBodySmall(true).copyWith(
                    color: AppStyle.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppStyle.cardBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Send button
            IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: AppStyle.primaryGreen,
                disabledBackgroundColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}