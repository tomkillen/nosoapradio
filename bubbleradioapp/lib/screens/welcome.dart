import 'package:flutter/material.dart';

import '../widgets/animated_intro_text.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/white_large.jpg'), repeat: ImageRepeat.repeat),
        ),
        child: const AnimatedTextAndImage(
            topText: 'NO',
            leftText: 'SOAP',
            bottomText: 'RADIO',
            image: Image(image: AssetImage('assets/images/logo.png'))));
  }
}
