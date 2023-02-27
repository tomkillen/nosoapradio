import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/radio_station.dart';
import '../widgets/header_text.dart';
import '../widgets/pulsing_widget.dart';
import '../widgets/soapy_button.dart';

/// A radio player is a screen that presents a play / pause button to the user
/// and plays the selected radio station
class RadioPlayer extends StatefulWidget {
  final RadioStation station;

  const RadioPlayer({super.key, required this.station});

  @override
  State<RadioPlayer> createState() => _RadioPlayerState();
}

enum _RadioPlayerStage {
  loading,
  playing,
  stopped,
  failed,
}

class _RadioPlayerState extends State<RadioPlayer> with WidgetsBindingObserver {
  final _player = AudioPlayer();
  _RadioPlayerStage _stage = _RadioPlayerStage.loading;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _play();
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // switch (state) {
    //   case AppLifecycleState.resumed:
    //     _play();
    //     break;
    //   case AppLifecycleState.inactive:
    //     _stop();
    //     break;
    //   case AppLifecycleState.paused:
    //     _stop();
    //     break;
    //   case AppLifecycleState.detached:
    //     _stop();
    //     break;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        // Wrap the screen in a swipe detector that allows the user to swip back to the previous screen
        body: GestureDetector(
            onHorizontalDragEnd: (details) {
              // Swipe back to the previous page
              if (details.primaryVelocity! > 0) {
                setState(() {
                  _stage = _RadioPlayerStage.stopped;
                  _player.stop();
                });
                Navigator.of(context).pop();
              }
            },

            // Main contents
            child: Container(
                decoration: const BoxDecoration(
                  image:
                      DecorationImage(image: AssetImage('assets/images/white_large.jpg'), repeat: ImageRepeat.repeat),
                ),
                child: Stack(children: [
                  // Some UI descriping the current radio station
                  SafeArea(
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Align(
                              alignment: Alignment.topRight,
                              child: Column(children: [
                                // Radio Name text display
                                HeaderText(widget.station.name,
                                    delay: const Duration(milliseconds: 1200),
                                    duration: const Duration(milliseconds: 180),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontFamily: 'ClimateCrisis',
                                        fontSize: 24,
                                        color: Color.fromARGB(255, 113, 191, 69))),

                                // Radio tags text display
                                HeaderText(widget.station.tags.join(', '),
                                    delay: const Duration(milliseconds: 1500),
                                    duration: const Duration(milliseconds: 300),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontFamily: 'ShantellSans',
                                        fontSize: 36,
                                        color: Color.fromARGB(255, 63, 200, 244))),
                              ])))),

                  // Radio playback controls, which pulse to the beat of the music
                  PulsingWidget(
                    // Ideally we could beat detect the music to drive the duration of the pulse
                    // Use a fourier transform for this
                    pulseDuration: const Duration(milliseconds: 500),
                    pulsing: _stage == _RadioPlayerStage.playing,
                    child: Center(
                        child: SoapyButton(
                            isPlaying: _player.playing,
                            isLoading: _stage == _RadioPlayerStage.loading,
                            onPressed: () {
                              // User pressed the big play / pause button.
                              // If the stream is playing, then pause it
                              // If it is paused, then play it
                              if (_player.playing) {
                                _stop();
                              } else {
                                _play();
                              }
                            })),
                  )
                ]))));
  }

  /// Helper method for playing the stream, first it loads the stream, then it
  /// plays the stream
  Future<void> _play() async {
    setState(() {
      _stage = _RadioPlayerStage.loading;
    });
    await _player.setUrl(widget.station.url).catchError((error) {
      setState(() {
        _stage = _RadioPlayerStage.failed;
      });
      return null;
    });

    if (_stage == _RadioPlayerStage.loading) {
      setState(() {
        _stage = _RadioPlayerStage.playing;
      });
      await _player.play();
    }
  }

  // Helper method to stop the radio
  void _stop() {
    if (_stage == _RadioPlayerStage.playing) {
      setState(() {
        _stage = _RadioPlayerStage.stopped;
      });
      _player.stop();
    }
  }
}
