import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/radio_station.dart';

/// API for loading radio stations
class RadioStationsApi {
  /// FIFO queue of known radio stations that have not yet been consumed
  final List<RadioStation> _available = [];

  /// Tracks which page of radio stations we have loaded
  int _page = 1;

  /// Gets the indicated number of radio stations from the
  Future<List<RadioStation>> getRadioStations({int limit = 20}) async {
    while (_available.length < limit) {
      final loaded = await _getMoreRadioStations();
      if (loaded.isEmpty) {
        // We failed to load more stations, so exit the loop
        break;
      } else {
        // Enqueue the loaded stations to our list
        _available.addAll(loaded);
      }
    }
    List<RadioStation> nextStations = _available.sublist(0, limit);
    _available.removeRange(0, limit);
    return nextStations;
  }

  /// Helper method that loads the next batch of radio stations from the server
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

  /// Helper method that constructs the query for fetching the desired number of
  /// radio stations
  Uri _createRadioStationQuery({int page = 1, int limit = 20}) {
    return Uri.parse(
        'https://de1.api.radio-browser.info/json/stations/search?page=$page&limit=$limit&hidebroken=true&has_extended_info=true&order=random');
  }
}
