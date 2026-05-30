import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../viewmodels/app_state.dart';

class TarsChatbot extends ConsumerStatefulWidget {
  const TarsChatbot({Key? key}) : super(key: key);

  @override
  ConsumerState<TarsChatbot> createState() => _TarsChatbotState();
}

class _TarsChatbotState extends ConsumerState<TarsChatbot> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isOpen = ref.watch(isChatOpenProvider);

    // Auto-scroll on new message logs
    ref.listen<List<ChatMessage>>(chatMessagesProvider, (prev, next) {
      _scrollToBottom();
    });

    if (!isOpen) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: 80, right: 20),
        width: 320,
        height: 480,
        decoration: BoxDecoration(
          color: Colors.white, // As shown in mockup, the conversation body has a white background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF0C3A2B), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // --- HEADER: ASK TARS ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0C3A2B), // Premium dark forest green from mockup
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  // White circular support icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.support_agent,
                        color: Color(0xFF0C3A2B),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tars Info details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ASK TARS',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Chat Support',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Close button
                  GestureDetector(
                    onTap: () {
                      ref.read(isChatOpenProvider.notifier).state = false;
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // --- CONVERSATION VIEW (White Background) ---
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return _buildMessageRow(msg);
                  },
                ),
              ),
            ),

            // --- INPUT CONTAINER ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF0C3A2B), // Forest green bottom wrap
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(14)),
              ),
              child: Row(
                children: [
                  // White curved text pill
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: GoogleFonts.inter(
                          color: AppColors.backgroundDark,
                          fontSize: 13,
                        ),
                        onSubmitted: (val) => _handleSendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: GoogleFonts.inter(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Send Icon
                  GestureDetector(
                    onTap: _handleSendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send,
                          color: Color(0xFF0C3A2B),
                          size: 16,
                        ),
                      ),
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

  Widget _buildMessageRow(ChatMessage message) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // User Chat Bubble
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0), // Soft grayish blue for user bubble
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: Text(
                  message.text,
                  style: GoogleFonts.inter(
                    color: AppColors.backgroundDark,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Small round dark TARS profile icon
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black, // Dark TARS avatar
              ),
              child: const Center(
                child: Icon(
                  Icons.smart_toy_outlined,
                  color: AppColors.primaryTeal,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // TARS Chat Bubble
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100, // Very soft gray container
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  message.text,
                  style: GoogleFonts.inter(
                    color: Colors.black87,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _handleSendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatMessagesProvider.notifier).addMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }
}
