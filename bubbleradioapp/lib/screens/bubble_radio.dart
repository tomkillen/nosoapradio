import 'package:flutter/material.dart';

import '../widgets/wave_animation.dart';

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
    return const Scaffold(
        body: BackgroundWave(height: 30, waveLength: 1200, speed: 0.1));
  }
}
