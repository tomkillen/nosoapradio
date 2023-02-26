import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/radio_station.dart';
import '../services/radio_stations_service.dart';

class RadioStationList extends StatelessWidget {
  const RadioStationList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RadioStationsBloc, List<RadioStation>>(
      builder: (context, stations) {
        return ListView.builder(
          itemCount: stations.length,
          itemBuilder: (context, index) {
            final station = stations[index];
            return ListTile(
              title: Text(station.name),
              subtitle: Text(station.url),
              onTap: () => {Navigator.pushNamed(context, '/radio', arguments: station)},
            );
          },
        );
      },
      buildWhen: (previous, current) => current.isNotEmpty,
      bloc: BlocProvider.of<RadioStationsBloc>(context)..getRadioStations(),
    );
  }
}
