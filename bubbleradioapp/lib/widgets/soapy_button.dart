import 'dart:math';

import 'package:flutter/material.dart';

class SoapyButton extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPressed;

  const SoapyButton({super.key, required this.isPlaying, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 376 * 0.75,
        height: 306 * 0.75,
        child: Stack(
          children: [
            Image.asset(
              'assets/images/soap.png',
              width: 376,
            ),
            Positioned.fill(
              top: -35,
              left: 10,
              child: Transform.rotate(
                  angle: -23.0 * pi / 180.0,
                  child: isLoading
                      ? const Center(
                          child: SizedBox(
                              width: 60,
                              height: 60,
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 188, 106, 138),
                                strokeWidth: 15,
                              )))
                      : IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 120,
                            color: const Color.fromARGB(255, 188, 106, 138),
                          ),
                          onPressed: onPressed)),
            ),
          ],
        ));
    // return Stack(
    //   children: [
    //     Center(child: Image.asset('assets/images/soap.png')),
    //     Center(
    //         child: Icon(
    //       isPlaying ? Icons.stop : Icons.play_arrow,
    //       size: 72,
    //       color: const Color.fromARGB(255, 188, 106, 138),
    //     ))
    //   ],
    // );
  }
}
