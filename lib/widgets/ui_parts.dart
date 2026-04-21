import 'package:flutter/material.dart';

class FadeInUp extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double beginOffset;
  const FadeInUp({super.key, required this.child, this.delay = Duration.zero, this.beginOffset = 0.3});

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _offset = Tween<Offset>(begin: Offset(0, widget.beginOffset), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}

class GlowCard extends StatefulWidget {
  const GlowCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  State<GlowCard> createState() => _GlowCardState();
}

class _GlowCardState extends State<GlowCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 150), lowerBound: 0.95, upperBound: 1.0)..value = 1.0;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _scaleCtrl.reverse(),
        onTapUp: (_) { _scaleCtrl.forward(); widget.onTap?.call(); },
        onTapCancel: () => _scaleCtrl.forward(),
        child: ScaleTransition(
          scale: _scaleCtrl,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: widget.padding,
            decoration: BoxDecoration(
              color: _isHovered ? const Color(0xFF1E285D) : const Color(0xFF121C44),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFF7C3AED).withOpacity(_isHovered ? 0.8 : 0.4), width: _isHovered ? 2 : 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(_isHovered ? 0.35 : 0.15),
                  blurRadius: _isHovered ? 28 : 20,
                  spreadRadius: _isHovered ? 3 : 1,
                  offset: _isHovered ? const Offset(0, 6) : Offset.zero,
                )
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatefulWidget {
  final String message;
  final double progress;
  const LoadingOverlay({super.key, required this.message, required this.progress});

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: FadeInUp(
          beginOffset: 0.1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFFA78BFA), strokeWidth: 6),
              const SizedBox(height: 32),
              Text(
                widget.message,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: widget.progress,
                  backgroundColor: Colors.white10,
                  color: const Color(0xFFA78BFA),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${(widget.progress * 100).toInt()}%',
                style: const TextStyle(color: Color(0xFFA78BFA), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
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
          Icon(icon, color: Colors.white38, size: 54),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 15, height: 1.5),
          ),
        ],
      ),
    );
  }
}
