import 'dart:math';

import 'package:flutter/material.dart';

/// A cool soapy button that sits at an angle.
/// It is designed for use by the soapy radio, and the button indicates if the
/// radio is loading or playing or stopped
class SoapyButton extends StatelessWidget {
  /// Inidicates if the radio station is currently playing
  final bool isPlaying;

  /// Indicates if the radio station is currently loading
  final bool isLoading;

  /// Callback when the button the pressed
  final VoidCallback onPressed;

  const SoapyButton({super.key, required this.isPlaying, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // 1. Constrain the soap button to a specific size
    return SizedBox(
        width: 376 * 0.75,
        height: 306 * 0.75,
        // 2. Stack the play/pause button on top of the soap background
        child: Stack(
          children: [
            // 3. Render the soap background
            Image.asset(
              'assets/images/soap.png',
              width: 376,
            ),
            // 4. Position the play/pause within the background so it is centered
            // on the soap
            Positioned.fill(
              top: -35,
              left: 10,
              // 5. And rotate the button so it has the same angle as the bar of soap
              child: Transform.rotate(
                  angle: -23.0 * pi / 180.0,
                  // 6. If we are loading show a loading bar
                  //    If we are playing show a pause button
                  //    If we are paused show a play button
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
  }
}
