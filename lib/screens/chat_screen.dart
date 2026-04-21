import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../state/quiz_state.dart';
import '../widgets/app_shell.dart';
import '../widgets/ui_parts.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? initialContext;
  const ChatScreen({super.key, this.initialContext});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialContext != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatProvider.notifier).sendMessage("I have a study guide. Can you help me understand it? Context: ${widget.initialContext}");
      });
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
    final chatState = ref.watch(chatProvider);

    return AppShell(
      title: 'QuizForge AI',
      subtitle: widget.initialContext != null ? 'Analyzing study guide...' : 'Ask me anything',
      child: Column(
        children: [
          Expanded(
            child: chatState.when(
              data: (messages) {
                _scrollToBottom();
                if (messages.isEmpty) {
                  return const Center(
                    child: EmptyState(
                      message: 'Hello! I am your QuizForge AI tutor.\nHow can I help you study today?',
                      icon: Icons.psychology_outlined,
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    return FadeInUp(
                      beginOffset: 0.05,
                      child: _ChatBubble(message: m)
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFA78BFA))),
              error: (e, s) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.redAccent))),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black26,
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Ask a question...',
                      hintStyle: const TextStyle(color: Colors.white24),
                      fillColor: Colors.white.withOpacity(0.05),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        ref.read(chatProvider.notifier).sendMessage(val.trim());
                        _controller.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)]),
                  ),
                  child: IconButton(
                    onPressed: () {
                      final val = _controller.text;
                      if (val.trim().isNotEmpty) {
                        ref.read(chatProvider.notifier).sendMessage(val.trim());
                        _controller.clear();
                      }
                    },
                    icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF7C3AED) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: message.isUser ? const Radius.circular(4) : const Radius.circular(20),
            bottomLeft: !message.isUser ? const Radius.circular(4) : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.white.withOpacity(0.9),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
