import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/bubble.dart';
import '../physics/bubble_simulation.dart';
import '../services/radio_stations_api.dart';
import '../services/service_locator.dart';
import '../widgets/radio_station_bubble.dart';

/// A Screen that displays a set of bubbles on screen, those bubbles are
/// animated using a physics animation system. Each bubble can be popped by
/// tapping it, and double tapping a bubble will open the radio station player
/// for the radio associated with that bubble
class BubbleRadio extends StatefulWidget {
  BubbleRadio({super.key}) {
    _initSimulation();
  }

  @override
  State<StatefulWidget> createState() => _BubbleRadioState();

  void _initSimulation() {
    // Create a bubble simulation sized to fit the physical screen
    final Size simSize = window.physicalSize / window.devicePixelRatio;
    ServiceLocator.get<BubbleSimulation>().initialize(simSize);
  }
}

class _BubbleRadioState extends State<BubbleRadio> with WidgetsBindingObserver {
  static const double minBubbleSize = 32;
  static const double maxBubbleSize = 64;
  final _random = Random();
  final _backgroundAudio = AudioPlayer();
  final _sfxBigPop = AudioPlayer();
  final List<RadioStationBubble> _radioBubbleWidgets = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadStations(18);
    _loadPops();

    _startShowerAudio();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startShowerAudio();
        break;
      case AppLifecycleState.inactive:
        _stopShowerAudio();
        break;
      case AppLifecycleState.paused:
        _stopShowerAudio();
        break;
      case AppLifecycleState.detached:
        _stopShowerAudio();
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundAudio.stop();
    _backgroundAudio.dispose();
    _sfxBigPop.stop();
    _sfxBigPop.dispose();
    super.dispose();
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

  void _onBubbleSelected(BuildContext context, Bubble bubble) {
    Navigator.pushNamed(context, '/radio', arguments: bubble.station!);
  }

  void _onBubblePopped(Bubble bubble) {
    // Despawn the bubble or reuse it as another radio station
    ServiceLocator.get<BubbleSimulation>().respawnBubble(bubble, minBubbleSize, maxBubbleSize);
    _removeDeadRadioBubble(deadBubble: bubble);

    // Give some feedback
    _playBigBubblePop();
  }

  Future<void> _loadPops() async {
    await _sfxBigPop.setAsset('assets/sounds/big_pop.wav');
  }

  Future<void> _playBigBubblePop() async {
    await _sfxBigPop.stop();
    await _sfxBigPop.seek(Duration.zero);
    _sfxBigPop.play();
  }

  Future<void> _startShowerAudio() async {
    if (!_backgroundAudio.playing) {
      await _backgroundAudio.setAsset('assets/sounds/showersinging.wav');
      _backgroundAudio.setLoopMode(LoopMode.one);
      _backgroundAudio.play();
    }
  }

  Future<void> _stopShowerAudio() async {
    if (_backgroundAudio.playing) {
      _backgroundAudio.stop();
    }
  }

  Future<void> _removeDeadRadioBubble({required Bubble deadBubble, double delaySeconds = -1.0}) async {
    // Wait for the bubble to complete it's pop and remove it
    if (delaySeconds < 0) {
      delaySeconds = _random.nextDouble() * 2.0 + 2.0;
    }
    Timer(Duration(microseconds: (delaySeconds * 1000.0 * 1000.0).toInt()), () {
      _loadStations(1);
    });
  }

  Future<void> _loadStations(int numToLoad) async {
    final stations = await ServiceLocator.get<RadioStationsApi>().getRadioStations(limit: numToLoad);
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
        if (station.favicon != '' && station.url != '') {
          // final votePower = (station.votes - minVotes) / voteVariance;
          var bubble = ServiceLocator.get<BubbleSimulation>().spawnRandomBubble(minBubbleSize, maxBubbleSize);
          bubble.station = station;
          _radioBubbleWidgets.add(_createRadioBubbleWidget(bubble));
        }
      }
    });
  }
}
