import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/radio_station.dart';
import 'radio_stations_api.dart';
import 'service_locator.dart';

/// Bloc'ifies access to RadioStationsApi for widgets that want to access that
/// service using the bloc provider instead of the ServiceLocator provider
class RadioStationsBloc extends Cubit<List<RadioStation>> {
  RadioStationsBloc() : super([]);

  /// Fetches the desired number of radio stations from teh server
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
