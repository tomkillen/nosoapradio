import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/radio_station.dart';

class RadioStationsService extends Cubit<List<RadioStation>> {
  RadioStationsService() : super([]);

  Future<void> getRadioStations() async {
    try {
      final response = await http.get(_createRadioStationQuery(limit: 20));
      final json = jsonDecode(response.body) as List<dynamic>;
      final stations = json.map((e) => RadioStation.fromJson(e)).toList();
      emit(stations);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load radio stations: $e');
      }
    }
  }

  Uri _createRadioStationQuery({int limit = 10}) {
    return Uri.parse(
        'https://de1.api.radio-browser.info/json/stations/search?limit=$limit&hidebroken=true&has_extended_info=true&order=votes&reverse=true');
  }
}
