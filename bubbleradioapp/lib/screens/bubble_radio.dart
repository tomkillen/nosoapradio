import 'package:bubbleradioapp/features/bubblesimulation/physics/bubble_simulation.dart';
import 'package:flutter/material.dart';

import '../features/bubblesimulation/widgets/bubble_simulation_painter.dart';

class BubbleRadio extends StatelessWidget {
  final BubbleSimulation bubbleSimulation = BubbleSimulation();

  BubbleRadio({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/white_large.jpg'), repeat: ImageRepeat.repeat),
        ),
        child: BubbleSimulationPainterWidget(
          bubbleSimulation: bubbleSimulation,
        ) // Your widget contents here
        );
  }
}
