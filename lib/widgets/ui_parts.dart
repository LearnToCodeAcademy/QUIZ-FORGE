import 'package:flutter/material.dart';

class GlowCard extends StatelessWidget {
  const GlowCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF121C44),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withValues(alpha: 0.15), blurRadius: 16, spreadRadius: 1)],
      ),
      child: child,
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.icon = Icons.description_outlined});
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white38, size: 44),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
