import 'package:bubbleradioapp/services/radio_stations_api.dart';
import 'package:bubbleradioapp/services/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/radio_station.dart';

/// Bloc'ifies access to RadioStationsApi
class RadioStationsBloc extends Cubit<List<RadioStation>> {
  RadioStationsBloc() : super([]);

  Future<void> fetchRadioStations(int limit) async {
    try {
      final stations = await ServiceLocator.get<RadioStationsApi>().getRadioStations(limit: limit);
      emit(stations);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load radio stations: $e');
      }
    }
  }
}
