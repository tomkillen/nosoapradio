import 'package:forge2d/forge2d.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class BubbleRadio extends StatefulWidget {
  const BubbleRadio({super.key});

  @override
  State<BubbleRadio> createState() => _BubbleRadioState();
}

class _BubbleRadioState extends State<BubbleRadio> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/white_large.jpg'),
              repeat: ImageRepeat.repeat),
        ),
        child: const Text('Hello world') // Your widget contents here
        );
  }
}
