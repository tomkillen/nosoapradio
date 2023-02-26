import 'package:bubbleradioapp/services/radio_stations_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/radio_station.dart';

class RadioStationsBloc extends Cubit<List<RadioStation>> {
  final _api = RadioStationsApi();

  RadioStationsBloc() : super([]);

  Future<void> getRadioStations() async {
    try {
      final stations = await _api.getRadioStations();
      emit(stations);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load radio stations: $e');
      }
    }
  }
}
