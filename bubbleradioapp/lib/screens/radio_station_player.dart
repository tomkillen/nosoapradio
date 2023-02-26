import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/radio_station.dart';

class RadioPlayer extends StatefulWidget {
  final RadioStation station;

  const RadioPlayer({super.key, required this.station});

  @override
  State<RadioPlayer> createState() => _RadioPlayerState();
}

class _RadioPlayerState extends State<RadioPlayer> {
  final _player = AudioPlayer();

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
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/images/white_large.jpg'), repeat: ImageRepeat.repeat),
      ),
      child: Center(
        child: StreamBuilder<Duration?>(
          stream: _player.durationStream,
          builder: (context, snapshot) {
            final duration = snapshot.data ?? Duration.zero;
            return StreamBuilder<Duration?>(
              stream: _player.positionStream,
              builder: (context, snapshot) {
                var position = snapshot.data ?? Duration.zero;
                if (position > duration) {
                  position = duration;
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_player.playing) {
                          _player.stop();
                        } else {
                          _player.play();
                        }
                        setState(() {});
                      },
                      icon: Icon(_player.playing ? Icons.stop : Icons.play_arrow),
                      iconSize: 64.0,
                    ),
                    const SizedBox(height: 16.0),
                    Text('${position.inSeconds}/${duration.inSeconds} seconds'),
                  ],
                );
              },
            );
          },
        ),
      ),
    ));
  }

  Future<void> _play() async {
    await _player.setUrl(widget.station.url).catchError((error) {
      print('Failed to load audio: $error');
      return null;
    });
    await _player.play();
  }
}
