import 'dart:async';

import 'package:flutter/material.dart';

class AutoScrollCarousel extends StatefulWidget {
  final List<Widget> children;
  final Duration autoScrollDuration;
  final Duration animationDuration;

  const AutoScrollCarousel({
    Key? key,
    required this.children,
    this.autoScrollDuration = const Duration(seconds: 3),
    this.animationDuration = const Duration(milliseconds: 600),
  }) : super(key: key);

  @override
  _AutoScrollCarouselState createState() => _AutoScrollCarouselState();
}

class _AutoScrollCarouselState extends State<AutoScrollCarousel> {
  late final PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _timer = Timer.periodic(widget.autoScrollDuration, (timer) {
      if (!mounted) return;

      if (_currentPage < widget.children.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: widget.animationDuration,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const PageScrollPhysics(),
      children: widget.children,
    );
  }
}
