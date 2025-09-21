import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/style.dart';
import '../../data/services/simple_chat_service.dart';

/// A floating chat overlay that appears on top of the current screen
class ChatOverlay extends StatefulWidget {
  final VoidCallback onClose;
  
  const ChatOverlay({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  State<ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<ChatOverlay>
    with TickerProviderStateMixin {
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final SimpleChatService _chatService = SimpleChatService();
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isTyping = false;
  bool _isMinimized = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // Add welcome message
    _messages.add(ChatMessage(
      text: "Hi! I'm MoneyCA, your financial assistant. How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background tap to close
          GestureDetector(
            onTap: _closeChatOverlay,
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          // Chat bubble
          Positioned(
            right: 20,
            bottom: 20,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _isMinimized ? _buildMinimizedChat() : _buildExpandedChat(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimizedChat() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isMinimized = false;
        });
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppStyle.primaryGreen, AppStyle.greenAccent],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppStyle.primaryGreen.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.chat_bubble_rounded,
                color: Color.fromARGB(255, 140, 80, 80),
                size: 28,
              ),
            ),
            if (_messages.where((m) => !m.isRead && !m.isUser).isNotEmpty)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedChat() {
    return Container(
      width: 350,
      height: 700,
      decoration: BoxDecoration(
        color: AppStyle.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildChatHeader(),
          Expanded(child: _buildMessagesList()),
          _buildTypingIndicator(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppStyle.primaryGreen.withOpacity(0.8), const Color.fromARGB(255, 22, 27, 31)]
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
           
            child: Image.asset('assets/images/monyca.png',
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monyca',
                  style: AppStyle.getHeadingSmall(true).copyWith(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
                Text(
                  'AI personal finance assistant',
                  style: AppStyle.getCaption(true).copyWith(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
    
              GestureDetector(
                onTap: _closeChatOverlay,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 250),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser 
                  ? LinearGradient(colors: [AppStyle.primaryGreen, AppStyle.greenAccent])
                  : null,
                color: isUser ? null : AppStyle.primaryStone10.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
                border: !isUser ? Border.all(color: Colors.white.withOpacity(0.1)) : null,
              ),
              child: Text(
                message.text,
                style: AppStyle.getBodyMedium(true).copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: AppStyle.getCaption(true).copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    if (!_isTyping) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
         
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(200),
                const SizedBox(width: 4),
                _buildTypingDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            math.sin((_animationController.value * 2 * math.pi) + (delay / 100)) * 3,
          ),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
  
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: AppStyle.getBodyMedium(true),
                decoration: InputDecoration(
                  hintText: 'Ask me anything about your finances...',
                  hintStyle: AppStyle.getBodySmall(true).copyWith(
                    color: Colors.white54,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
                onSubmitted: (text) => _sendMessage(text),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isSending ? null : () => _sendMessage(_messageController.text),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isSending 
                    ? [Colors.grey, Colors.grey] 
                    : [AppStyle.primaryGreen, AppStyle.greenAccent],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty || _isSending) return;
    
    final userMessage = text.trim();
    
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
      _isTyping = true;
      _isSending = true;
    });
    
    _scrollToBottom();
    
    try {
      // Actually call your API
      final aiResponse = await _chatService.sendMessage(userMessage);
      
      if (mounted) {
        setState(() {
          _isTyping = false;
          _isSending = false;
          _messages.add(ChatMessage(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      // Handle errors
      if (mounted) {
        setState(() {
          _isTyping = false;
          _isSending = false;
          _messages.add(ChatMessage(
            text: "Sorry, I'm having trouble responding right now. Please try again.",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    }
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

  void _closeChatOverlay() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);
    
    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Model for chat messages
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isRead;
  
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isRead = true,
  });
}