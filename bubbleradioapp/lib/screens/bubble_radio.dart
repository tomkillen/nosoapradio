import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/bubble.dart';
import '../physics/bubble_simulation.dart';
import '../services/radio_stations_api.dart';
import '../services/service_locator.dart';
import '../widgets/radio_station_bubble.dart';

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
  static const double minBubbleSize = 32;
  static const double maxBubbleSize = 64;
  final _backgroundAudio = AudioPlayer();
  final _sfxBigPop = AudioPlayer();
  final _sfxMidPop = AudioPlayer();
  final _sfxSmallPop = AudioPlayer();
  final List<RadioStationBubble> _radioBubbleWidgets = [];

  @override
  void initState() {
    super.initState();
    _loadStations();
    _sfxBigPop.setAsset('assets/sounds/big_pop.wav');
    _sfxMidPop.setAsset('assets/sounds/middle_pop.wav');
    _sfxSmallPop.setAsset('assets/sounds/small_pop.wav');

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
        child: Stack(children: _radioBubbleWidgets));
  }

  RadioStationBubble _createRadioBubbleWidget(Bubble bubble) {
    return RadioStationBubble(bubble: bubble, onBubbleSelected: _onBubbleSelected, onBubblePopped: _onBubblePopped);
  }

  void _onBubbleSelected(Bubble bubble) {}

  void _onBubblePopped(Bubble bubble) {
    // Despawn the bubble or reuse it as another radio station
    ServiceLocator.get<BubbleSimulation>().respawnBubble(bubble, minBubbleSize, maxBubbleSize);

    // Give some feedback, with the strength of the pop audio sfx corresponding
    // to the bubble size
    if (bubble.radius < 42) {
      _playSmallBubblePop();
    } else if (bubble.radius < 52) {
      _playMidBubblePop();
    } else {
      _playBigBubblePop();
    }
  }

  Future<void> _playSmallBubblePop() async {
    await _sfxBigPop.stop();
    await _sfxBigPop.seek(Duration.zero);
    _sfxBigPop.play();
  }

  Future<void> _playMidBubblePop() async {
    await _sfxBigPop.stop();
    await _sfxBigPop.seek(Duration.zero);
    _sfxBigPop.play();
  }

  Future<void> _playBigBubblePop() async {
    await _sfxBigPop.stop();
    await _sfxBigPop.seek(Duration.zero);
    _sfxBigPop.play();
  }

  Future<void> _startShowerAudio() async {
    await _backgroundAudio.setAsset('assets/sounds/showersinging.wav');
    _backgroundAudio.setLoopMode(LoopMode.one);
    _backgroundAudio.play();
  }

  Future<void> _loadStations() async {
    final stations = await ServiceLocator.get<RadioStationsApi>().getRadioStations(limit: 32);
    if (stations.isEmpty) {
      // no stations loaded
      return;
    }

    // int minVotes = stations[0].votes;
    // int maxVotes = stations[0].votes;
    // for (var station in stations) {
    //   minVotes = min(minVotes, station.votes);
    //   maxVotes = max(maxVotes, station.votes);
    // }
    //double voteVariance = (maxVotes - minVotes).toDouble();

    setState(() {
      for (var station in stations) {
        // final votePower = (station.votes - minVotes) / voteVariance;
        var bubble = ServiceLocator.get<BubbleSimulation>().spawnRandomBubble(minBubbleSize, maxBubbleSize);
        if (bubble != null) {
          bubble.station = station;
          _radioBubbleWidgets.add(_createRadioBubbleWidget(bubble));
        }
      }
    });
  }
}
