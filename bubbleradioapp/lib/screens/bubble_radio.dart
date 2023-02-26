import 'package:flutter/material.dart';

import '../features/bubblesimulation/widgets/bubble_simulation_painter.dart';

class BubbleRadio extends StatelessWidget {
  const BubbleRadio({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/white_large.jpg'), repeat: ImageRepeat.repeat),
        ),
        child: BubbleSimulationPainterWidget() // Your widget contents here
        );
  }
}
