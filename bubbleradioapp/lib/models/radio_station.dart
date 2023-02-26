class RadioStation {
  final String name;
  final String url;
  final String favicon;

  RadioStation({required this.name, required this.url, required this.favicon});

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    // Example JSON object
    // "changeuuid": "de1da046-eaae-4ee8-abdf-8187e89dcf33",
    // "stationuuid": "d1a54d2e-623e-4970-ab11-35f7b56c5ec3",
    // "serveruuid": "b40473b6-aa07-432d-9df2-0ab251399a04",
    // "name": "Classic Vinyl HD",
    // "url": "https://icecast.walmradio.com:8443/classic",
    // "url_resolved": "https://icecast.walmradio.com:8443/classic",
    // "homepage": "https://walmradio.com/classic",
    // "favicon": "https://icecast.walmradio.com:8443/classic.jpg",
    // "tags": "1930,1940,1950,1960,beautiful music,big band,classic hits,crooners,easy,easy listening,hd,jazz,light orchestral,lounge,oldies,orchestral,otr,relaxation,strings,swing,unwind,walm",
    // "country": "The United States Of America",
    // "countrycode": "US",
    // "iso_3166_2": "US-NY",
    // "state": "New York NY",
    // "language": "english",
    // "languagecodes": "en",
    // "votes": 63319,
    // "lastchangetime": "2022-11-24 20:54:25",
    // "lastchangetime_iso8601": "2022-11-24T20:54:25Z",
    // "codec": "MP3",
    // "bitrate": 320,
    // "hls": 0,
    // "lastcheckok": 1,
    // "lastchecktime": "2023-02-24 03:13:41",
    // "lastchecktime_iso8601": "2023-02-24T03:13:41Z",
    // "lastcheckoktime": "2023-02-24 03:13:41",
    // "lastcheckoktime_iso8601": "2023-02-24T03:13:41Z",
    // "lastlocalchecktime": "2023-02-23 18:49:40",
    // "lastlocalchecktime_iso8601": "2023-02-23T18:49:40Z",
    // "clicktimestamp": "2023-02-24 11:10:53",
    // "clicktimestamp_iso8601": "2023-02-24T11:10:53Z",
    // "clickcount": 4183,
    // "clicktrend": 118,
    // "ssl_error": 0,
    // "geo_lat": 40.75166,
    // "geo_long": -73.97538,
    // "has_extended_info": true

    return RadioStation(
      name: json['name'],
      url: json['url'],
      favicon: json['favicon'],
    );
  }
}
