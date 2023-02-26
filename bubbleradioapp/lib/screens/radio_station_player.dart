import 'package:bubbleradioapp/widgets/soapy_button.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/radio_station.dart';
import '../widgets/header_text.dart';
import '../widgets/pulsing_widget.dart';

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

class _RadioPlayerState extends State<RadioPlayer> {
  final _player = AudioPlayer();
  _RadioPlayerStage _stage = _RadioPlayerStage.loading;

  @override
  void initState() {
    super.initState();
    _play();
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_stage == _RadioPlayerStage.failed) {
      Navigator.pop(context);
    }

    return Scaffold(
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
            child: Container(
                decoration: const BoxDecoration(
                  image:
                      DecorationImage(image: AssetImage('assets/images/white_large.jpg'), repeat: ImageRepeat.repeat),
                ),
                child: Stack(children: [
                  SafeArea(
                      child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Align(
                              alignment: Alignment.topRight,
                              child: Column(children: [
                                // Radio Name
                                HeaderText(widget.station.name,
                                    delay: const Duration(milliseconds: 1200),
                                    duration: const Duration(milliseconds: 180),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontFamily: 'ClimateCrisis',
                                        fontSize: 24,
                                        color: Color.fromARGB(255, 113, 191, 69))),

                                // Radio tags
                                HeaderText(widget.station.tags,
                                    delay: const Duration(milliseconds: 1500),
                                    duration: const Duration(milliseconds: 300),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontFamily: 'ClimateCrisis',
                                        fontSize: 18,
                                        color: Color.fromARGB(255, 63, 200, 244))),
                              ])))),
                  PulsingWidget(
                    // Ideally we could beat detect the music to drive the duration of the pulse
                    // Use a fourier transform for this
                    pulseDuration: const Duration(milliseconds: 500),
                    pulsing: _player.playing,
                    child: Center(
                        child: SoapyButton(
                            isPlaying: _player.playing,
                            isLoading: _stage == _RadioPlayerStage.loading,
                            onPressed: () {
                              if (_player.playing) {
                                setState(() {
                                  _stage = _RadioPlayerStage.stopped;
                                });
                                _player.stop();
                                Navigator.pop(context);
                              } else {
                                _player.play();
                                setState(() {});
                              }
                            })),
                  )
                ]))));
  }

  Future<void> _play() async {
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
}
