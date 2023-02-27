import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/radio_station.dart';

/// API for loading radio stations
class RadioStationsApi {
  /// Well-known DNS record for available servers
  static const String WellKnownApiBrowserUrl = 'all.api.radio-browser.info';

  /// Fallback server url that is known to work at build time, hopefully still does latere
  static const String FallbackServerUrl = 'de1.api.radio-browser.info';

  /// FIFO queue of known radio stations that have not yet been consumed
  final List<RadioStation> _available = [];

  /// Tracks which page of radio stations we have loaded
  int _page = 1;

  /// Which server should we be using
  String? _apiBaseUrl;

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
      _apiBaseUrl ??= await _findApiBaseUrl();
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
        'https://$_apiBaseUrl/json/stations/search?page=$page&limit=$limit&hidebroken=true&has_extended_info=true&order=random');
  }

  /// Helper utility to find an appropriate API base url
  Future<String> _findApiBaseUrl() async {
    try {
      // Perform the DNS lookup to get a list of server addresses
      List<InternetAddress> addresses = await InternetAddress.lookup(WellKnownApiBrowserUrl);
      List<String> apiBaseUrls = [];

      // For each server address, see if we can get a valid host name
      for (InternetAddress address in addresses) {
        // Perform a reverse DNS lookup to find the host name
        InternetAddress hostnames = await address.reverse();
        apiBaseUrls.add(hostnames.host);
      }

      // Choose a server
      if (apiBaseUrls.isEmpty) {
        return FallbackServerUrl;
      } else {
        return apiBaseUrls[0];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to lookup $WellKnownApiBrowserUrl: $e');
      }
      return FallbackServerUrl;
    }
  }
}
