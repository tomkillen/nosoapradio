import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/radio_station.dart';
import '../services/radio_stations_bloc.dart';

/// A very simple list of radio stations, useful for simply viewing the list
/// of radio stations, if you want.
class RadioStationList extends StatelessWidget {
  const RadioStationList({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the radio stations bloc
    return BlocBuilder<RadioStationsBloc, List<RadioStation>>(
      builder: (context, stations) {
        // 3. Build a list using the loaded list of radio stations
        return ListView.builder(
          itemCount: stations.length,
          itemBuilder: (context, index) {
            final station = stations[index];
            // 3. Each radio station becomes a list item
            return ListTile(
              title: Text(station.name),
              subtitle: Text(station.url),
              // 4. Open the radio player when a radio is selected
              onTap: () => {Navigator.pushNamed(context, '/radio', arguments: station)},
            );
          },
        );
      },
      buildWhen: (previous, current) => current.isNotEmpty,
      // 2. Update me with the available radio stations
      bloc: BlocProvider.of<RadioStationsBloc>(context)..fetchRadioStations(20),
    );
  }
}
