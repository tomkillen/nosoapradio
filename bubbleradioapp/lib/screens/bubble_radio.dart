import 'dart:math';
import 'dart:ui';

import 'package:bubbleradioapp/features/bubblesimulation/physics/bubble_simulation.dart';
import 'package:bubbleradioapp/features/bubblesimulation/widgets/radio_bubble.dart';
import 'package:bubbleradioapp/services/radio_stations_api.dart';
import 'package:bubbleradioapp/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge2d/forge2d.dart';
import 'package:just_audio/just_audio.dart';

import '../features/bubblesimulation/models/bubble.dart';
import '../features/bubblesimulation/widgets/bubble_simulation_painter.dart';
import '../models/radio_station.dart';
import '../services/radio_stations_bloc.dart';

class BubbleRadio extends StatefulWidget {
  BubbleRadio({super.key}) {
    _initSimulation();
  }

  @override
  State<StatefulWidget> createState() => _BubbleRadioState();

  void _initSimulation() {
    // Create a bubble simulation sized to fit the physical screen
    final Size simSize = window.physicalSize / window.devicePixelRatio;
    ServiceLocator.get<BubbleSimulation>().initialize(simSize, 18);
  }
}

class _BubbleRadioState extends State<BubbleRadio> {
  final _backgroundAudio = AudioPlayer();
  final List<Bubble> _bubbles = [];

  @override
  void initState() {
    super.initState();
    _loadStations();

    // TODO renable audio before releasing this
    // _startAudio();
  }

  @override
  void dispose() {
    super.dispose();
    _backgroundAudio.stop();
    _backgroundAudio.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage('assets/images/white_large.jpg'), repeat: ImageRepeat.repeat),
        ),
        child: Stack(children: [
          BubbleSimulationPainterWidget(bubbleSimulation: ServiceLocator.get<BubbleSimulation>()),
          Stack(
              children: List<Widget>.generate(_bubbles.length, (index) => RadioBubble(bubble: _bubbles[index]),
                  growable: false))
        ]));
  }

  Future<void> _startAudio() async {
    await _backgroundAudio.setAsset('assets/sounds/showersinging.wav');
    _backgroundAudio.setLoopMode(LoopMode.one);
    _backgroundAudio.play();
  }

  // TODO change to use flutter_bloc using RadioStationsBloc
  // see ../services/radio_stations_bloc.dart
  Future<void> _loadStations() async {
    final stations = await ServiceLocator.get<RadioStationsApi>().getRadioStations(limit: 32);
    if (stations.isEmpty) {
      // no stations loaded
      return;
    }
    int minVotes = stations[0].votes;
    int maxVotes = stations[0].votes;

    for (var station in stations) {
      minVotes = min(minVotes, station.votes);
      maxVotes = max(maxVotes, station.votes);
    }
    double voteVariance = (maxVotes - minVotes).toDouble();

    setState(() {
      _bubbles.clear();
      for (var station in stations) {
        final votePower = (station.votes - minVotes) / voteVariance;
        final bubble = ServiceLocator.get<BubbleSimulation>().spawnBubbleWithRadius(32 + 32 * votePower);
        if (bubble != null) {
          bubble.station = station;
          _bubbles.add(bubble);
        }
      }
    });
  }
}
