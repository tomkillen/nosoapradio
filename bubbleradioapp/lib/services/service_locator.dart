import 'package:get_it/get_it.dart';

import '../physics/bubble_simulation.dart';
import 'radio_stations_api.dart';

class ServiceLocator {
  static init() {
    GetIt.instance.registerLazySingleton<BubbleSimulation>(() => BubbleSimulation());
    GetIt.instance.registerLazySingleton<RadioStationsApi>(() => RadioStationsApi());
  }

  static T get<T extends Object>() {
    return GetIt.instance.get<T>();
  }
}
