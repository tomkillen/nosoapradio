import 'package:get_it/get_it.dart';

import '../physics/bubble_simulation.dart';
import 'radio_stations_api.dart';

/// Utility class that implements a simple provider pattern, making business
/// logic accessible to the UI layer
class ServiceLocator {
  /// Registers the services for this app
  static init() {
    GetIt.instance.registerLazySingleton<BubbleSimulation>(() => BubbleSimulation());
    GetIt.instance.registerLazySingleton<RadioStationsApi>(() => RadioStationsApi());
  }

  /// Gets the indicated service, e.g. `ServiceLocator.get<MyService>()`
  static T get<T extends Object>() {
    return GetIt.instance.get<T>();
  }
}
