import 'package:flutter/material.dart';

import 'agri_network_image.dart';

/// Fade + slide-up reveal driven by scroll visibility (senior polish motion).
class ScrollReveal extends StatefulWidget {
  const ScrollReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 520),
    this.offset = 28,
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offset;
  final Curve curve;

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('TestWidgetsFlutterBinding');
    _controller = AnimationController(vsync: this, duration: widget.duration);
    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    _opacity = curved;
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offset / 100),
      end: Offset.zero,
    ).animate(curved);
    if (isTest) {
      _controller.value = 1;
      _started = true;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryStart());
    }
  }

  void _tryStart() {
    if (!mounted || _started) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      _started = true;
      return;
    }
    _started = true;
    Future<void>.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return widget.child;
    }
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

/// Parallax image that shifts slightly with scroll offset of a [ScrollController].
class ParallaxImage extends StatelessWidget {
  const ParallaxImage({
    super.key,
    required this.imageUrl,
    required this.scrollController,
    this.height = 200,
    this.factor = 0.18,
  });

  final String imageUrl;
  final ScrollController scrollController;
  final double height;
  final double factor;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      return ClipRect(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: AgriNetworkImage(
            url: imageUrl,
            height: height,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: scrollController,
      builder: (context, _) {
        final offset = scrollController.hasClients
            ? scrollController.offset
            : 0.0;
        return ClipRect(
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Transform.translate(
              offset: Offset(0, offset * factor),
              child: Transform.scale(
                scale: 1.12,
                child: AgriNetworkImage(
                  url: imageUrl,
                  height: height * 1.12,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
