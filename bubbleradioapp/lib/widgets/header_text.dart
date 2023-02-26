import 'package:flutter/material.dart';

class HeaderText extends StatefulWidget {
  final String text;
  final Duration duration;
  final Duration delay;
  final TextStyle style;
  final TextAlign textAlign;

  const HeaderText(this.text,
      {super.key, required this.duration, required this.style, required this.textAlign, required this.delay});

  @override
  State<HeaderText> createState() => _HeaderTextState();
}

class _HeaderTextState extends State<HeaderText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<Offset>(begin: const Offset(2.0, 0.0), end: Offset.zero).animate(_controller);

    Future.delayed(widget.delay, () {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          alignment: Alignment.centerRight,
          child: Text(
            widget.text,
            style: widget.style,
            textAlign: widget.textAlign,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
