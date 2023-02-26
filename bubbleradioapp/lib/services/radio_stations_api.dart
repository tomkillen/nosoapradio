import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/radio_station.dart';

class RadioStationsApi {
  Future<List<RadioStation>> getRadioStations({int limit = 20}) async {
    try {
      final response = await http.get(_createRadioStationQuery(limit: limit));
      final json = jsonDecode(response.body) as List<dynamic>;
      final stations = json.map((e) => RadioStation.fromJson(e)).toList();
      return stations;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load radio stations: $e');
      }
      return [];
    }
  }

  Uri _createRadioStationQuery({int limit = 20}) {
    return Uri.parse(
        'https://de1.api.radio-browser.info/json/stations/search?limit=$limit&hidebroken=true&has_extended_info=true&order=votes&reverse=true');
  }
}
