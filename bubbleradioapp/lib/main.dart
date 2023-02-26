import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'models/radio_station.dart';
import 'screens/bubble_radio.dart';
import 'screens/radio_station_player.dart';
import 'services/radio_stations_bloc.dart';
import 'services/service_locator.dart';

void main() {
  ServiceLocator.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RadioStationsBloc(),
      child: MaterialApp(
          title: 'Bubble Radio',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          // initialRoute: '/welcome',
          home: BubbleRadio(),
          routes: {
            '/radio': (context) => RadioPlayer(station: ModalRoute.of(context)!.settings.arguments as RadioStation),
          }),
    );
  }
}
