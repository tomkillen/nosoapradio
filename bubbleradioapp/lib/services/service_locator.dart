import 'package:bubbleradioapp/physics/bubble_simulation.dart';
import 'package:bubbleradioapp/services/radio_stations_api.dart';
import 'package:get_it/get_it.dart';

class ServiceLocator {
  static init() {
    GetIt.instance.registerLazySingleton<BubbleSimulation>(() => BubbleSimulation());
    GetIt.instance.registerLazySingleton<RadioStationsApi>(() => RadioStationsApi());
  }

  static T get<T extends Object>() {
    return GetIt.instance.get<T>();
  }
}
