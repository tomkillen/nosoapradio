import 'dart:ui';

import 'package:bubbleradioapp/features/bubblesimulation/physics/bubble_simulation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../features/bubblesimulation/widgets/bubble_simulation_painter.dart';

class BubbleRadio extends StatefulWidget {
  final BubbleSimulation bubbleSimulation = BubbleSimulation();

  BubbleRadio({super.key}) {
    _initSimulation();
  }

  @override
  State<StatefulWidget> createState() => _BubbleRadioState();

  void _initSimulation() {
    final Size simSize = window.physicalSize / window.devicePixelRatio;
    bubbleSimulation.initialize(simSize);
    bubbleSimulation.spawnBubbles(18);
  }
}

class _BubbleRadioState extends State<BubbleRadio> {
  final backgroundAudio = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startAudio();
  }

  @override
  void dispose() {
    super.dispose();
    backgroundAudio.stop();
    backgroundAudio.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/white_large.jpg'), repeat: ImageRepeat.repeat),
        ),
        child: BubbleSimulationPainterWidget(
          bubbleSimulation: widget.bubbleSimulation,
        ));
  }

  Future<void> _startAudio() async {
    await backgroundAudio.setAsset('assets/sounds/showersinging.wav');
    backgroundAudio.setLoopMode(LoopMode.one);
    backgroundAudio.play();
  }
}
