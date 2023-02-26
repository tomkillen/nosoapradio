import 'package:bubbleradioapp/services/radio_stations_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'screens/boring_radio_station_directory.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RadioStationsService(),
      child: MaterialApp(
        title: 'Bubble Radio',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Scaffold(body: RadioStationList()),
      ),
    );
  }
}
