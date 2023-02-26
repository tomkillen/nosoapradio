import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/radio_station.dart';

class RadioStationsApi {
  final List<RadioStation> _available = [];
  int _page = 1;

  Future<List<RadioStation>> getRadioStations({int limit = 20}) async {
    while (_available.length < limit) {
      _available.addAll(await _getMoreRadioStations());
    }
    List<RadioStation> nextStations = _available.sublist(0, limit);
    _available.removeRange(0, limit);
    return nextStations;
  }

  Future<List<RadioStation>> _getMoreRadioStations() async {
    try {
      final response = await http.get(_createRadioStationQuery(page: _page, limit: 20));
      final json = jsonDecode(response.body) as List<dynamic>;
      final stations = json.map((e) => RadioStation.fromJson(e)).toList();
      _page++;
      return stations;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load radio stations: $e');
      }
      return [];
    }
  }

  Uri _createRadioStationQuery({int page = 1, int limit = 20}) {
    return Uri.parse(
        'https://de1.api.radio-browser.info/json/stations/search?page=$page&limit=$limit&hidebroken=true&has_extended_info=true&order=random');
  }
}
